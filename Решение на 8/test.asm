# test.asm
.include "io_macros.asm"
.include "array_io_macros.asm"
.include "rearrange_macros.asm"

.data
# Тестовые массивы A и буферы B
test1_a: .word 42
test1_b: .word 0

test2_a: .word 10, 20
test2_b: .word 0, 0

test3_a: .word 1, 2, 3, 4, 5
test3_b: .word 0, 0, 0, 0, 0

test4_a: .word 7, -3, 0, 9, 12, -5
test4_b: .word 0, 0, 0, 0, 0, 0

test5_a: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
test5_b: .word 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

# Метки для заголовков
label_test1: .asciz "\n--- Test 1: N=1 ---\nArray A: "
label_test2: .asciz "\n--- Test 2: N=2 ---\nArray A: "
label_test3: .asciz "\n--- Test 3: N=5 ---\nArray A: "
label_test4: .asciz "\n--- Test 4: N=6 ---\nArray A: "
label_test5: .asciz "\n--- Test 5: N=10 ---\nArray A: "
label_b:     .asciz "Array B: "

.text
.globl main
main:
    # Test 1: N = 1
    print_str(label_test1)
    la a0, test1_a
    li a1, 1
    print_array(a1, a0)

    la s0, test1_a
    la s1, test1_b
    rearrange_arrays(a1, s0, s1)

    print_str(label_b)
    print_array(a1, s1)

    # Test 2: N = 2
    print_str(label_test2)
    la a0, test2_a
    li a1, 2
    print_array(a1, a0)

    la s0, test2_a
    la s1, test2_b
    rearrange_arrays(a1, s0, s1)

    print_str(label_b)
    print_array(a1, s1)

    # Test 3: N = 5
    print_str(label_test3)
    la a0, test3_a
    li a1, 5
    print_array(a1, a0)

    la s0, test3_a
    la s1, test3_b
    rearrange_arrays(a1, s0, s1)

    print_str(label_b)
    print_array(a1, s1)

    # Test 4: N = 6
    print_str(label_test4)
    la a0, test4_a
    li a1, 6
    print_array(a1, a0)

    la s0, test4_a
    la s1, test4_b
    rearrange_arrays(a1, s0, s1)

    print_str(label_b)
    print_array(a1, s1)

    # Test 5: N = 10
    print_str(label_test5)
    la a0, test5_a
    li a1, 10
    print_array(a1, a0)

    la s0, test5_a
    la s1, test5_b
    rearrange_arrays(a1, s0, s1)

    print_str(label_b)
    print_array(a1, s1)

    exit()