.text
.code32

.global enable_paging
enable_paging:
    /* load P4 to cr3 register (cpu uses this to access the P4 table) */
    movl p4_table, %eax
    movl %eax, %cr3

    /* enable PAE-flag in cr4 (Physical Address Extension) */
    movl %cr4, %eax
    movl $1, %ebx
    shll $5, %ebx
    orl %ebx, %eax
    movl %eax, %cr4

    /* set the long mode bit in the EFER MSR (model specific register) */
    movl $1, %ebx
    shll $31, %ebx
    movl %ebx, %ecx
    rdmsr
    movl $1, %ebx
    shll $8, %ebx
    orl %ebx, %eax
    wrmsr

    /* enable paging in the cr0 register */
    movl %cr0, %eax
    orl $0xF000, %eax
    mov %eax, %cr0

    ret

.global setup_page_tables
setup_page_tables:
    /* map first P4 entry to P3 table */
    movl (p3_table), %eax
    orl $0b11, %eax /* present + writable */
    movl %eax, (p4_table)

    /* map first P3 entry to P2 table */
    movl p2_table, %eax
    orl $0b11, %eax /* present + writable */
    movl %eax, (p3_table)

    /* map each P2 entry to a huge 2MiB page */
    movl $0, %ecx

.map_p2_table:
    /* map ecx-th P2 entry to a huge page that starts at address 2MiB*ecx */
    movl $0x200000, %eax   /* 2MiB */
    mul %ecx             /* start address of ecx-th page */
    orl $0b10000011, %eax /* present + writable + huge */
    movl $p2_table, %ebx
    movl (%ebx,%ecx,8), %eax  /* map ecx-th entry */

    inc %ecx            /* increase counter */
    cmp $512, %ecx       /* if counter == 512, the whole P2 table is mapped */
    jne .map_p2_table  /* else map the next entry */

.recursive_map_p4_table:
    movl %eax, (p4_table)
    orl $0b11, %eax  /* present & writable */
    movl $511, %ebx
    movl $p4_table, %ecx
    movl (%ecx,%ebx,8), %eax

    ret


.section .bss
.align 4096

p4_table:
    .fill 4096
p3_table:
    .fill 4096
p2_table:
    .fill 4096
