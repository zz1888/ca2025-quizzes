bf16_add:
    li t6,0xFF
    bne t2,t6,check_exp_b
    bnez t4,return_a
check_expb:
    bne t3,t6,return_a
    bnez t5,return_b
    beq t0,t1,return_b
    li a0, 0x7FC0
    jr ra
return_b:
    mv a0,a1
    jr ra
return_a:
    mv a0,a0
    jr ra
check_exp_b: 
    bne t3,t6,check_expa_manta
    mv a0,a1
    jr ra
check_expa_manta:
    bnez t2,check_expb_mantb
    bnez t4,check_expb_mantb
    mv a0,a1
    jr ra
check_expb_mantb:
    bnez t3,check_zero_expa
    bnez t5,check_zero_expa
    mv a0,a0
    jr ra
check_zero_expa:
    beqz t2,check_zero_expb
    ori t4,t4,0x80
check_zero_expb:
    beqz t3,next
    ori t5,t5,0x80
next:
    sub s0,t2,t3  #s0=exp_diff
    beqz s0,equal
    blt s0,x0,expa_smaller
expa_bigger:
    mv s1,t2        
    li t6,8
    bgt s0,t6,return_a
    srl t5,t5,s0
    j align_done
expa_smaller: 
    mv s1, t3
    li t6,-8
    blt s0,t6,return_b
    sub s0,x0,s0
    srl t4,t4,s0
    j align_done
equal:
    mv s1,t2 #s1=result_exp
align_done:
    beq t0,t1,same_sign
    bge t4,t5,mant_bigger
    mv s2,t1
    sub s3,t5,t4
    beqz s3,result_mant
    andi t6,s3,0x80
    bnez t6,normalize_done
while:
    slli s3,s3,1             # mant �����@��
    addi s1,s1,-1            # exp--
    ble s1,x0,return_zero    # exp <= 0 -> return 0
    andi t6,s3,0x80          # �A���ˬd leading 1
    beqz t6,while            # �Y���L leading 1 -> �~���j��
normalize_done:
    slli s2,s2,15
    andi s1,s1,0xFF
    slli s1,s1,7
    andi s3,s3,0x7F
    or a0,s2,s1
    or a0,a0,s3
    jr ra
result_mant:
    li t6,0x0000
    mv a0,t6
    jr ra
mant_bigger:
    mv s2,t0
    sub s3,t4,t5
    beqz s3,result_mant
    andi t6,s3,0x80
    bnez t6,normalize_done
    j while
same_sign:
    mv s2,t0 #result_sign
    add s3,t4,t5 #s3=result_mant
    andi s4,s3,0x100 #S4=result_mant&&0x100
    beqz s4, build_result    # �L�i���N���� build ���G
    srli s3, s3, 1           # mantissa 
    addi s1, s1, 1           # exponent +1
    li t6, 0xFF
    bge s1, t6, return_out   # �Y overflow�A���h ��Inf
build_result:
    andi s1,s1,0xFF
    andi s3, s3, 0x7F
    slli s1, s1, 7
    or s1, s1, s3
    slli s2, s2, 15
    or a0, s2, s1
    jr ra
return_out:
    li t6,0x7F80
    slli s2,s2,15         # sign << 15
    or a0,s2,t6           # �զX���G
    jr ra
return_zero:
    li t6,0x0000
    mv a0,t6
    jr ra
