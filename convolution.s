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
        ; r12 - new color
        ; r13 - save_pixel adress
        ; r14 - radius / x calculations
        ; r15 - radius / y calculations
        ; rbx - offset from address

        ; rdi - image pixel map address
        ; rsi - result pixel map address
        ; dl  - width / lenght                  >rdx
        ; dh  - height                          >rdx
        ; cl  - curent x
        ; ch  - current y

        mv      dl, rdi
        mv      dh, rcx
        mv      cl, r10
        mv      ch, r11

        ; Initial values
        mv      r10, 1
        mv      r11, 1

convolute_pixel:
        ; Calculate distance
        sub     eax, r10, r8    ; delta x
        sub     r15, r11, r9    ; delta y 

        imul    eax, eax        ; (delta x)^2
        imul    r15, r15        ; (delta y)^2

        add     eax, r15

estimate_sqr_root:


        



save_pixel:
        imul    rax, r11, rdx   ; rax =  y * width
        add     rax, r10        ; rax =  y * width + x
        imul    rax, 3          ; rax = (y * width + x) * 3

        add     rax, rsi        ; rax = (y * width + x) * 3 + result pixel map address
        mov     [rax], r12      ; save color

next_pixel:
        cmp    r10, rdx
        je     next_row         ; leaves row without modyfing last pixel

        add     r10, 1
        jmp     convolute_pixel

next_row:
        mv      r10, 1
        add     r11, 1

        cmp     r11, rcx
        jl      convolute_pixel ; ends when equals last pixel

end:
        mov     rax, rsi        ; return result_pixel_map
        ret
