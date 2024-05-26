        section .data
        fixed_point_1 dq 4294967296
        fixed_point_5 dq 21474836480
        
        
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

        ; r12 - radius
        ; r13 - 
        ; r14 - 
        ; r15 -
        ; rbx -

        ; Initial values
        mov      r10, 1
        mov      r11, 1

convolute_pixel:
        ; Calculate distance
        mov     r12, r10
        sub     r12, r8    ; delta x

        mov     r13, r11
        sub     r13, r9    ; delta y

        imul    r12, r12        ; (delta x)^2
        imul    r13, r13        ; (delta y)^2

        add     r12, r13        ; (delta x)^2 + (delta y)^2
        shl     r12, 32         ; fixed point 32b32b

estimate_sqr_root:
        mov     r13, 0                  ; r13 - low
        mov     r14, r12                ; r14 - high
        mov     rbx, [fixed_point_1]    ; 1 in 32b32b

sqrt_root_loop:
        mov     r15, r13        ; r15 = low
        add     r15, r14        ; r15 = low + high
        shr     r15, 1          ; r15 = (low + high) / 2 [mid]

        mov     rax, r15
        imul    r15             ; rax - estimated square
        shr     rax, 32         ; fix fixed point offset

        cmp     rax, r12        ; check if matches
        jg      upper_half
        je      found_sqrt_root

lower_half:
        mov     r13, r15                ; low = mid

        add     r13, rbx                ; low = mid + 1 (2^32)          ; !!!!!
        jmp     continue

upper_half:
        mov     r14, r15                ; high = mid
        sub     r14, rbx                ; high = mid - 1 (2^32)         ; !!!!!

continue:
        cmp     r13, r14
        jle     sqrt_root_loop

found_sqrt_root:
        mov      r12, r15
        shl     r12, 32         ; this is distance

take_first_minimum:
        ; w = min(r / (2 * min(width, height)), 1)
        ; r13 = min(width, height)
        ; r12 = distance
        cmp     rdx, rcx        ; compare width and height
        jl      width_lower

height_lower:
        mov     r13, rcx
        jmp     perform_division

width_lower:
        mov     r13, rdx

perform_division:
        shl     r13, 32         ; convert to fixed pointed 32b32b
        xor     rdx, rdx        ; load with 0's for division

        mov     rax, r12        ; rax = r
        div     r13             ; rax = r /  min(wdith, height)
        shr     rax, 1          ; rax = r / (min(wdith, height) * 2)
        shr     rax, 32         ; fix fixed point offset

        mov     r12, rax

take_second_minimum:
        cmp     r12, rbx                ; 1 in 32b32b (2^32)            ; !!!!!
        jl      calculate_offset        ; 1 is higher

        mov     r12, rbx                ; 1 is lower 

calculate_offset:
        ; r12 - contains W
        ; r13 - will store final new pixel color
        ; r14 - will store color byte offset
        ; r15 - will store current mask
        ; rbx - will store current color*mask

        mov     r14, r11        ;  y
        imul    r14, rdx        ;  y * width
        add     r14, r10        ;  y * width + x 
        imul    r14, 3          ; (y * width + x) * 3 = offset from bitmap start
        
        add     r14, rdi        ;  original pixel byte adress

calculate_middle_mask:
        imul    r13, r12, -1            ; mask = W * (-1)               ; !!!!!
        shl     r13, 2                  ; mask = W * (-4)
        shr     r13, 32                 ; fix fixed point offset

        mov     rax, [fixed_point_5]
        add     r13, rax                ; += 5 (in 32b32b)              ; !!!!!
        
calculate_middle_color:
        imul    r13, [r14]      ; color = mask * og M color
        shr     r13, 32         ; fix fixed point offset

sum_edge_colors:
        ; sum L, R, T and B  colors
        ; because all have the same mask

        ; temporarly use r10 and r11 due to lack of registers
        ; r10 - offset difference when moving diagonaly
        ; r11 - sum of colors

        push    r10
        push    r11

        mov     r10, rdx        ; width
        imul    r10, 3          ; width * 3


        sub     r14, 3          ; L offset
        mov     r11, [r14]      ; L color

        add     r14, 6          ; R offset
        add     r11, [r14]      ; L + R color
        
        sub     r14, 3          ; back to M
        sub     r14, r10        ; T offset
        add     r11, [r14]      ; L + R + T color

        add     r14, r10        ; back to M
        add     r14, r10        ; B offset
        add     r11, [r14]      ; L + R + T + B color

        shl     r11, 32         ; convert to 32b32b

calculate_edge_mask:
        mov     r15, r12                ; mask = w
        shl     r15, 1                  ; mask = w * 2

        mov     rax, [fixed_point_1]
        sub     r15, rax                ; mask = w * 2 - 1 (in 32b32b)          ; !!!!!

        imul    r11, r15        ; color factor = color * mask
        shr     r11, 32         ; fix fixed point offset

        add     r13, r11        ; add factor to final color

sum_corner_colors:
        ; add BL, BR, TR and TL colors
        ; because all have the same mask

        ; offset atm points to B pixel

        sub     r14, 3          ; BL offset
        mov     r11, [r14]      ; BL color

        add     r14, 6          ; BR offset
        add     r11, [r14]      ; BL + BR color

        sub     r14, r10        ; R edge
        sub     r14, r10        ; TR offset
        add     r11, [r14]      ; BL + BR + TR color

        sub     r14, 6          ; TL offset
        add     r11, [r14]      ; BL + BR + TR + TL color

        shl     r11, 32         ; convert to 32b32b

calculate_corner_mask:
        ; we can multiply by W since for corner mask = w * 1 + 0

        imul    r11, r12        ; color *= w
        shr     r11, 32         ; fix fixed point offset

        add     r13, r11        ; add factor to final color

        pop     r11
        pop     r10

save_color:
        ; r14 currently is offset to TL pixel

        shr     r13, 32         ; turn back from fixed point to int

        add     r14, 3          ; back to T pixel
        add     r14, r10        ; back to M pixel

        sub     r14, rdi        ; back to pure offset
        add     r14, rsi        ; new pixel map save adress 

        mov     [r14], r13      ; save color byte 1
        inc     r14

        mov     [r14], r13      ; save color byte 2
        inc     r14

        mov     [r14], r13      ; save color byte 3
        inc     r14

next_pixel:
        cmp    r10, rdx
        je     next_row         ; leaves row without modyfing last pixel

        add     r10, 1
        jmp     convolute_pixel

next_row:
        mov      r10, 1
        add     r11, 1

        cmp     r11, rcx
        jl      convolute_pixel ; ends when equals last pixel


end:
        mov     rax, rdi        ; return result_pixel_map
        ret
