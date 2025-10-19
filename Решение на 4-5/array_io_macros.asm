.macro print_array(%n_reg, %addr_reg)
    li t0, 0
.print_loop_array:
    beq t0, %n_reg, .print_nl_array

    slli t1, t0, 2
    add t2, %addr_reg, t1    # t2 = адрес элемента
    lw t3, 0(t2)             # t3 = значение
    print_int(t3)

    li t4, ' '
    print_char(t4)

    addi t0, t0, 1
    j .print_loop_array
.print_nl_array:
    li t4, '\n'
    print_char(t4)
.end_macro