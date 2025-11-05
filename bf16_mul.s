bf16_mul:
    xor s0,t0,t1    #s0 is result sign
    li t6, 0xFF
check_a_inf:
    bne t2, t6, check_b
    bnez t4,return_a
    beq t3,t6,check_nan1 ########################
    j bb
check_nan1:   ############################
    bnez t5,return_nan ##########################
bb:
    bnez t3,check_a_inf_done
    bnez t5,check_a_inf_done
    j return_nan
check_a_inf_done:
    slli s0,s0,15
    li t6,0x7F80
    or s0,s0,t6
    mv a0,s0
    jr ra
check_b:
    li t6, 0xFF
    bne t3,t6,check_zero
    bnez t5,return_b
    bnez t2,check_b_inf_done
    bnez t4,check_b_inf_done
    li t6,0x7FC0
    mv a0,t6
    jr ra
check_b_inf_done:
    slli s0,s0,15
    li t6,0x7F80
    or s0,s0,t6
    mv a0,s0
    jr ra
check_zero:
    # if ((!exp_a&&!mant_a) || (!exp_b&&!mant_b))
    beqz t2,check_a_zero
    beqz t3,check_b_zero
    j conti
check_a_zero:
    beqz t4,zero_done
    j conti
check_b_zero:
    beqz t5,zero_done
    j conti
zero_done:
    slli s0,s0,15
    mv a0,s0
    jr ra
conti:
    li s5,0  ### s5 is exp_adjust
    bnez t2,expa_not_if    #if(!expa)
whiles_a:
    li t6,0x80
    and t6,t4,t6
    bnez t6,set_expa
    slli t4,t4,1
    addi s5,s5,-1
    j whiles_a
set_expa:
    li t2,1
    j check_expb_zero
expa_not_if:
    ori t4,t4,0x80
    j check_expb_zero
check_expb_zero:
    bnez t3,expb_not_if
whiles_b:
    li t6,0x80
    and t6,t5,t6
    bnez t6,set_expb
    slli t5,t5,1
    addi s5,s5,-1
    j whiles_b
set_expb:
    li t3,1
    j conti2
expb_not_if:
    ori t5,t5,0x80
    j conti2
conti2: 
    #s3=result_mant
    li   s3, 0           # s3 = result_mant = 0
    mv   t6, t5          # t6 = multiplier
    mv   s7, t4          # s7 = multiplicand
mul_mant_loop:
    beqz t6, mul_mant_done   
    andi s8, t6, 1       
    beqz s8, skip_add_mant   
    add  s3, s3, s7          
skip_add_mant:
    slli s7, s7, 1           
    srli t6, t6, 1           
    j    mul_mant_loop
mul_mant_done:
    add s1,t2,t3  #s1=result_exp
    addi s1,s1,-127
    add s1,s1,s5
check_resulit_mant:
    li t6,0x8000
    and t6,s3,t6
    beqz t6,set_result_mant
    srli s3,s3,8
    li t6,0x7F
    and s3,s3,t6
    addi s1,s1,1
    j check_result_exp
set_result_mant:
    srli s3,s3,7
    li t6,0x7F
    and s3,s3,t6
    j check_result_exp
check_result_exp:
    li t6,0xFF
    blt s1,t6,check_result_exp_zero
    li t6,0x7F80
    slli s0,s0,15
    or s0,s0,t6
    mv a0,s0
    jr ra   
check_result_exp_zero:
    bgt s1,x0,output
    li t6,-6
    blt s1,t6,returns
    li t6,1
    sub t6,t6,s1
    srl s3,s3,t6
    li s1,0
    j output
returns:
    slli s0,s0,15
    mv a0,s0
    jr ra
output:
    slli s0,s0,15
    li t6,0xFF
    and s1,s1,t6
    slli s1,s1,7
    li t6,0x7F
    and s3,s3,t6
    or a0,s0,s1
    or a0,a0,s3
    jr ra
