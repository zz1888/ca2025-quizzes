bf16_sub:
    addi sp, sp, -4
    sw   ra, 0(sp)
    li  t6, 0x8000
    xor a1, a1, t6          # ½�� b �Ÿ�
    jal ra, bf16_unpack
    jal ra, bf16_add
    lw   ra, 0(sp)
    addi sp, sp, 4
    jr ra
