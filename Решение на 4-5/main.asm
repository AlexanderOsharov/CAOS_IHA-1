.include "io_macros.asm"
.include "array_io_macros.asm"
.include "rearrange_macros.asm"

.data
    array_a: .word 0 : 10
    array_b: .word 0 : 10
    input_buffer: .space 32

    prompt_n:        .asciz "Enter N (1-10): "
    prompt_a_prefix: .asciz "Enter A["
    prompt_a_suffix: .asciz "]: "
    error_msg:       .asciz "Error: N must be between 1 and 10.\n"
    label_a:         .asciz "Array A: "
    label_b:         .asciz "Array B: "

.text
.globl main

main:
    print_str(prompt_n)
    jal ra, _read_int_safe
    bnez a1, _invalid
    mv s3, a0

    # Валидация:
    li t0, 1
    blt s3, t0, _invalid
    li t0, 10
    bgt s3, t0, _invalid

    # Цикл:
    la s0, array_a
    li s2, 0
.input_loop:
    beq s2, s3, .input_done

    print_str(prompt_a_prefix)
    print_int(s2)
    print_str(prompt_a_suffix)

    jal ra, _read_int_safe
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

# ------------------------------------------------------------
# Конвертация
# ------------------------------------------------------------
_read_int_safe:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)

    li a7, 8
    la a0, input_buffer
    li a1, 32
    ecall

    la s0, input_buffer
    li s1, 0
    li t0, 0

.skip_spaces:
    lb t1, 0(s0)
    li t2, ' '
    beq t1, t2, .next_char
    li t2, 9
    beq t1, t2, .next_char
    li t2, 10
    beq t1, t2, .invalid
    li t2, 13
    beq t1, t2, .invalid
    li t2, 0
    beq t1, t2, .invalid
    j .check_sign

.next_char:
    addi s0, s0, 1
    j .skip_spaces

.check_sign:
    lb t1, 0(s0)
    li t2, '-'
    beq t1, t2, .handle_neg
    li t2, '+'
    beq t1, t2, .skip_sign
    j .parse_digits

.handle_neg:
    li t0, 1
    addi s0, s0, 1
    j .parse_digits

.skip_sign:
    addi s0, s0, 1

.parse_digits:
    lb t1, 0(s0)
    li t2, 10
    beq t1, t2, .done
    li t2, 13
    beq t1, t2, .done
    li t2, 0
    beq t1, t2, .done

    li t2, '0'
    blt t1, t2, .invalid
    li t2, '9'
    bgt t1, t2, .invalid

    li t2, 10
    mul s1, s1, t2
    li t2, '0'
    sub t3, t1, t2
    add s1, s1, t3

    addi s0, s0, 1
    j .parse_digits

.done:
    beqz t0, .positive
    neg s1, s1
.positive:
    mv a0, s1
    li a1, 0
    j .exit_parse

.invalid:
    li a0, 0
    li a1, 1

.exit_parse:
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16
    jr ra