open Types
open Symvalue

type memory
type t = memory

type size = int32
type address = int64
type offset = int32
type store = int * sym_expr

exception Bounds
exception InvalidAddress of address

val packed_size : Memory.pack_size -> int

val alloc : int -> memory
val size : memory -> int
val clear : memory -> unit
val memcpy : memory -> memory
val init : memory -> (address * store) list -> unit
val update : memory -> Logicenv.t -> unit

val to_list : memory -> (address * store) list
val to_string : memory -> string

val load_byte : memory -> address -> store
val store_byte : memory -> address -> store -> unit
val load_string : memory -> address -> string
val load_bytes : memory -> address -> int -> string * sym_expr
val store_bytes : memory -> address -> string -> unit

val load_value : 
  memory -> address -> offset -> value_type -> sym_value
val store_value : 
  memory -> address -> offset -> sym_value -> unit
val load_packed : 
  Memory.pack_size -> Memory.extension -> memory -> address ->
    offset -> value_type -> sym_value
val store_packed : 
  Memory.pack_size -> memory -> address -> offset -> sym_value -> unit
