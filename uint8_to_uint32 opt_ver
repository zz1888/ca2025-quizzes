.data
msg_pass:    .asciz "All tests passed.\n"
msg_fail:    .asciz "Some tests failed.\n"

.text
.global _main
main:
    li s3,1      # passed = true
    li s4,-1     # previous_value = -1
    li s5,0      # i = 0
    jal ra, test_loop
    beqz s3, fail
    j end
pass:
    la a0, msg_pass
    li a7, 4
    ecall
    j end

fail:
    mv a0,s5 # print value 
    li a7,1
    ecall
    la a0, msg_fail
    li a7, 4
    ecall    
    j end
clz:
    addi sp, sp, -4
    sw ra, 0(sp)
    li a2, 32 #n=32
    li a3, 16 #c=16
    
clz_loop:
    srl a1,a0,a3 #x=a0 y=t1
    beqz a1, clz_not_if_loop
    sub a2,a2,a3
    mv a0,a1
    
clz_not_if_loop:
    srli a3,a3,1
    bnez a3,clz_loop
    sub a0, a2, a0
    lw ra, 0(sp)
    addi sp, sp, 4
    ret
uf8_decoder:
    andi t0,a0,0x0F #mantissa
    srli t1,a0,4 #exponent
    li t6,15 #15
    sub t2,t6,t1 #15-exponent
    li t3,0x7FFF
    srl t3,t3,t2 #0x7FFF >> (15 - exponent)
    slli t3,t3,4 #offset
    sll t4,t0,t1 #mantissa << exponent
    add a0,t4,t3
    ret
uf8_encoder:
    addi sp, sp, -20       
    sw  ra, 16(sp)     
    sw  s0, 12(sp) 
    sw  s1, 8(sp)    
    sw  s2, 4(sp)     
    sw  s3, 0(sp)     
    mv  s0,a0
    slti t0,s0,16
    bnez t0,clz_encoder_if1_loop 
    #if (value < 16) return value;
    jal ra,clz #lz
    mv s9,a0 # t1=lz 
    li t0,31
    sub s3,t0,s9 # s3=msb
    li s1,0 #exponent
    li s2,0 #overflow
    li t0,5
    bge s3,t0,clz_encoder_if2_loop
    li t6,15
    bge s1,t6,clz_encoder_ending_while2
    j clz_encoder_ending_while1
clz_encoder_if1_loop:
    mv a0,s0
    j encoder_end
clz_encoder_if2_loop:
    addi s1,s3,-4
    li t0,15
    ble s1,t0,clz_encoder_if3_loop
    li s1,15
clz_encoder_if3_loop:
    li t5,0      #t5=e
clz_encoder_for:
    bge t5,s1,clz_encoder_ending_for    
    slli s2,s2,1
    addi s2,s2,16
    addi t5,t5,1
    j clz_encoder_for
clz_encoder_ending_for:
     blez s1,clz_encoder_ending_while1
     bge s0,s2,clz_encoder_ending_while1
     addi s2,s2,-16
     srli s2,s2,1
     addi s1,s1,-1
     j clz_encoder_ending_for
clz_encoder_ending_while1:
    li t6,15
    slli t4,s2,1
    addi t4,t4,16
    blt s0,t4,clz_encoder_ending_while2 # if (value < next_overflow)
    mv s2,t4     # overflow = next_overflow
    addi s1,s1,1
    bge s1,t6,clz_encoder_ending_while2 #if (exponent >= 15)
    j clz_encoder_ending_while1
clz_encoder_ending_while2:
    sub s3,s0,s2
    srl s3,s3,s1
    slli a0,s1,4
    or a0,a0,s3
    j encoder_end
encoder_end:
    lw  s3,0(sp)     
    lw  s2,4(sp)  
    lw  s1,8(sp)        
    lw  s0,12(sp) 
    lw  ra,16(sp)        
    addi sp, sp, 20   
    ret
test_loop: 
    addi sp, sp, -4
    sw  ra,0(sp)   
    li s10,256
    bge s5,s10,test_end
    mv a0,s5
    jal ra,uf8_decoder
    mv t1,a0
    jal ra,uf8_encoder
    mv t2,a0
    bne s5,t2,test_if_loop1
    ble t1,s4,test_if_loop2
    mv s4,t1                         
    j test_out
test_if_loop1:
    li s3,0
    mv s6,s5
    mv s7,t1
    mv s8,t2
    ble t1,s4,test_if_loop2
    mv s4,t1
    j test_out
test_if_loop2:
    li s3,0
    mv s6,s5
    mv s7,t1
    mv s8,s4
    mv s4,t1
    j test_out
test_out:
    beqz s3,fail
    addi s5,s5,1
    bge s5,s10,test_end
    j test_loop
test_end:
    lw  ra,0(sp)
    addi sp,sp,4
    beq s5,s10,pass
    jr   ra
end:
     li a7,10
    ecall
