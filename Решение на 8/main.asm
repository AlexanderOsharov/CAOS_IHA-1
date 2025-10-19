.include "io_macros.asm"
.include "array_io_macros.asm"
.include "rearrange_macros.asm"
#.include "utils.asm"

.data
array_a:        .word 0 : 10
array_b:        .word 0 : 10

prompt_n:       .asciz "Enter N (1-10): "
prompt_a_prefix:.asciz "Enter A["
prompt_a_suffix:.asciz "]: "
error_msg:      .asciz "Error: N must be between 1 and 10.\n"
label_a:        .asciz "Array A: "
label_b:        .asciz "Array B: "

.text
.globl main
main:

    # Запрос N
    print_str(prompt_n)
    jal ra, utils_read_int_safe   # Вызов функции
    bnez a1, _invalid             # если a1 != 0 -> ошибка парсинга
    mv s3, a0                     # s3 = N

    # Проверка диапазона (вдобавок можно вызвать utils_validate_n)
    jal ra, utils_validate_n      # a0 содержит N при входе
    beqz a0, _invalid             # если 0 -> некорректно

    # Ввод массива
    la s0, array_a
    li s2, 0
.input_loop:
    beq s2, s3, .input_done
    print_str(prompt_a_prefix)
    print_int(s2)
    print_str(prompt_a_suffix)
    jal ra, utils_read_int_safe
    bnez a1, _invalid
    slli t0, s2, 2
    add t1, s0, t0
    sw a0, 0(t1)
    addi s2, s2, 1
    j .input_loop

.input_done:
    print_str(label_a)
    print_array(s3, s0)

    la s1, array_b
    rearrange_arrays(s3, s0, s1)

    print_str(label_b)
    print_array(s3, s1)

    exit()

_invalid:
    print_str(error_msg)
    exit()
