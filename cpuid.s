.extern error

.global check_cpuid

.text
.code32

check_cpuid:
    /*
        Check if CPUID is supported by attempting to flip the ID bit (bit 21)
        in the FLAGS register. If we can flip it, CPUID is available.
    */

    /* Copy FLAGS in to EAX via stack */
    pushfl
    popl %eax

    /* Copy to ECX as well for comparing later on */
    movl %eax, %ecx

    /* Flip the ID bit */
    xorl 1 << 21, %eax

    /* Copy EAX to FLAGS via the stack */
    push %eax
    popfl

    /* Copy FLAGS back to EAX (with the flipped bit if CPUID is supported) */
    pushfl
    popl %eax

    /*
        Restore FLAGS from the old version stored in ECX (i.e. flipping the
        ID bit back if it was ever flipped).
    */
    pushl %ecx
    popfl

    /*
        Compare EAX and ECX. If they are equal then that means the bit
        wasn't flipped, and CPUID isn't supported.
    */
    cmpl %eax, %ecx
    je .no_cpuid
    ret
.no_cpuid:
    movb $1, %al
    jmp error
