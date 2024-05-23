        section .text
        global  convolution
        
convolution:
        mov     rcx, rdi        ; head ptr

fin:
        mov     rax, rdi        ; return the original arg
        ret
