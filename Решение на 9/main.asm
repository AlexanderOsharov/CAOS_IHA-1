.include "io_macros.asm"
.include "array_io_macros.asm"

.data
array_a:        .word 0 : 10
array_b:        .word 0 : 10

prompt_n:       .asciz "Enter N (1-10): "
error_msg:      .asciz "Error: N must be between 1 and 10.\n"
label_a:        .asciz "Array A: "
label_b:        .asciz "Array B: "

.text
.globl main
main:
    # Запрос N
    print_str(prompt_n)
    safe_read_int()           # Использование макроса-обертки
    bnez a1, _invalid
    mv s0, a0                 # s0 = N

    # Валидация N
    validate_n(s0)           # Использование макроса-обертки
    beqz a0, _invalid

    # Ввод массива A с использованием макроса
    # Загружаем адрес array_a в регистр для передачи в макрос
    la s1, array_a
    input_array(s0, s1)

    # Печать исходного массива
    print_str(label_a)
    print_array(s0, s1)

    # Перестановка элементов с использованием макроса
    la s2, array_b
    rearrange_arrays(s0, s1, s2)

    # Печать результирующего массива
    print_str(label_b)
    print_array(s0, s2)

    exit()

_invalid:
    print_str(error_msg)
    exit()