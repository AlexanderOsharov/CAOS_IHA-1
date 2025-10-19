# rearrange_macros.asm — перестановка: сначала элементы с чётными индексами, затем нечётные
# %n_reg    — регистр с длиной массива (N)
# %src_reg  — регистр с адресом исходного массива A
# %dst_reg  — регистр с адресом целевого массива B

.macro rearrange_arrays(%n_reg, %src_reg, %dst_reg)
    li    t0, 0       # write_offset (в байтах)
    li    t1, 0       # i = 0 (чётный индекс)
    mv    t6, %dst_reg# t6 хранит базовый адрес B

.even_loop_array:
    bge   t1, %n_reg, .odd_pass_array
    slli  t2, t1, 2        # t2 = i * 4
    add   t3, %src_reg, t2 # t3 = адрес A[i]
    lw    t4, 0(t3)        # t4 = A[i]
    add   t5, t6, t0       # t5 = адрес B + write_offset
    sw    t4, 0(t5)        # B[...] = A[i]
    addi  t0, t0, 4
    addi  t1, t1, 2
    j     .even_loop_array

.odd_pass_array:
    li    t1, 1

.odd_loop_array:
    bge   t1, %n_reg, .done_array
    slli  t2, t1, 2
    add   t3, %src_reg, t2
    lw    t4, 0(t3)
    add   t5, t6, t0
    sw    t4, 0(t5)
    addi  t0, t0, 4
    addi  t1, t1, 2
    j     .odd_loop_array

.done_array:
.end_macro
