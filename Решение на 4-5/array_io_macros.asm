# Макрос для печати массива целых чисел

# %n_reg   — регистр с количеством элементов (N)
# %addr_reg — регистр с базовым адресом массива
.macro print_array(%n_reg, %addr_reg)
    li t0, 0                        # t0 = счётчик индекса (i = 0)
.print_loop_array:
    beq t0, %n_reg, .print_nl_array # Если i == N, завершить цикл

    slli t1, t0, 2                  # t1 = i * 4 (смещение в байтах)
    add t2, %addr_reg, t1           # t2 = адрес элемента массива[i]
    lw t3, 0(t2)                    # t3 = значение массива[i]
    print_int(t3)                   # Вывод значения

    li t4, ' '                      # Пробел как разделитель
    print_char(t4)

    addi t0, t0, 1                  # i++
    j .print_loop_array

.print_nl_array:
    li t4, '\n'                     # Перевод строки после массива
    print_char(t4)
.end_macro