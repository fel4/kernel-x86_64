.code32
.extern error
.global check_multiboot
.section .multiboot_header

header_start:
    .int 0xe85250d6                   /* multiboot2 magic number */
    .int 0                            /* arch 0 (protected mode x86) */
    .int header_end - header_start    /* header length */
    .int 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start)))

    /* optional multiboot tags here */


    /* required end tag */
    .hword 0    /* type */
    .hword 0    /* flags */
    .hword 8    /* size */
header_end:

.text

check_multiboot:
    cmpl $0x36d76289, %eax
    jne .no_multiboot
    ret

.no_multiboot:
    movb $0, %al
    jmp error
