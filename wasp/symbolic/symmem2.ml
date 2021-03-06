open Types
open Values
open Symvalue

type size = int32
type address = int64
type offset = int32
type store = int * sym_expr

(*  Represents a symbolic memory  *)
type memory = (address, store) Hashtbl.t 
type t = memory

exception Bounds
exception InvalidAddress of address

let packed_size = function
  | Memory.Pack8  -> 1
  | Memory.Pack16 -> 2
  | Memory.Pack32 -> 4

(*
let fresh_sth (x : string) : (unit -> string) =
  let counter = ref 0 in
  let f () =
    let v = x ^ (string_of_int !counter) in
    counter := !counter + 1;
    v
  in f

let fresh_sym : (unit -> string) =
  fresh_sth "undef"
*)

(*  Create an empty symbolic memory  *)
let alloc (sz : int) : memory = 
  let mem : memory = Hashtbl.create sz in
  mem

let size (mem : memory) : int = 
  Hashtbl.length mem

let clear (mem : memory) : unit =
  Hashtbl.clear mem

let memcpy (mem : memory) : memory =
  Hashtbl.copy mem

let iter (f : address -> store -> unit) (mem : memory) : unit =
  Hashtbl.iter f mem

let init (mem : memory) (l : (address * store) list) : unit =
  List.iter (fun (a, s) -> Hashtbl.replace mem a s) l

let to_list (mem : memory) : (address * store) list =
  Hashtbl.fold (fun a s acc -> (a, s) :: acc) mem []

let to_string (mem : memory) : string = 
  let lst = List.sort (fun (a, _) (b, _) -> compare a b) (to_list mem) in
  List.fold_right (
    fun (a, (v, e)) b ->
      "(" ^ (Int64.to_string a) ^ "->" ^ 
      "(" ^ (string_of_int v)   ^ ", " ^ (Symvalue.to_string e) ^ ")" ^
      ")\n" ^ b
  ) lst ""

let load_byte (mem : memory) (a : address) : store =
  try Hashtbl.find mem a with Not_found -> 
    (0, Extract (Value (I64 0L), 8, 0))
    (* raise (InvalidAddress a) *)

let store_byte (mem : memory) (a : address) (b : store) : unit =
  Hashtbl.replace mem a b

let load_bytes (mem : memory) (a : address) (n : int) : string * sym_expr =
  let buf = Buffer.create n in
  let rec loop i acc =
    if i = (n - 1) then acc else begin
      let (chr, schr) = load_byte mem Int64.(add a (of_int i)) in
      Buffer.add_char buf (Char.chr chr);
      loop (i + 1) (schr :: acc)
    end
  in
  let lst = List.rev (loop 0 []) in
  let se = simplify 
    (List.fold_left (fun a b -> Concat (b, a)) (List.hd lst) (List.tl lst))
  in (Buffer.contents buf, se)
    
let load_string (mem : memory) (a : address) : string =
  let rec loop a acc =
    let (c, _) = load_byte mem a in
    if c = 0 then acc 
             else loop (Int64.add a 1L) (acc ^ Char.(escaped (chr c)))
  in loop a ""

let store_bytes (mem : memory) (a : address) (bs : string) : unit =
  for i = String.length bs - 1 downto 0 do
    let b = Char.code bs.[i] in
    let sb = Extract (Value (I64 (Int64.of_int b)), 1, 0) in
    store_byte mem Int64.(add a (of_int i)) (b, sb)
  done

let effective_address (a : I64.t) (o : offset) : address =
  let ea = Int64.(add a (of_int32 o)) in
  if I64.lt_u ea a then raise Bounds;
  ea

let loadn (mem : memory) (a : address) (o : offset) (n : int) =
  assert (n > 0 && n <= 8);
  let rec loop a n acc = 
    if n = 0 then acc else begin
      let (x, lacc) = acc
      and (cv, se) = load_byte mem a in
      let x' = Int64.(logor (of_int cv) (shift_left x 8)) in
      loop (Int64.sub a 1L) (n - 1) (x', se :: lacc)
    end
  in loop Int64.(add (effective_address a o) (of_int (n - 1))) n (0L, [])

let storen (mem : memory) (a : address) (o : offset) (n : int) 
    (x : int64 * sym_expr) : unit =
  assert (n > 0 && n <= 8);
  let rec loop a i n x =
    if n > i then begin 
      let (cv, se) = x in
      let b = Int64.to_int cv land 0xff in
      let se' = match se with 
        | Symvalue.Value v -> 
          let v' = match v with
          | I32 x -> I64 (Int64.of_int32 x)
          | I64 x -> I64 x
          | F32 x -> I64 (Int64.of_int32 (F32.to_bits x))
          | F64 x -> I64 (F64.to_bits x)
          in Symvalue.Value v'
        | _ -> se 
      in store_byte mem a (b, Extract (se', i+1, i));
      loop (Int64.add a 1L) (i + 1) n ((Int64.shift_right cv 8), se)
    end 
  in loop (effective_address a o) 0 n x

let load_value (mem : memory) (a : address) (o : offset) 
    (t : value_type) : sym_value  =
  (* FIXME: messy code *)
  let (n, se) = loadn mem a o (Types.size t) in
  (* Concat symbolic byte list *)
  let se = List.fold_left (fun a b -> Concat (b, a)) (List.hd se) (List.tl se) in
  (* Cast to `t` *)
  let n' , se' = match t with
    | I32Type -> I32 (Int64.to_int32 n), se
    | I64Type -> I64 n, se
    | F32Type -> 
        F32 (F32.of_bits (Int64.to_int32 n)), 
        F32Cvtop (Sf32.F32ReinterpretInt, se)
    | F64Type -> 
        F64 (F64.of_bits n), 
        F64Cvtop (Sf64.F64ReinterpretInt, se) in
  let se' = simplify se' in
  let se' = match se' with 
    | F32Cvtop (Sf32.F32ReinterpretInt, Extract (Value _, _, _))
    | F64Cvtop (Sf64.F64ReinterpretInt, Extract (Value _, _, _))
    | Extract (Value (I64 _), _, _) -> Symvalue.Value n'
    | _ -> se' 
  in (n', se')

let store_value (mem : memory) (a : address) (o : offset) 
    (v : sym_value) : unit =
  let (cv, sv) = v in
  let x, sv = match cv with
    | I32 x -> Int64.of_int32 x, sv
    | I64 x -> x, sv
    | F32 x -> 
        let sv' = match sv with
          | Value (F32 x) -> Symvalue.Value (I32 (F32.to_bits x))
          | _ -> I32Cvtop (Si32.I32ReinterpretFloat, sv)
        in Int64.of_int32 (F32.to_bits x), sv'
    | F64 x -> 
        let sv' = match sv with
          | Value (F64 x) -> Symvalue.Value (I64 (F64.to_bits x))
          | _ -> I64Cvtop (Si64.I64ReinterpretFloat, sv)
        in F64.to_bits x, sv'
  in storen mem a o (Types.size (Values.type_of cv)) (x, sv)

let extend x n = function
  | Memory.ZX -> x
  | Memory.SX -> let sh = 64 - 8 * n in Int64.(shift_right (shift_left x sh) sh)

let load_packed (sz : Memory.pack_size) (ext : Memory.extension)
    (mem : memory) (a : address) (o : offset) (t : value_type) : sym_value =
  let n = packed_size sz in
  let (cv, sv) = loadn mem a o n in
  let cv = extend cv n ext in
  let x' =
    begin match t with
    | I32Type -> I32 (Int64.to_int32 cv)
    | I64Type -> I64 cv
    | _ -> raise Memory.Type
    end
  in
  let sv' = 
    let rec loop acc i =
      if i >= (Types.size t) then acc
      else loop (acc @ [Extract (Value (I64 0L), i+1, i)]) (i + 1)
    in loop sv (List.length sv)
  in
  let sv'' = simplify
    (List.fold_left (fun a b -> Concat (b, a)) (List.hd sv') (List.tl sv')) in
  let se = match sv'' with 
    | Extract (Value (I64 _), _, _) -> Symvalue.Value x'
    | _ -> sv''
  in (x', se)

let store_packed (sz : Memory.pack_size) (mem : memory) (a : address) 
    (o : offset) (v : sym_value) : unit =
  let n = packed_size sz in
  let (cv, sv) = v in
  let x =
    match cv with
    | I32 x -> Int64.of_int32 x
    | I64 x -> x
    | _     -> raise Memory.Type
  in storen mem a o n (x, sv)

let update (mem : memory) (env : Logicenv.t) : unit =
  iter (fun a s ->
    let (_, se) = s in
    let i = match Logicenv.eval env se with
      | I32 x -> Int32.to_int x
      | I64 x -> Int64.to_int x
      | F32 x -> Int32.to_int (F32.to_bits x)
      | F64 x -> Int64.to_int (F64.to_bits x)
    in store_byte mem a (i, se)
  ) mem
