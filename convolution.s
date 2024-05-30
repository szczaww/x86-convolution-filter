        section .data
        matrix1_corner  dq      0.0
        matrix1_edge    dq      -1.0
        matrix1_mid     dq      5.0
        matrix2_corner  dq      1.0
        matrix2_edge    dq      2.0
        matrix2_mid     dq      -4.0

        ; Constants
        float_2         dq      2.0
        float_1         dq      1.0
        
        section .text
        global  convolution
        
convolution:
        ; rdi - image pixel map address
        ; rsi - result pixel map address
        ; rdx - width
        ; rcx - heightd
        ; r8  - mouse x
        ; r9  - mouse y
        ; r10 - current x
        ; r11 - current y
        ; r12 - bpp (bites per pixel)
        push    rbp
        mov     rbp, rsp
        push    r13
        push    r14
        push    r15

        mov     rdx, 512
        mov     rcx, 512
        ;mov     r8, 2
        ;mov     r9, 1

        mov     r12, 3


        ; Initial values
        mov      r10, 1
        mov      r11, 1

convolute_pixel:
        ; Calculate distance
        mov     r13, r10
        sub     r13, r8         ; delta x
        imul    r13, r13        ; (delta x)^2

        mov     r14, r11
        sub     r14, r9         ; delta y
        imul    r14, r14        ; (delta y)^24
        add     r13, r14        ; (delta x)^2 + (delta y)^2

sqrt_root:        
        cvtsi2sd        xmm0, r13
        sqrtsd          xmm0, xmm0      ; is distance

calculate_w:
        movsd   xmm1, [float_1]
        movsd   xmm2, [float_2]

        cmp             rdx, rcx        ; compare width and height
        jl              width_lower

        ; Height_lower
        cvtsi2sd        xmm3, rcx
        jmp             perform_division

width_lower:
        cvtsi2sd        xmm3, rdx

perform_division:
        divsd           xmm0, xmm2      ; w = r /  2
        divsd           xmm0, xmm3      ; w = r / (2 * min(width, height))

        ucomisd         xmm0, xmm1
        jb              calculate_offset        ; jummp if xmm0 < xmm1

        movsd           xmm0, xmm1              ; 1 is lower 

calculate_offset:
        ; xmm0 - w
        ; xmm1 - result color (float)
        ; xmm2 - current color (float)
        ; xmm3 - current m1 (float)
        ; xmm4 - current m2 / result mask (float)
        ; r13 - addres offset
        ; r14 - sum of colors
        ; r13 - ++y offset

        ; Calculate ++y offset
        mov     r15, rdx        ; width
        imul    r15, r12        ; width * bpp

        ; Calculate pixel offset
        mov     r13, r11        ;  y
        imul    r13, rdx        ;  y * width
        add     r13, r10        ;  y * width + x 
        imul    r13, r12          ; (y * width + x) * bpp
        add     r13, rdi        ; (y * width + x) * bpp + pixel map adress

middle_factor:
        ; Get original color
        xor     r14, r14
        mov     r14b, byte [r13]

        ; Calculate mask
        movsd   xmm3, [matrix1_mid]     ; prep m1
        movsd   xmm4, [matrix2_mid]     ; mask = m2
        mulsd   xmm4, xmm0              ; mask = m2 * w
        addsd   xmm3, xmm4              ; mask = m2 * w + m1
        
        ; Multiply mask and color
        cvtsi2sd        xmm1, r14       ; convert to float
        mulsd           xmm1, xmm3      ; color *= mask

edges_factor:
        xor     r14, r14

        ; Sum edge colors
        sub     r13, r12                ; go to L
        mov     r14b, byte [r13]        ; L color

        add     r13, r12                ; go to M
        add     r13, r12                ; go to R
        movzx   rax, byte [r13]         ; load
        add     r14, rax                ; L + R color

        sub     r13, r12                ; go to M
        sub     r13, r15                ; go to T
        movzx   rax, byte [r13]         ; load
        add     r14, rax                ; L + R + T color

        add     r13, r15                ; go to M
        add     r13, r15                ; go to B
        movzx   rax, byte [r13]         ; load
        add     r14, rax                ; L + R + T + B color

        ; Calculate mask
        movsd   xmm3, [matrix1_edge]    ; prep m1
        movsd   xmm4, [matrix2_edge]    ; mask = m2
        mulsd   xmm4, xmm0              ; mask = m2 * w
        addsd   xmm3, xmm4              ; mask = m2 * w + m1

        ; Multiply mask and sum of colors
        cvtsi2sd        xmm2, r14
        mulsd           xmm2, xmm3
        addsd           xmm1, xmm2      

corners_factor:
        xor     r14, r14

        ; Sum edge colors
        sub     r13, r12                ; go to BL
        mov     r14b, byte [r13]        ; BL color

        add     r13, r12                ; go to BR
        movzx   rax, byte [r13]         ; load
        add     r14, rax                ; BL + BR color

        sub     r13, r15                ; go to R
        sub     r13, r15                ; go to TR
        movzx   rax, byte [r13]         ; load
        add     r14, rax                ; BL + BR + TR color

        sub     r13, r12                 ; go to TM
        sub     r13, r12                 ; go to TL
        movzx   rax, byte [r13]         ; load
        add     r14, rax                ; BL + BR + TR + TL color

        ; Calculate mask
        movsd   xmm3, [matrix1_corner]  ; prep m1
        movsd   xmm4, [matrix2_corner]  ; mask = m2
        mulsd   xmm4, xmm0              ; mask = m2 * w
        addsd   xmm3, xmm4              ; mask = m2 * w + m1

        ; Multiply mask and sum of colors
        cvtsi2sd        xmm2, r14
        mulsd           xmm2, xmm3
        addsd           xmm1, xmm2

        ; Convert float to integer
        cvtsd2si        r14, xmm1 

save_color:
        ; Fix offset back
        add     r13, r12        ; go to T
        add     r13, r15        ; go to M
        sub     r13, rdi        ; back to pure offset
        add     r13, rsi        ; new pixel map save adress

        mov     [r13], r14b      ; save color byte 1
        inc     r13
        mov     [r13], r14b     ; save color byte 2
        inc     r13
        mov     [r13], r14b     ; save color byte 3
        inc     r13

next_pixel:
        cmp    cl, dl
        je     next_row         ; leaves row without modyfing last pixel

        add     cl, 1
        jmp     convolute_pixel

next_row:
        mov     r10, 1
        add     r11, 1

        cmp     ch, dh
        jl      convolute_pixel ; ends when equals last pixel


end:
        mov     rax, rsi        ; return result_pixel_map
        pop     r15
        pop     r14
        pop     r13
        ;pop     r12
        mov     rsp, rbp
        pop     rbp
        ret
