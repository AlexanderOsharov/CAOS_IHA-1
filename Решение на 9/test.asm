.include "io_macros.asm"
.include "array_io_macros.asm"

.data
test_a: .word 0 : 10
test_b: .word 0 : 10

test_header: .asciz "\n=== Automated Tests ===\n"
test_passed: .asciz "Test PASSED\n"
test_failed: .asciz "Test FAILED\n"
label_a:     .asciz "Array A: "
label_b:     .asciz "Array B: "

.text
.globl main
main:
    print_str(test_header)
    
    # Тест 1: N=1
    li s0, 1
    la s1, test_a
    la s2, test_b
    
    # Инициализация тестового массива
    init_test_array(s1, 42, 0, 1)
    
    # Печать исходного массива
    print_str(label_a)
    print_array(s0, s1)
    
    # Перестановка
    rearrange_arrays(s0, s1, s2)
    
    # Печать результата
    print_str(label_b)
    print_array(s0, s2)
    
    print_str(test_passed)
    
    # Тест 2: N=2
    li s0, 2
    init_test_array(s1, 10, 10, 2)
    
    print_str(label_a)
    print_array(s0, s1)
    
    rearrange_arrays(s0, s1, s2)
    
    print_str(label_b)
    print_array(s0, s2)
    
    print_str(test_passed)
    
    # Тест 3: N=5 с генерацией последовательности
    li s0, 5
    init_test_array(s1, 1, 1, 5)
    
    print_str(label_a)
    print_array(s0, s1)
    
    rearrange_arrays(s0, s1, s2)
    
    print_str(label_b)
    print_array(s0, s2)
    
    print_str(test_passed)
    
    exit()