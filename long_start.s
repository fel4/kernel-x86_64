.text
.code64

.global long_start
long_start:
    .extern rust_main
    call rust_main
.os_returned:
    /* rust main returned, print `OS returned!` */
    movq $0x4f724f204f534f4f, %rax
    movq %rax, ($0xb8000)
    movq $0x4f724f754f744f65, %rax
    movq %rax, ($0xb8008)
    movq $0x4f214f644f654f6e, %rax
    movq %rax, ($0xb8010)
    hlt
