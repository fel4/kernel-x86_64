/************
 * start.asm
 ************
 * This is the kernel's entry point. We could either call main here,
 * or we can use this to setup the stack or other nice stuff, like
 * perhaps setting up the GDT and segments. Please note that interrupts
 * are disabled at this point.
 */

.extern check_cpuid /* import from cpuid.asm */
.extern check_multiboot /* import from multiboot.asm */
.extern enable_paging, setup_page_tables /* import from paging.asm */
.extern gdt64, gdt64.code, gdt64.data, gdt64.pointer /* import from gdt.asm */
.extern long_start /* import from long_start.asm */
.extern setup_SSE /* import from sse.asm */

.text
.code32

.global start
start:
    /* intialize the stack. */
    movl $stack_top, %ecx
    movl %ecx, %esp
    movl %ebx, %edi /* move mutliboot pointer to edi */

    /* cpu feature detection tests. */
    call check_multiboot
    call check_cpuid
    call check_long_mode

    call setup_page_tables
    call enable_paging
    call setup_SSE

    /* load the 64-bit global descriptor table. */
    lgdt (gdt64.pointer)

    /* update selectors */
    movw $gdt64.data, %ax
    movw %ax, %ss  /* stack selector */
    movw %ax, %ds  /* data selector */
    movw %ax, %es  /* extra selector */

    ljmp $8, $long_start
    /* 
     * print `OK` to the screen
     *mov dword [0xb8000], 0x2f4b2f4f
     */
    hlt

/* Prints `ERR: ` and the given error code to screen and hangs. */
/* parameter: error code (in ascii) in al */
.global error
error:
    movl $0xb8000, %ebp
    movl $0x4f524f45,  (%ebp)
    movl $0x4f3a4f52, 0x4(%ebp)
    movl $0x4f204f20, 0x8(%ebp)
    movb %al,         0xa(%ebp)
    hlt

check_long_mode:
    /* test if extended processor info in available */
    movl $0x80000000, %eax    /* implicit argument for cpuid */
    cpuid                     /* get highest supported argument */
    cmpl $0x80000001, %eax    /* it needs to be at least 0x80000001 */
    jb .no_long_mode          /* if it's less, the CPU is too old for long mode */

    /* use extended info to test if long mode is available */
    mov $0x80000001, %eax  /* argument for extended processor info */
    cpuid                  /* returns various feature bits in ecx and edx */
    movl $1, %ebx
    shll $29, %ebx
    test %ebx, %edx        /* test if the LM-bit is set in the D-register */
    jz .no_long_mode       /* If it's not set, there is no long mode */
    ret
.no_long_mode:
    movb $"2", %al
    jmp error

/*
 * Here is the definition of our BSS section. Right now, we'll use
 * it just to store the stack. Remember that a stack actually grows
 * downwards, so we declare the size of the data before declaring
 * the identifier '_sys_stack'
 */
.section .bss
.align 4096
.stack_bottom:
    /* This reserves 64KiB of memory here */
    .zero 65536
.stack_top:
/*****************************************************************************/
