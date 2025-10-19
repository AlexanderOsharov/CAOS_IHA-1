.include "io_macros.asm"
.include "array_io_macros.asm"
.include "rearrange_macros.asm"

.data
    array_a: .word 0 : 10          # Исходный массив A (макс. 10 элементов)
    array_b: .word 0 : 10          # Результирующий массив B (макс. 10 элементов)
    input_buffer: .space 32        # Буфер для чтения строки ввода

    prompt_n:        .asciz "Enter N (1-10): "
    prompt_a_prefix: .asciz "Enter A["
    prompt_a_suffix: .asciz "]: "
    error_msg:       .asciz "Error: N must be between 1 and 10.\n"
    label_a:         .asciz "Array A: "
    label_b:         .asciz "Array B: "

.text
.globl main

main:
    # Запрос значения N
    print_str(prompt_n)
    jal ra, _read_int_safe         # Вызов безопасного чтения целого числа
    bnez a1, _invalid              # Если a1 != 0 → ошибка ввода
    mv s3, a0                      # Сохраняем N в s3 (длина массива)

    # Валидация: N должно быть в диапазоне [1, 10]
    li t0, 1
    blt s3, t0, _invalid           # N < 1 → недопустимо
    li t0, 10
    bgt s3, t0, _invalid           # N > 10 → недопустимо

    # Инициализация цикла ввода элементов массива A
    la s0, array_a                 # s0 = базовый адрес массива A
    li s2, 0                       # s2 = счётчик индекса (i = 0)

.input_loop:
    beq s2, s3, .input_done        # Если i == N, завершить ввод

    # Вывод приглашения: "Enter A[i]: "
    print_str(prompt_a_prefix)
    print_int(s2)
    print_str(prompt_a_suffix)

    jal ra, _read_int_safe         # Чтение A[i]
    bnez a1, _invalid              # Проверка корректности ввода

    # Сохранение значения в массив A[i]
    slli t0, s2, 2                 # t0 = i * 4 (смещение в байтах)
    add t1, s0, t0                 # t1 = адрес A[i]
    sw a0, 0(t1)                   # Запись значения в память

    addi s2, s2, 1                 # i++
    j .input_loop

.input_done:
    # Вывод исходного массива A
    print_str(label_a)
    print_array(s3, s0)            # Печать N элементов, начиная с адреса s0

    # Перегруппировка элементов: чётные индексы → начало, нечётные → конец
    la s1, array_b                 # s1 = базовый адрес массива B
    rearrange_arrays(s3, s0, s1)   # Вызов макроса перегруппировки

    # Вывод результирующего массива B
    print_str(label_b)
    print_array(s3, s1)

    exit()                         # Завершение программы

_invalid:
    print_str(error_msg)
    exit()

# ------------------------------------------------------------
# Безопасное чтение целого числа из stdin
# Вход: ничего
# Выход: a0 = прочитанное число (если успешно), a1 = 0 (успех) или 1 (ошибка)
# Использует input_buffer для хранения строки
#
# Причину написания чтения целого числа в основном файле привёл в ТГ
# ------------------------------------------------------------
_read_int_safe:
    # Сохранение вызываемо-сохраняемых регистров
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)
    sw s2, 0(sp)

    # Системный вызов: чтение строки (a7=8)
    li a7, 8                       # Код системного вызова для чтения строки
    la a0, input_buffer            # Адрес буфера
    li a1, 32                      # Макс. длина строки
    ecall                          # Вызов ОС

    # Инициализация парсера
    la s0, input_buffer            # s0 = указатель на текущий символ
    li s1, 0                       # s1 = накопленное значение числа
    li t0, 0                       # t0 = флаг отрицательного числа (0 = положительное, 1 = отрицательное)

.skip_spaces:
    # Пропуск пробельных символов (пробел, табуляция)
    lb t1, 0(s0)                   # Загрузка текущего символа
    li t2, ' '
    beq t1, t2, .next_char
    li t2, 9                       # ASCII табуляции
    beq t1, t2, .next_char
    # Если встретился конец строки или нуль-терминатор — ошибка
    li t2, 10                      # '\n'
    beq t1, t2, .invalid
    li t2, 13                      # '\r'
    beq t1, t2, .invalid
    li t2, 0                       # '\0'
    beq t1, t2, .invalid
    j .check_sign                  # Иначе проверяем знак

.next_char:
    addi s0, s0, 1                 # Переход к следующему символу
    j .skip_spaces

.check_sign:
    # Проверка наличия знака '+' или '-'
    lb t1, 0(s0)
    li t2, '-'
    beq t1, t2, .handle_neg        # Обработка отрицательного числа
    li t2, '+'
    beq t1, t2, .skip_sign         # Пропуск '+'
    j .parse_digits                # Начало парсинга цифр

.handle_neg:
    li t0, 1                       # Установка флага отрицательного числа
    addi s0, s0, 1                 # Пропуск символа '-'
    j .parse_digits

.skip_sign:
    addi s0, s0, 1                 # Пропуск символа '+'

.parse_digits:
    # Парсинг последовательности цифр
    lb t1, 0(s0)
    # Проверка завершения строки
    li t2, 10                      # '\n'
    beq t1, t2, .done
    li t2, 13                      # '\r'
    beq t1, t2, .done
    li t2, 0                       # '\0'
    beq t1, t2, .done

    # Проверка, что символ — цифра
    li t2, '0'
    blt t1, t2, .invalid           # Символ < '0' → недопустимо
    li t2, '9'
    bgt t1, t2, .invalid           # Символ > '9' → недопустимо

    # Обновление накопленного значения: s1 = s1 * 10 + (t1 - '0')
    li t2, 10
    mul s1, s1, t2                 # Умножение на 10
    li t2, '0'
    sub t3, t1, t2                 # Преобразование ASCII в цифру
    add s1, s1, t3                 # Добавление цифры

    addi s0, s0, 1                 # Переход к следующему символу
    j .parse_digits

.done:
    # Применение знака, если число отрицательное
    beqz t0, .positive             # Если t0 == 0 → положительное
    neg s1, s1                     # Отрицание значения
.positive:
    mv a0, s1                      # Результат в a0
    li a1, 0                       # Успех (ошибки нет)
    j .exit_parse

.invalid:
    li a0, 0                       # Возвращаем 0 при ошибке
    li a1, 1                       # Флаг ошибки

.exit_parse:
    # Восстановление сохранённых регистров
    lw ra, 12(sp)
    lw s0, 8(sp)
    lw s1, 4(sp)
    lw s2, 0(sp)
    addi sp, sp, 16
    jr ra