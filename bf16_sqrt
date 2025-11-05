bf16_sqrt:
    #t0=SIGN_A
    #t2=EXP_A
    #t4=MANT_A
    li t6,0xFF
    bne t2,t6,check_exp_mant_is_zero
    bnez t4,return_a
    bnez t0,return_nan
    j return_a
check_exp_mant_is_zero:
    bnez t2,check_sign
    bnez t4,check_sign
    j return_zero
check_sign:
    bnez t0,return_nan
check_exp:
    beqz t2,return_zero
conti5:
    addi s5,t2,-127 #s5=e
    li s6,0 #s6=new_exp
    ori s7,t4,0x80 #s7=m
if:
    andi t6,s5,1
    beqz t6,else_if
    slli s7,s7,1
    addi t6,s5,-1
    srli t6,t6,1
    addi s6,t6,127
    j conti6
else_if:
    srli t6,s5,1
    addi s6,t6,127
conti6:
    li s8,90  #s8=low
    li s9,256 #s9=high
    li s10,128 #s10=result
    ble s8,s9,while_loop
    j if_2
while_loop:
    add s1,s8,s9  #s1=mid
    srli s1,s1,1
# ===== mul s3 = s1 * s1 =====
    li   s3, 0
    mv   t6, s1
    mv   t3, s1        
mul_sqrt_loop:
    beqz t6, mul_sqrt_done
    andi t0, t6, 1
    beqz t0, skip_add_sqrt
    add  s3, s3, t3
skip_add_sqrt:
    slli t3, t3, 1
    srli t6, t6, 1
    j    mul_sqrt_loop
mul_sqrt_done:
# ===== div s3 /= 128 =====
    li t0,0
    mv t1,s3
    li t2,128
div_emul_loop:
    blt t1,t2,div_emul_end
    sub t1,t1,t2
    addi t0,t0,1
    j div_emul_loop
div_emul_end:
    mv s3,t0
    bgt s3,s7,else_if_2
    mv s10,s1
    addi s8,s1,1
    ble s8,s9,while_loop
    j if_2
else_if_2:
    addi s9,s1,-1
    ble s8,s9,while_loop
if_2:
    li t6,256
    blt s10,t6,else_if3
    srli s10,s10,1
    addi s6,s6,1
    j final_2
else_if3:
    li t6,128
    bge s10,t6,final_2  
    li t6,1
    blt s6,t6,final_2
while_loop2:
    slli s10,s10,1
    addi s6,s6,-1
    li t6,128
    bge s10,t6,final_2   
    li t6,1
    ble s6,t6,final_2
    j while_loop2
final_2:
    andi s0,s10,0x7F  #s11=new_mant
    li t6,0xFF
    bge s6,t6,final_if1
    blez s6,return_zero
    andi a0,s6,0xFF
    slli a0,a0,7
    or a0,a0,s0
    jr ra
final_if1:
    li a0,0x7F80
    mv a0,a0
    jr ra
return_nan:
    li a0, 0x7FC0
    jr ra
