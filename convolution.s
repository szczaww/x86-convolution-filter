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
        ; rcx - height
        ; r8  - mouse x
        ; r9  - mouse y
        ; r10 - current x
        ; r11 - current y
        ; r12 - bpp (bites per pixel)
        push    rbp
        mov     rbp, rsp
        push    r12
        push    r13
        push    r14
        push    r15

        ; 7th argument from stack
        mov     r12, [rbp+16]

        ; Initial x&y values
        mov      r10, 1
        mov      r11, 1

calculate_padding:
        ; Lets add padding
        ; r15 - width * bpp
        mov     r15, rdx        ; width
        imul    r15, r12        ; width * bpp

        mov     r14, r15        ; copy        
        and     r14, 7          ; last 3 bits 

        cmp     r14, 0
        je      convolute_pixel ; padding is zero

        ; Padding neccessary
        mov     r13, 4
        sub     r13, r14        ; padding = 4 - r14
        add     r15, r13        ; width * bpp + padding

convolute_pixel:
        ; Calculate distance
        mov     r13, r10
        sub     r13, r8         ; delta x
        imul    r13, r13        ; (delta x)^2

        mov     r14, r11
        sub     r14, r9         ; delta y
        imul    r14, r14        ; (delta y)^2

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
        divsd           xmm0, xmm2              ; w = r /  2
        divsd           xmm0, xmm3              ; w = r / (2 * min(width, height))

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
        ; r15 - row offset (++y or --y)
        
        mov     r13, r11        ;  y
        imul    r13, r15        ;  y * (width * bpp + padding) 
        
        mov     r14, r10        ; x
        imul    r14, r12        ; x * bpp

        add     r13, r14        ; y * (width * bpp + padding) + x * bpp
        add     r13, rdi        ; y * (width * bpp + padding) + x * bpp + pixel map offset

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
corner1:
        mov     r14b, byte [r13]        ; BL color

        add     r13, r12                ; go to BM
        add     r13, r12                ; go to BR
corner2:
        movzx   rax, byte [r13]         ; load
        add     r14, rax                ; BL + BR color

        sub     r13, r15                ; go to R
        sub     r13, r15                ; go to TR
corner3:
        movzx   rax, byte [r13]         ; load
        add     r14, rax                ; BL + BR + TR color

        sub     r13, r12                ; go to TM
        sub     r13, r12                ; go to TL
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

        ;cmp             r14, 255
        ;jg              greater_than_255

        ;cmp             r14, 0
        ;jl              less_than_0

        ;jmp             save_color

less_than_0:
        ;mov             r14, 0
        ;jmp             save_color

greater_than_255:
        ;mov             r14, 255

save_color:
        ; Fix offset back
        add     r13, r12        ; go to T
        add     r13, r15        ; go to M
        sub     r13, rdi        ; back to pure offset
        add     r13, rsi        ; new pixel map save adress

        mov     [r13], r14b     ; save color byte 1
        inc     r13
        mov     [r13], r14b     ; save color byte 2
        inc     r13
        mov     [r13], r14b     ; save color byte 3
        inc     r13

next_pixel:
        inc     r10             ; x++

        mov     r13, rdx        ; width
        dec     r13             ; width - 1

        cmp     r10, r13
        je      next_row        ; x = width -1 
        jmp     convolute_pixel ; x < width -1 

next_row:
        mov     r10, 1          ; x = 1 (2nd pixel)
        inc     r11             ; y++

        mov     r13, rcx        ; height
        sub     r13, 1          ; height - 1
     
        cmp     r11, r13
        jl      convolute_pixel ; y < width -1

end:
        mov     rax, rsi        ; return result_pixel_map
        pop     r15
        pop     r14
        pop     r13
        pop     r12
        mov     rsp, rbp
        pop     rbp
        ret
