#include "queue.h"
#include "utils.h"
#include <gillian-c/gillian-c.h>

static Queue *q;
static Queue *q2;
static int stat;

void setup_test() {
    stat = queue_new(&q);
    queue_new(&q2);
}

void teardown_test() {
    queue_destroy(q);
    queue_destroy(q2);
}

int main() {
    setup_test();

    char a = (char)__builtin_annot_intval("symb_int", a);
    char str_a[] = {a, '\0'};

    char b = (char)__builtin_annot_intval("symb_int", b);
    char str_b[] = {b, '\0'};

    char c = (char)__builtin_annot_intval("symb_int", c);
    char str_c[] = {c, '\0'};

    char d = (char)__builtin_annot_intval("symb_int", d);
    char str_d[] = {d, '\0'};

    char e = (char)__builtin_annot_intval("symb_int", e);
    char str_e[] = {e, '\0'};

    char f = (char)__builtin_annot_intval("symb_int", f);
    char str_f[] = {f, '\0'};

    char g = (char)__builtin_annot_intval("symb_int", g);
    char str_g[] = {g, '\0'};

    queue_enqueue(q, str_a);
    queue_enqueue(q, str_b);
    queue_enqueue(q, str_c);
    queue_enqueue(q, str_d);

    queue_enqueue(q2, str_e);
    queue_enqueue(q2, str_f);
    queue_enqueue(q2, str_g);

    QueueZipIter zip;
    queue_zip_iter_init(&zip, q, q2);

    size_t i = 0;

    void *e1, *e2;
    while (queue_zip_iter_next(&zip, &e1, &e2) != CC_ITER_END) {
        if (i == 0) {
            ASSERT(strcmp(str_d, (char *)e1) == 0);
            ASSERT(strcmp(str_g, (char *)e2) == 0);
        }
        if (i == 2) {
            ASSERT(strcmp(str_b, (char *)e1) == 0);
            ASSERT(strcmp(str_e, (char *)e2) == 0);
        }
        i++;
    }
    ASSERT(3 == i);

    teardown_test();
    return 0;
}
