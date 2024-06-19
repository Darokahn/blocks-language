global _start
.text:
_start:
    push 42
    call uitoa
    return:
    call print
    call end
    

end:
    mov ebx, [esp+4]
    ; before operation: push exit code
    mov eax, 1
    int 0x80

print:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, len
    int 0x80
    ret

uitoa:
    ; +4: num
    ; -4: digits
    ; -8: comp
    ; -12: has_found_digit
    mov ebp, esp
    push msg
    push 1000000
    push 0

    mov eax, [ebp + 4]
    cmp eax, [ebp-8]

    jl divide_comp
    jmp else
        divide_comp:
            mov eax, [ebp-8]
            mov esi, 10
            div esi
            mov [ebp-8], eax
        increment_digit:
            add eax, 1
            mov byte [eax], 48
        jmp then

    else:

        jge subtract_comp
            subtract_comp:
                sub eax, ecx

        jge increment_val
            increment_val:
            add byte [eax], 1
    
    then:
        cmp ebp, 0
        jle return

        jmp uitoa

    ;if num < comp:
    ;    goto divide code
    ;    if has_found_digit:
    ;        goto increment digit code
    ;else:
    ;   sub comp from num
    ;   increment value at current place
    ;if num:
    ;    restart


.data:
msg resb 80
len equ $ - msg
