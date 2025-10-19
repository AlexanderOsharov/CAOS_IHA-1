.macro rearrange_arrays(%n_reg, %src_reg, %dst_reg)
    li t0, 0        # write_offset (bytes)
    li t1, 0        # i = 0 (even)

.even_loop_array:
    bge t1, %n_reg, .odd_pass_array
    slli t2, t1, 2
    add t3, %src_reg, t2     # адрес A[i]
    lw t4, 0(t3)             # значение A[i]
    add t5, %dst_reg, t0     # адрес B[write]
    sw t4, 0(t5)             # сохранить
    addi t0, t0, 4
    addi t1, t1, 2
    j .even_loop_array

.odd_pass_array:
    li t1, 1
.odd_loop_array:
    bge t1, %n_reg, .done_array
    slli t2, t1, 2
    add t3, %src_reg, t2
    lw t4, 0(t3)
    add t5, %dst_reg, t0
    sw t4, 0(t5)
    addi t0, t0, 4
    addi t1, t1, 2
    j .odd_loop_array
.done_array:
.end_macro