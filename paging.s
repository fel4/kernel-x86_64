.text
.code32

.global enable_paging
enable_paging:
    /* load P4 to cr3 register (cpu uses this to access the P4 table) */
    movl p4_table, %eax
    movl %eax, %cr3

    /* enable PAE-flag in cr4 (Physical Address Extension) */
    movl %cr4, %eax
    orl %eax, $1 << $5
    movl %eax, %cr4

    /* set the long mode bit in the EFER MSR (model specific register) */
    movl $0xC0000080, %ecx
    rdmsr
    orl %eax, $1 << $8
    wrmsr

    /* enable paging in the cr0 register */
    movl %cr0, %eax
    orl %eax, $1 << $31
    mov %eax, %cr0

    ret

.global setup_page_tables
setup_page_tables:
    /* map first P4 entry to P3 table */
    movl p3_table, %eax
    orl %eax, $0b11 /* present + writable */
    mov %eax, (p4_table)

    /* map first P3 entry to P2 table */
    movl p2_table, %eax
    orl %eax, @0b11 /* present + writable */
    movl %eax, (p3_table)

    /* map each P2 entry to a huge 2MiB page */
    movl $0, %ecx

.map_p2_table:
    ; map ecx-th P2 entry to a huge page that starts at address 2MiB*ecx
    mov eax, 0x200000  ; 2MiB
    mul ecx            ; start address of ecx-th page
    or eax, 0b10000011 ; present + writable + huge
    mov [p2_table + ecx * 8], eax ; map ecx-th entry

    inc ecx            ; increase counter
    cmp ecx, 512       ; if counter == 512, the whole P2 table is mapped
    jne .map_p2_table  ; else map the next entry

.recursive_map_p4_table:
    mov eax, p4_table
    or eax, 0b11 ; present & writable
    mov [p4_table + 511 * 8], eax

    ret


section .bss
align 4096

p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096
