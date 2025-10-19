# utils.asm
# Подпрограммы: безопасное чтение целого и валидация N
# Экспортируемые имена имеют префикс utils_ чтобы избежать конфликтов

.data
input_buffer: .space 32

.text

# ------------------------------------------------------------
# int utils_read_int_safe()
# Вход: ничего (читает строку в input_buffer)
# Выход: a0 = прочитанное число, a1 = 0 (успех) или 1 (ошибка)
# ------------------------------------------------------------
.globl utils_read_int_safe
utils_read_int_safe:
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)   # указатель на строку
    sw s1, 20(sp)   # накопленное значение
    sw s2, 16(sp)   # флаг отрицания

    li a7, 8
    la a0, input_buffer
    li a1, 32
    ecall

    la s0, input_buffer
    li s1, 0
    li s2, 0

.skip_spaces:
    lb t0, 0(s0)
    li t1, ' '
    beq t0, t1, .next_char
    li t1, 9
    beq t0, t1, .next_char
    li t1, 10
    beq t0, t1, .invalid
    li t1, 13
    beq t0, t1, .invalid
    li t1, 0
    beq t0, t1, .invalid
    j .check_sign

.next_char:
    addi s0, s0, 1
    j .skip_spaces

.check_sign:
    lb t0, 0(s0)
    li t1, '-'
    beq t0, t1, .handle_neg
    li t1, '+'
    beq t0, t1, .skip_sign
    j .parse_digits

.handle_neg:
    li s2, 1
    addi s0, s0, 1
    j .parse_digits

.skip_sign:
    addi s0, s0, 1

.parse_digits:
    lb t0, 0(s0)
    li t1, 10
    beq t0, t1, .done
    li t1, 13
    beq t0, t1, .done
    li t1, 0
    beq t0, t1, .done

    li t1, '0'
    blt t0, t1, .invalid
    li t1, '9'
    bgt t0, t1, .invalid

    li t1, 10
    mul s1, s1, t1
    li t1, '0'
    sub t2, t0, t1
    add s1, s1, t2

    addi s0, s0, 1
    j .parse_digits

.done:
    beqz s2, .positive
    neg s1, s1
.positive:
    mv a0, s1
    li a1, 0
    j .exit

.invalid:
    li a0, 0
    li a1, 1

.exit:
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    addi sp, sp, 32
    jr ra

# ------------------------------------------------------------
# int utils_validate_n(int n)
# Вход: a0 = n
# Выход: a0 = 1 (корректно) или 0 (некорректно)
# ------------------------------------------------------------
.globl utils_validate_n
utils_validate_n:
    addi sp, sp, -8
    sw ra, 4(sp)
    sw s0, 0(sp)

    mv s0, a0
    li t0, 1
    blt s0, t0, .invalid_n
    li t0, 10
    bgt s0, t0, .invalid_n
    li a0, 1
    j .end_n
.invalid_n:
    li a0, 0
.end_n:
    lw ra, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 8
    jr ra
