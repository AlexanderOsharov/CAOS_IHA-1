# array_procedures.asm
# Подпрограммы для работы с массивами

.data
input_prompt_prefix: .asciz "Enter A["
input_prompt_suffix: .asciz "]: "

.text
.globl print_array_proc, input_array_proc, init_test_array_proc, rearrange_arrays_proc

# ------------------------------------------------------------
# void print_array_proc(int n, int* array)
# Вход: a0 = n, a1 = адрес массива
# Выход: ничего (печатает массив)
# ------------------------------------------------------------
print_array_proc:
    addi sp, sp, -20
    sw ra, 16(sp)
    sw s0, 12(sp)  # n
    sw s1, 8(sp)   # адрес массива
    sw s2, 4(sp)   # i
    sw s3, 0(sp)   # временные вычисления
    
    mv s0, a0      # n
    mv s1, a1      # адрес массива
    li s2, 0       # i = 0
    
print_loop:
    bge s2, s0, print_done
    
    # Вычисление адреса array[i]
    slli s3, s2, 2
    add s3, s1, s3
    lw a0, 0(s3)
    
    # Печать элемента
    li a7, 1
    ecall
    
    # Печать пробела (кроме последнего элемента)
    addi t0, s2, 1
    bge t0, s0, no_space
    li a0, ' '
    li a7, 11
    ecall
no_space:
    
    addi s2, s2, 1
    j print_loop

print_done:
    # Печать новой строки
    li a0, '\n'
    li a7, 11
    ecall
    
    lw ra, 16(sp)
    lw s0, 12(sp)
    lw s1, 8(sp)
    lw s2, 4(sp)
    lw s3, 0(sp)
    addi sp, sp, 20
    jr ra

# ------------------------------------------------------------
# void input_array_proc(int n, int* array)
# Вход: a0 = n, a1 = адрес массива
# Выход: заполненный массив
# ------------------------------------------------------------
input_array_proc:
    addi sp, sp, -24
    sw ra, 20(sp)
    sw s0, 16(sp)  # n
    sw s1, 12(sp)  # адрес массива
    sw s2, 8(sp)   # i
    sw s3, 4(sp)   # временные вычисления
    sw s4, 0(sp)   # значение
    
    mv s0, a0      # n
    mv s1, a1      # адрес массива
    li s2, 0       # i = 0

input_loop:
    bge s2, s0, input_done
    
    # Печать приглашения
    la a0, input_prompt_prefix
    li a7, 4
    ecall
    
    mv a0, s2
    li a7, 1
    ecall
    
    la a0, input_prompt_suffix
    li a7, 4
    ecall
    
    # Безопасный ввод
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, utils_read_int_safe
    lw ra, 0(sp)
    addi sp, sp, 4
    
    bnez a1, input_error
    
    mv s4, a0      # сохранение значения
    
    # Сохранение в массив
    slli s3, s2, 2
    add s3, s1, s3
    sw s4, 0(s3)
    
    addi s2, s2, 1
    j input_loop

input_error:
    # В случае ошибки заполняем нулями оставшиеся элементы
    mv a0, zero
complete_zeros:
    bge s2, s0, input_done
    slli s3, s2, 2
    add s3, s1, s3
    sw zero, 0(s3)
    addi s2, s2, 1
    j complete_zeros

input_done:
    lw ra, 20(sp)
    lw s0, 16(sp)
    lw s1, 12(sp)
    lw s2, 8(sp)
    lw s3, 4(sp)
    lw s4, 0(sp)
    addi sp, sp, 24
    jr ra

# ------------------------------------------------------------
# void init_test_array_proc(int* array, int start, int step, int count)
# Вход: a0 = адрес массива, a1 = начальное значение, a2 = шаг, a3 = количество
# Выход: заполненный массив арифметической прогрессией
# ------------------------------------------------------------
init_test_array_proc:
    addi sp, sp, -24
    sw ra, 20(sp)
    sw s0, 16(sp)  # адрес массива
    sw s1, 12(sp)  # текущее значение
    sw s2, 8(sp)   # шаг
    sw s3, 4(sp)   # количество
    sw s4, 0(sp)   # i
    
    mv s0, a0      # адрес массива
    mv s1, a1      # начальное значение
    mv s2, a2      # шаг
    mv s3, a3      # количество
    li s4, 0       # i = 0

init_loop:
    bge s4, s3, init_done
    
    # Сохранение текущего значения
    slli t0, s4, 2
    add t0, s0, t0
    sw s1, 0(t0)
    
    # Увеличение значения
    add s1, s1, s2
    addi s4, s4, 1
    j init_loop

init_done:
    lw ra, 20(sp)
    lw s0, 16(sp)
    lw s1, 12(sp)
    lw s2, 8(sp)
    lw s3, 4(sp)
    lw s4, 0(sp)
    addi sp, sp, 24
    jr ra

# ------------------------------------------------------------
# void rearrange_arrays_proc(int n, int* src, int* dst)
# Вход: a0 = n, a1 = src, a2 = dst
# Выход: заполненный массив dst
# ------------------------------------------------------------
rearrange_arrays_proc:
    addi sp, sp, -28
    sw ra, 24(sp)
    sw s0, 20(sp)  # n
    sw s1, 16(sp)  # src
    sw s2, 12(sp)  # dst
    sw s3, 8(sp)   # write_offset
    sw s4, 4(sp)   # i
    sw s5, 0(sp)   # временные вычисления
    
    mv s0, a0      # n
    mv s1, a1      # src
    mv s2, a2      # dst
    li s3, 0       # write_offset (в байтах)
    
    # Четные индексы
    li s4, 0       # i = 0
even_loop:
    bge s4, s0, odd_start
    
    # Чтение A[i]
    slli s5, s4, 2
    add s5, s1, s5
    lw t0, 0(s5)
    
    # Запись в B[write_offset]
    add t1, s2, s3
    sw t0, 0(t1)
    
    addi s3, s3, 4
    addi s4, s4, 2
    j even_loop

odd_start:
    # Нечетные индексы
    li s4, 1
odd_loop:
    bge s4, s0, rearrange_done
    
    # Чтение A[i]
    slli s5, s4, 2
    add s5, s1, s5
    lw t0, 0(s5)
    
    # Запись в B[write_offset]
    add t1, s2, s3
    sw t0, 0(t1)
    
    addi s3, s3, 4
    addi s4, s4, 2
    j odd_loop

rearrange_done:
    lw ra, 24(sp)
    lw s0, 20(sp)
    lw s1, 16(sp)
    lw s2, 12(sp)
    lw s3, 8(sp)
    lw s4, 4(sp)
    lw s5, 0(sp)
    addi sp, sp, 28
    jr ra