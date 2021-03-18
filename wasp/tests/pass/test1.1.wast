;; Must pass
;; Tests if stored value in memory is still equal to x and different than z
(module 
    (memory $0 1)

    (func $main (result i32)
        (i32.const 1)                   ;; address number
        (sym_float32 "x")                 ;; value
        (f32.const 1)
        (f32.add)
        (f32.store offset=0)            ;; store in offset

        (i32.const 1)                   ;; address number
        (sym_float32 "y")                 ;; value
        (f32.const 2)
        (f32.add)
        (f32.store offset=4)            ;; store in offset
        
        (i32.const 1)
        (f32.load offset=0) ;; loads x
        (get_sym_float32 "x")
        (f32.const 1)
        (f32.add)
        (f32.eq)            ;; checks if the loaded value is equal to x
        (print_stack)
        (print_memory)
        (sym_assert)

        (i32.const 1)
        (f32.load offset=4) ;; loads x
        (get_sym_float32 "y")
        (f32.const 2)
        (f32.add)
        (f32.eq)            ;; checks if the loaded value is equal to y
        (sym_assert)


        (i32.const 0) ;;return
    )
    (export "main" (func $main))
)
(invoke "main")
