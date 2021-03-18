;; Must fail
;; Tests i32 arithmetic
(module 
    (memory $0 1)

    (func $main
        (sym_int32 "a")
        (i32.const 0)
        (i32.gt_s)
        (if (result i32)            ;; if a > 0
            (then
                (i32.const -2)      ;; x = -2
            )
            (else   
                (i32.const 0)       ;; x = 0
            )
        )

        (sym_int32 "b")
        (i32.const 5)
        (i32.lt_s)
        (if (result i32)                        ;; if b < 5
            (then
                (get_sym_int32 "a")
                (i32.const 0)
                (i32.lt_s)
                (if (result i32)                ;; if a < 0
                    (then
                        (sym_int32 "c")
                        (i32.const 0)
                        (i32.gt_s)
                        (if (result i32)            ;; if a < 0 && c > 0
                            (then
                                (i32.const 1) ;; y = 1
                            )
                            (else
                                (i32.const 0)   ;; y = 0
                            )
                        )
                    )
                    (else
                        (i32.const 0)   ;; y = 0
                    )
                )
                (i32.const 2)       ;; z = 2
                (i32.add)           ;; y + z
            )
            (else
                (i32.const 0)       ;; y + z = 0
            )
        )
        (i32.add)   ;; x + y + z
        (i32.const 3)
        (i32.ne)    
        (sym_assert)    ;; assert x+y+z != 3

    )
        
    (export "main" (func $main))
)
(invoke "main")




