# io_macros.asm
# Базовые макросы ввода-вывода для RARS (RISC-V)

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

.macro exit()
    li a7, 10
    ecall
.end_macro
