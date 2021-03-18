;; Must fail
;; Tests simple control flow
(module 
    (memory $0 1)

    (func $main
        (sym_int32 "x")
        (sym_int32 "y")
        (sym_int32 "z")         ;; just to create the variable
        (drop)
        (i32.lt_s)            ;; if x < y
        (if
            (then
                (loop
                    (get_sym_int32 "x")
                    (i32.const 1)
                    (i32.add)
                    (get_sym_int32 "y")
                    (i32.eq)
                    (br_if 1)               ;; break if x+1 = y
                    (get_sym_int32 "z")
                    (get_sym_int32 "y")
                    (i32.eq)
                    (if                     ;; if z == x
                        (then
                            (get_sym_int32 "z")
                            (i32.const 0)
                            (i32.gt_s)
                            (sym_assert)    ;; assert z > 0
                        )
                    )
                )
            )
        )
    )
    (export "main" (func $main))
)
(invoke "main")