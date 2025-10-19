# Макрос для перегруппировки массива:
# сначала элементы с чётными индексами (0, 2, 4, ...),
# затем — с нечётными (1, 3, 5, ...)

# %n_reg    — регистр с длиной массива (N)
# %src_reg  — регистр с адресом исходного массива A
# %dst_reg  — регистр с адресом целевого массива B
.macro rearrange_arrays(%n_reg, %src_reg, %dst_reg)
    li t0, 0        # t0 = смещение записи в байтах (write_offset)
    li t1, 0        # t1 = индекс i для чётных элементов (начинаем с 0)

.even_loop_array:
    bge t1, %n_reg, .odd_pass_array  # Если i >= N, переходим к нечётным
    slli t2, t1, 2                   # t2 = i * 4 (смещение)
    add t3, %src_reg, t2             # t3 = адрес A[i]
    lw t4, 0(t3)                     # t4 = A[i]
    add t5, %dst_reg, t0             # t5 = адрес B[write_offset/4]
    sw t4, 0(t5)                     # Сохранить A[i] в B
    addi t0, t0, 4                   # Увеличить смещение на 4 байта
    addi t1, t1, 2                   # Переход к следующему чётному индексу
    j .even_loop_array

.odd_pass_array:
    li t1, 1        # t1 = индекс i для нечётных элементов (начинаем с 1)

.odd_loop_array:
    bge t1, %n_reg, .done_array      # Если i >= N, завершить
    slli t2, t1, 2                   # t2 = i * 4
    add t3, %src_reg, t2             # t3 = адрес A[i]
    lw t4, 0(t3)                     # t4 = A[i]
    add t5, %dst_reg, t0             # t5 = адрес в B для записи
    sw t4, 0(t5)                     # Сохранить A[i] в B
    addi t0, t0, 4                   # Смещение +4
    addi t1, t1, 2                   # Следующий нечётный индекс
    j .odd_loop_array

.done_array:
    # Макрос завершён; результат в %dst_reg
.end_macro