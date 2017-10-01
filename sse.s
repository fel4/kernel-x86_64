.code32
.text

.extern error



/* Check for SSE and enable it. If it's not supported throw error "a". */
.global setup_SSE
setup_SSE:
    /* check for SSE */
    movl $0x1, %eax
    cpuid
    test %edx, 1<<25
    jz .no_SSE

    /* enable SSE */
    movl %cr0, %eax
    andw $0xFFFB, %ax   /* clear coprocessor emulation CR0.EM */
    orw $0x2, %ax       /* set coprocessor monitoring  CR0.MP */
    movl %eax, %cr0
    movl %cr4, %eax
    movw $3, %bx
    shlw $9, %bx
    orw %bx, %ax       /* set CR4.OSFXSR and CR4.OSXMMEXCPT at the same time */
    mov %cr4, %eax

    ret
.no_SSE:
    movb $"a", %al
    jmp error


