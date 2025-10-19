# array_io_macros.asm
# Расширенная библиотека макросов для работы с массивами

.macro print_array(%n_reg, %addr_reg)
    mv a0, %n_reg
    mv a1, %addr_reg
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, print_array_proc
    lw ra, 0(sp)
    addi sp, sp, 4
.end_macro

.macro input_array(%n_reg, %addr_reg)
    mv a0, %n_reg
    mv a1, %addr_reg
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, input_array_proc
    lw ra, 0(sp)
    addi sp, sp, 4
.end_macro

.macro init_test_array(%addr_reg, %start_val, %step_val, %count_val)
    mv a0, %addr_reg
    li a1, %start_val
    li a2, %step_val  
    li a3, %count_val
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, init_test_array_proc
    lw ra, 0(sp)
    addi sp, sp, 4
.end_macro

.macro rearrange_arrays(%n_reg, %src_reg, %dst_reg)
    mv a0, %n_reg
    mv a1, %src_reg
    mv a2, %dst_reg
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, rearrange_arrays_proc
    lw ra, 0(sp)
    addi sp, sp, 4
.end_macro

.macro read_array_from_file(%addr_reg)
    mv a0, %addr_reg
    addi sp, sp, -4
    sw ra, 0(sp)
    jal ra, read_array_from_file_proc
    lw ra, 0(sp)
    addi sp, sp, 4
.end_macro