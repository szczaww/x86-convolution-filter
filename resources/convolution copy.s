        section .text
        global  convolution
        
convolution:
        ; ORIGNAL
        ; rdi - image pixel map address
        ; rsi - result pixel map address
        ; rdx - width
        ; rcx - height
        ; r8  - mouse x
        ; r9  - mouse y
        ; r10 - current x
        ; r11 - current y

        push    rbp
        mov     rbp, rsp
        push    r12
        push    r13
        push    r14
        push    r15

        ; Initial values
        mov      r10, 1
        mov      r11, 1

get_OG_color:
        mov     r14, r11        ;  y
        imul    r14, rdx        ;  y * width
        add     r14, r10        ;  y * width + x 
        imul    r14, 4          ; (y * width + x) * 3
        add     r14, rdi        ; (y * width + x) * 3 + pixel map adress

        ;mov     r12, [r14]

save_OG_color:
        sub     r14, rdi
        add     r14, rsi

        mov     r12, 255

        mov     [r14], byte 255      ; save color word 1
        inc     r14

        mov     [r14], byte 0      ; save color word 2
        inc     r14

        mov     [r14], byte 0     ; save color word 3
        inc     r14

        ;mov     [r14], byte 0     ; save color word 3
        ;inc     r14

next_pixel:
        add    r10, 1
        cmp    r10, rdx
        je     next_row         ; leaves row without modyfing last pixel

        jmp     get_OG_color

next_row:
        mov     r10, 0
        add     r11, 1

        cmp     r11, rcx
        jl     get_OG_color    ; ends when equals last pixel

end:
        mov     rax, rsi
        pop     r15
        pop     r14
        pop     r13
        pop     r12
        mov     rsp, rbp
        pop     rbp
        ret
