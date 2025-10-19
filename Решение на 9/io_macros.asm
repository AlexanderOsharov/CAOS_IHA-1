# io_macros.asm
# Расширенная библиотека макросов для RISC-V RARS

# Базовые макросы ввода-вывода
.macro print_str(%str)
    li a7, 4
    la a0, %str
    ecall
.end_macro

.macro print_int(%reg)
    li a7, 1
    mv a0, %reg
    ecall
.end_macro

.macro print_char(%reg)
    li a7, 11
    mv a0, %reg
    ecall
.end_macro

.macro read_int()
    li a7, 5
    ecall
.end_macro

.macro read_str(%buffer, %size)
    li a7, 8
    la a0, %buffer
    li a1, %size
    ecall
.end_macro

.macro exit()
    li a7, 10
    ecall
.end_macro

# Макросы-обертки над подпрограммами
.macro safe_read_int()
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, utils_read_int_safe
    lw ra, 0(sp)
    addi sp, sp, 4
.end_macro

.macro validate_n(%n_reg)
    mv a0, %n_reg
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, utils_validate_n
    lw ra, 0(sp)
    addi sp, sp, 4
.end_macro