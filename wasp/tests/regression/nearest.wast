;; Must pass
;; Tests f32 min
(module
    (func $main (local f32)
        (i32.const 1024)
        (f32.symbolic)      ;; retorna uma sym var com um valor random e a label `a`
        (local.tee 0)
        (f32.const 4.1)
        (f32.eq)
        (local.get 0)
        (f32.const 4.9)
        (f32.eq)
        (i32.__logor)
        (sym_assume)        ;; assume *a* == 4.1 || *a* == 4.9

        (local.get 0)
        (f32.nearest)
        (f32.const 4)
        (f32.eq)
        (sym_assume)        ;; assume 4 == nearest(*a*)

        (local.get 0)
        (f32.const 4.1)
        (f32.eq)            ;; *a* == 4.1

        (sym_assert)        ;; assert
    )
    (export "main" (func $main))
    (memory $0 1)
    (data $0 (i32.const 1024) "a\00b\00c\00")
)
(invoke "main")
