.include "io_macros.asm"
.include "array_io_macros.asm"

.data
array_a:        .word 0 : 10
array_b:        .word 0 : 10

main_error_msg: .asciz "Error: Invalid data in file\n"
label_a:        .asciz "Array A: "
label_b:        .asciz "Array B: "

.text
.globl main
main:
    # Инициализация массива нулями для безопасности
    la t0, array_a
    li t1, 0
    li t2, 10
init_loop:
    bge t1, t2, init_done
    slli t3, t1, 2
    add t4, t0, t3
    sw zero, 0(t4)
    addi t1, t1, 1
    j init_loop
init_done:

    # Запрос имени файла и чтение данных
    la s1, array_a
    read_array_from_file(s1)    # Чтение массива из файла
    
    bnez a1, _invalid          # Проверка на ошибку
    mv s0, a0                  # s0 = N (количество элементов)
    
    # Печать исходного массива
    print_str(label_a)
    print_array(s0, s1)
    
    # Перестановка элементов
    la s2, array_b
    rearrange_arrays(s0, s1, s2)
    
    # Печать результирующего массива
    print_str(label_b)
    print_array(s0, s2)
    
    exit()

_invalid:
    print_str(main_error_msg)
    exit()