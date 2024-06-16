format ELF64 executable 3

segment readable executable

entry $
    mov rax, 233
    call uitoa
    call print

print:
    mov rax, 1
    mov rdi, 1

    lea rsi, [forw]
    mov rdx, 3
    syscall
    ret

exit:
    mov rax, 60
    mov rdi, 0
    syscall

uitoa:
    mov r9, rax
    mov r15, 0 ; digit found bool
    mov r8, 0 ; digit counter
    mov rdx, 10000000000 ; max 10s
    call uitoa_loop

uitoa_loop:
    call print
    cmp r9, rdx
    jl divi
    mov r15, 1
    sub r9, rdx
    add byte [rev], 1

    divi:
        mov rdx, rax
        xor rdx, rdx
        mov rcx, 10
        div rcx
        mov rax, rdx
        cmp r15, 1
        jl add_digit
        jmp uitoa_loop

        add_digit:
            inc r8
            call migrate_buffer
            jmp uitoa_loop

migrate_buffer:
    ret


segment readable writable

rev:
    dd 10
    rb 80
forw:
    dd 48
    dd 10
    rb 80
