bf16_div:
    xor s0,t0,t1 #s0 is result sign
    li t6,0xFF
    bne t3,t6,check_not_expb_and_mantb
    bnez t5,return_b
    li t6,0xFF
    beq t2,t6,check_nan2  ##################
    j dd
check_nan2:    ######################
    bnez t4,return_nan ###############
dd:
    bne t2,t6,returnss
    bnez t4,returnss
    li a0,0x7FC0
    jr ra
returnss:
    slli s0,s0,15
    mv a0,s0
    jr ra
check_not_expb_and_mantb:
    bnez t3,check_expaa
    bnez t5,check_expaa
    li t6,0xFF ####
    beq t2,t6,check_nan3   #######
    j cc   ####
check_nan3:  ####
    bnez t4,return_nan  ####
    j cc ####
cc:
    bnez t2,returnsss
    bnez t4,returnsss
    li a0,0x7FC0
    jr ra
returnsss:
    li t6,0x7F80
    slli s0,s0,15
    or a0,s0,t6
    jr ra
check_expaa:
    li t6,0xFF
    bne t2,t6,check_not_expa_and_manta
    bnez t4,return_a
    li t6,0x7F80
    slli s0,s0,15
    or a0,s0,t6
    jr ra
check_not_expa_and_manta:
    bnez t2,check_expaaa
    bnez t4,check_expaaa
    slli s0,s0,15
    mv a0,s0
    jr ra
check_expaaa:
    beqz t2,check_expbbb
    ori t4,t4,0x80
check_expbbb:
    beqz t3,contii
    ori t5,t5,0x80
contii:
    slli s1,t4,15   #s1=dividend
    mv s2,t5        #s2=diversor
    li s3,0         #s3=quotient
    li s4,0         #i=0
    li s5,16        #16
    li s8,15
for:
    bge s4,s5,conti3
    slli s3,s3,1
    sub s6,s8,s4   #(15 - i)
    sll s7,s2,s6
    bge s1,s7,for_if
    addi s4,s4,1
    j for
for_if:
    sub s1,s1,s7
    ori s3,s3,1
    addi s4,s4,1
    j for
conti3:
    sub s9,t2,t3    #s9=result_exp
    addi s9,s9,127
    bnez t2,check_expb1
    addi s9,s9,-1
check_expb1:
    bnez t3,check_quotient
    addi s9,s9,1
check_quotient:
    li t6,0x8000
    and t6,s3,t6
    beqz t6,else
    srli s3,s3,8
    j conti4
else:
    li s7,0x8000
    li s8,1
    and t6,s3,s7
    bnez t6,else_conti
    ble s9,s8,else_conti
while2:
    slli s3,s3,1
    addi s9,s9,-1
    and t6,s3,s7
    bnez t6,else_conti
    ble s9,s8,else_conti
    j while2
else_conti:
    srli s3,s3,8
conti4:
    andi s3,s3,0x7F
    li t6,0xFF
    blt s9,t6,check_result_le_zero
    li t6,0x7F80
    slli s0,s0,15
    or a0,s0,t6
    jr ra
check_result_le_zero:
    bgtz s9,final
    slli a0,s0,15
    jr ra
final:
    slli s0,s0,15
    li t6,0xFF
    and s9,s9,t6
    slli s9,s9,7
    li t6,0x7F
    and s3,s3,t6
    or a0,s0,s9
    or a0,a0,s3
    jr ra
