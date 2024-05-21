        section .text
        global  convolution
        
convolution:
        mov     rcx, rdi        ; head ptr
        mov     rdx, rcx        ; tail ptr

fin:
        mov     rax, rdi        ; return the original arg
        ret
