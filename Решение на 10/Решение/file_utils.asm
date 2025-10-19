# file_utils.asm
# Подпрограммы для чтения данных из файла

.data
filename_buffer: .space 64
file_buffer:    .space 256
file_error_msg: .asciz "Error: Cannot open file or invalid format\n"
file_prompt_filename: .asciz "Enter filename: "

.text
.globl read_array_from_file_proc, parse_file_data_proc

# ------------------------------------------------------------
# int read_array_from_file_proc(int* array)
# Вход: a0 = адрес массива для заполнения
# Выход: a0 = количество элементов (N), a1 = 0 (успех) или 1 (ошибка)
# ------------------------------------------------------------
read_array_from_file_proc:
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)  # адрес массива
    sw s1, 20(sp)  # file descriptor / временные
    sw s2, 16(sp)  # количество прочитанных байт
    sw s3, 12(sp)  # указатель в file_buffer
    sw s4, 8(sp)   # количество элементов
    sw s5, 4(sp)   # текущий элемент
    
    mv s0, a0      # сохраняем адрес массива
    
    # ОЧИЩАЕМ БУФЕРЫ ПЕРЕД ИСПОЛЬЗОВАНИЕМ
    jal clear_buffers
    
    # Запрашиваем имя файла
    la a0, file_prompt_filename
    li a7, 4
    ecall
    
    # Читаем имя файла
    la a0, filename_buffer
    li a1, 64
    li a7, 8
    ecall
    
    # Убираем символ новой строки из имени файла
    la s3, filename_buffer
remove_newline_file:
    lb t0, 0(s3)
    beqz t0, open_file_label
    li t1, 10
    beq t0, t1, found_newline_file
    addi s3, s3, 1
    j remove_newline_file
found_newline_file:
    sb zero, 0(s3)  # заменяем \n на 0
    
open_file_label:
    # Открываем файл
    la a0, filename_buffer
    li a7, 1024     # open file
    li a1, 0        # read-only
    ecall
    
    blt a0, zero, file_error_proc
    mv s1, a0       # сохраняем file descriptor
    
    # Читаем содержимое файла
    mv a0, s1
    la a1, file_buffer
    li a2, 256
    li a7, 63       # read file
    ecall
    
    mv s2, a0       # сохраняем количество прочитанных байт
    
    # Закрываем файл
    mv a0, s1
    li a7, 57       # close file
    ecall
    
    # Добавляем нуль-терминатор в конец буфера
    la t0, file_buffer
    add t1, t0, s2
    sb zero, 0(t1)
    
    # Парсим данные из файла
    la a0, file_buffer
    mv a1, s0
    jal ra, parse_file_data_proc
    mv s4, a0       # количество элементов
    mv s5, a1       # флаг ошибки
    
    bnez s5, parse_error_proc
    
    # Проверяем валидность N
    mv a0, s4
    jal ra, utils_validate_n
    beqz a0, invalid_n_file
    
    # Успешное завершение
    mv a0, s4
    li a1, 0
    j exit_file_read

file_error_proc:
    la a0, file_error_msg
    li a7, 4
    ecall
    li a0, 0
    li a1, 1
    j exit_file_read

parse_error_proc:
    la a0, file_error_msg
    li a7, 4
    ecall
    li a0, 0
    li a1, 1
    j exit_file_read

invalid_n_file:
    la a0, file_error_msg
    li a7, 4
    ecall
    li a0, 0
    li a1, 1

exit_file_read:
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    lw s5, 4(sp)
    addi sp, sp, 32
    jr ra

# ------------------------------------------------------------
# void clear_buffers()
# Очищает буферы filename_buffer и file_buffer
# ------------------------------------------------------------
clear_buffers:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)
    
    # Очищаем filename_buffer
    la s0, filename_buffer
    li s1, 64
    li s2, 0
clear_filename_loop:
    bge s2, s1, clear_file_buffer
    add t0, s0, s2
    sb zero, 0(t0)
    addi s2, s2, 1
    j clear_filename_loop
    
clear_file_buffer:
    # Очищаем file_buffer
    la s0, file_buffer
    li s1, 256
    li s2, 0
clear_file_loop:
    bge s2, s1, clear_done
    add t0, s0, s2
    sb zero, 0(t0)
    addi s2, s2, 1
    j clear_file_loop
    
clear_done:
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16
    jr ra

# ------------------------------------------------------------
# int parse_file_data_proc(char* buffer, int* array)
# Вход: a0 = адрес буфера с данными, a1 = адрес массива
# Выход: a0 = количество элементов, a1 = 0 (успех) или 1 (ошибка)
# ------------------------------------------------------------
parse_file_data_proc:
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)  # указатель в буфере
    sw s1, 16(sp)  # адрес массива
    sw s2, 12(sp)  # количество элементов (N)
    sw s3, 8(sp)   # текущее число
    sw s4, 4(sp)   # флаг отрицания
    sw s5, 0(sp)   # счетчик прочитанных элементов
    
    mv s0, a0      # буфер
    mv s1, a1      # массив
    li s5, 0       # счетчик прочитанных элементов
    li s2, -1      # N (будет установлено первым числом)
    
    # ДОБАВЛЯЕМ ПРОВЕРКУ НА ПУСТОЙ БУФЕР
    lb t0, 0(s0)
    beqz t0, parse_error_out_file  # если буфер пустой
    
parse_loop_file:
    # Пропускаем пробелы и переводы строк
    lb t0, 0(s0)
    beqz t0, parse_done_file  # конец строки
    
    li t1, ' '
    beq t0, t1, skip_char_file
    li t1, 10
    beq t0, t1, skip_char_file
    li t1, 13
    beq t0, t1, skip_char_file
    li t1, 9
    beq t0, t1, skip_char_file
    
    # Нашли начало числа
    li s3, 0       # текущее число
    li s4, 0       # флаг отрицания
    
    # Проверяем знак
    li t1, '-'
    bne t0, t1, check_plus_file
    li s4, 1
    addi s0, s0, 1
    j parse_digits_file
    
check_plus_file:
    li t1, '+'
    bne t0, t1, parse_digits_file
    addi s0, s0, 1
    
parse_digits_file:
    lb t0, 0(s0)
    beqz t0, save_number_file
    li t1, ' '
    beq t0, t1, save_number_file
    li t1, 10
    beq t0, t1, save_number_file
    li t1, 13
    beq t0, t1, save_number_file
    li t1, 9
    beq t0, t1, save_number_file
    
    # Проверяем, что это цифра
    li t1, '0'
    blt t0, t1, parse_error_out_file
    li t1, '9'
    bgt t0, t1, parse_error_out_file
    
    # Добавляем цифру к числу
    li t1, 10
    mul s3, s3, t1
    li t1, '0'
    sub t2, t0, t1
    add s3, s3, t2
    
    addi s0, s0, 1
    j parse_digits_file

save_number_file:
    # Применяем знак
    beqz s4, positive_num_file
    neg s3, s3
    
positive_num_file:
    # Если это первое число - это N
    li t0, -1
    bne s2, t0, not_first_number
    mv s2, s3       # сохраняем N
    
    # Проверяем, что N в допустимом диапазоне
    li t0, 1
    blt s2, t0, parse_error_out_file
    li t0, 10
    bgt s2, t0, parse_error_out_file
    
    j continue_parsing
    
not_first_number:
    # Проверяем, не превысили ли размер массива
    li t0, 10
    bge s5, t0, parse_done_file
    
    # Сохраняем число в массив
    slli t0, s5, 2
    add t0, s1, t0
    sw s3, 0(t0)
    addi s5, s5, 1
    
continue_parsing:
    # Проверяем, прочитали ли все элементы
    blt s5, s2, parse_loop_file

parse_done_file:
    # Проверяем, что прочитали правильное количество элементов
    bne s5, s2, parse_error_out_file
    mv a0, s2
    li a1, 0
    j exit_parse_file

skip_char_file:
    addi s0, s0, 1
    j parse_loop_file

parse_error_out_file:
    li a0, 0
    li a1, 1

exit_parse_file:
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 16(sp)
    lw s2, 12(sp)
    lw s3, 8(sp)
    lw s4, 4(sp)
    lw s5, 0(sp)
    addi sp, sp, 32
    jr ra