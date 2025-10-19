# array_io_macros.asm — печать массива (не клобберит адресный регистр)
# %n_reg   — регистр с количеством элементов (N)
# %addr_reg — регистр с базовым адресом массива

.macro print_array(%n_reg, %addr_reg)
    li    t0, 0              # i = 0
    mv    t6, %addr_reg      # t6 = базовый адрес (сохраняем в t-регистр)

.print_loop_array:
    beq   t0, %n_reg, .print_nl_array

    slli  t1, t0, 2          # t1 = i * 4
    add   t2, t6, t1         # t2 = base + offset
    lw    t3, 0(t2)          # t3 = array[i]

    print_int(t3)            # печать элемента (ecall использует a0)
    li    t4, ' '
    print_char(t4)           # печать пробела

    addi  t0, t0, 1
    j     .print_loop_array

.print_nl_array:
    li    t4, '\n'
    print_char(t4)
.end_macro
