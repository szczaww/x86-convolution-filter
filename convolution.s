        section .text
        global  convolution
        
convolution:
        push    rbp
        mov     rbp, rsp
        push    r14
        push    r15

        ; Register with constants
        ; rdi - image pixel map address
        ; rsi - result pixel map address
        ; dl  - width / lenght                  >rdx
        ; dh  - height                          >rdx
        ; cl  - curent x                >rcx
        ; ch  - current y               >rcx
        ; r8  - mouse x
        ; r9  - mouse y

        ; Registers to use
        ; r10 - radius
        ; r11 - 
        ; r12 - 
        ; r13 - 
        ; r14 -  
        ; r15 -  
        ; rbx -

        mv      dl, rdi
        mv      dh, rcx
        mv      cl, r10
        mv      ch, r11

        ; Initial values
        mv      cl, 1
        mv      ch, 1

convolute_pixel:
        ; Calculate distance
        sub     rax, cl, r8    ; delta x
        sub     r10, ch, r9    ; delta y 

        imul    rax, rax       ; (delta x)^2
        imul    r10, r10       ; (delta y)^2

        add     rax, r10

estimate_sqrt_root:
        ; r10 - original value
        ; r11 - current aproximation
        ; r15 - iterations count
        mv      r10, rax
        mv      r11, rax
        mov     r15, 0

sqrt_root_loop:
        mov     r12, r10
        mov     r13, r11

        xor     r12, rax       ; r12 = og_value - curr_aprox^2
        div     rax,           ; rax  og_value / curr_arpox

        add     rax, 








save_pixel:
        imul    rax, ch, dl     ; rax =  y * width
        add     rax, cl         ; rax =  y * width + x
        imul    rax, 3          ; rax = (y * width + x) * 3

        add     rax, rsi        ; rax = (y * width + x) * 3 + result pixel map address
        mov     [rax], r12      ; save color !!!!!!!!

next_pixel:
        cmp    cl, dl
        je     next_row         ; leaves row without modyfing last pixel

        add     cl, 1
        jmp     convolute_pixel

next_row:
        mv      cl, 1
        add     ch, 1

        cmp     ch, dh
        jl      convolute_pixel ; ends when equals last pixel

end:
        mov     rax, rsi        ; return result_pixel_map
        pop     15
        pop     r14
        mov     rsp, rbp
        pop     rbp
        ret     
        ret
