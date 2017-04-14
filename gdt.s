.text
.code32

.section .bss
.align 4096

.section .rodata
.align 4096
.global gdt64
.global gdt64.code
.global gdt64.data
.global gdt64.user_code
.global gdt64.user_data
.global gdt64.pointer
gdt64:
    .quad 0 /* zero entry */
gdt64.code: /* . - gdt64 */ /* new */
    .quad (1<<44) | (1<<47) | (1<<41) | (1<<43) | (1<<53) /* code segment */
gdt64.data: /* . - gdt64 */ /* new */
    .quad (1<<44) | (1<<47) | (1<<41) /* data segment */
gdt64.user_code: /* . - gdt64 */ /* new */
    .quad (1<<44) | (3<<45) | (1<<47) | (1<<41) | (1<<43) | (1<<53) /* userspace code segment */
gdt64.user_data: /* . - gdt64 */ /* new */
    .quad (1<<44) | (3<<45) | (1<<47) | (1<<41) /* userspace data segment */
gdt64.pointer:
    .hword . - gdt64 - 1
    .quad gdt64
