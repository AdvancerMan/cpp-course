                section         .text

                global          _start
_start:
                
                sub             rsp, 2 * long_integer_size * 8
                lea             rdi, [rsp + long_integer_size * 8]
                mov             rcx, long_integer_size
                call            read_long
                mov             rdi, rsp
                call            read_long
                
                lea             rsi, [rsp + long_integer_size * 8]
                mov             rbx, rsp
                lea             rsp, [rsp - 2 * long_integer_size * 8]
                mov             rdi, rsp
                call            mul_long_long
                
                shl             rcx, 1
                call            write_long

                mov             al, 0x0a
                call            write_char

                jmp             exit

; adds two long number
;    rdi -- address of summand #1 (long number)
;    rsi -- address of summand #2 (long number)
;    rcx -- length of long numbers in qwords
; result:
;    sum is written to rdi
add_long_long:
                push            rdi
                push            rsi
                push            rcx

                clc
.loop:
                mov             rax, [rsi]
                lea             rsi, [rsi + 8]
                adc             [rdi], rax
                lea             rdi, [rdi + 8]
                dec             rcx
                jnz             .loop

                pop             rcx
                pop             rsi
                pop             rdi
                ret

; adds 64-bit number to long number
;    rdi -- address of summand #1 (long number)
;    rax -- summand #2 (64-bit unsigned)
;    rcx -- length of long number in qwords
; result:
;    sum is written to rdi
add_long_short:
                push            rdi
                push            rcx
                push            rdx

                xor             rdx,rdx
.loop:
                add             [rdi], rax
                adc             rdx, 0
                mov             rax, rdx
                xor             rdx, rdx
                add             rdi, 8
                dec             rcx
                jnz             .loop

                pop             rdx
                pop             rcx
                pop             rdi
                ret

; multiplies long number by a short
;    rdi -- address of multiplier #1 (long number)
;    rbx -- multiplier #2 (64-bit unsigned)
;    rcx -- length of long number in qwords
; result:
;    product is written to rdi
mul_long_short:
                push            rax
                push            rdi
                push            rcx

                xor             rsi, rsi
.loop:
                mov             rax, [rdi]
                mul             rbx
                add             rax, rsi
                adc             rdx, 0
                mov             [rdi], rax
                add             rdi, 8
                mov             rsi, rdx
                dec             rcx
                jnz             .loop

                pop             rcx
                pop             rdi
                pop             rax
                ret

; divides long number by a short
;    rdi -- address of dividend (long number)
;    rbx -- divisor (64-bit unsigned)
;    rcx -- length of long number in qwords
; result:
;    quotient is written to rdi
;    rdx -- remainder
div_long_short:
                push            rdi
                push            rax
                push            rcx

                lea             rdi, [rdi + 8 * rcx - 8]
                xor             rdx, rdx

.loop:
                mov             rax, [rdi]
                div             rbx
                mov             [rdi], rax
                sub             rdi, 8
                dec             rcx
                jnz             .loop

                pop             rcx
                pop             rax
                pop             rdi
                ret

; subtracts one unsigned long number from another unsigned long number
;    rdi -- address of minuend (unsigned long number)
;    rsi -- address of subtrahend (unsigned long number)
;    rcx -- length of long numbers in qwords
; result:
;    result is written to rdi
sub_long_long:
                push            rdi
                push            rsi
                push            rcx

                clc
.loop:
                mov             rax, [rsi]
                lea             rsi, [rsi + 8]
                sbb             [rdi], rax
                lea             rdi, [rdi + 8]
                dec             rcx
                jnz             .loop

                pop             rcx
                pop             rsi
                pop             rdi
                ret

; multiplies long number by a long number
;    rsi -- address of multiplier #1 (unsigned long number)
;    rbx -- address of multiplier #2 (unsigned long number)
;    rcx -- length of long number in qwords
; result:
;    product is written to rdi
;    result length is 2 * rcx
mul_long_long:
                shl             rcx, 1
                call            set_zero
                shr             rcx, 1
                
                cmp             rcx, 8
                jl              mul_long_long_naive
                
                ; isn't implemented now
                ; call            mul_karatsuba
                ; ret
mul_long_long_naive:
                call            mul_naive
                ret


; multiplies long number by a long number by karatsuba algorithm
;    rsi -- address of multiplier #1 (unsigned long number)
;    rbx -- address of multiplier #2 (unsigned long number)
;    rcx -- length of long number in qwords
; result:
;    product is written to rdi
;    result length is 2 * rcx
mul_karatsuba:
; A0 * B0 + ((A0 + A1) * (B0 + B1) - A0 * B0 - A1 * B1) * SHIFT + A1 * B1 * SHIFT ^ 2
                push            rdi
                mov             r8, rcx
                mov             r9, rcx
                mov             r10, rcx
		lea		r10, [r10 * 8 + 8]
                shr             r8, 1
                sub             r9, r8
                
                ; A0 * B0
                sub             rsp, r10
                mov             rdi, rsp
                mov             rcx, r8
                call            mul_long_long
                mov             r11, rdi
                
                ; A1 * B1
                sub             rsp, r10
                mov             rdi, rsp
                mov             rcx, r9
                lea             rsi, [rsi + r8 * 8]
                lea             rbx, [rbx + r8 * 8]
                call            mul_long_long
                ; lea             rsi, [rsi - r8 * 8]
                ; lea             rbx, [rbx - r8 * 8]
                mov             r12, rdi
                
                ; (A0 + A1) * (B0 + B1)
                sub             rsp, r10
                
                ; A0 + A1
                lea             r9, [r9 * 8 + 8]
                sub             rsp, r9
                shr             r9, 3
                
                mov             rdi, rsp
                mov             rcx, r9
                call            set_zero
		
		lea             rsi, [rsi + r8 * 8]
                lea             rbx, [rbx + r8 * 8]
                call            mul_long_long
                ; lea             rsi, [rsi - r8 * 8]
                ; lea             rbx, [rbx - r8 * 8]
                mov             r12, rdi
                
                
                
                ; B0 + B1
                
                
                ret


; multiplies long number by a long number by naive algorithm
;    rsi -- address of multiplier #1 (unsigned long number)
;    rbx -- address of multiplier #2 (unsigned long number)
;    rcx -- length of long number in qwords
; result:
;    product is written to rdi
;    result length is 2 * rcx
mul_naive:
                push            rdi
                
                mov             r9, rcx
                mov             r11, rsi
                xor             rdx, rdx
.loop1:
                mov             r10, rcx
                mov             r12, rbx
                mov             r13, [r11]
                mov             r14, rdi
                
                xor             rdx, rdx
                clc
.loop2:
                mov             r15, [r14]
                xor             r8, r8
                add             r15, rdx
                adc             r8, 0
                xor             rdx, rdx
                mov             rax, [r12]
                mul             r13
                add             r15, rax
                adc             rdx, r8
                mov             [r14], r15
                
                lea             r12, [r12 + 8]
                lea             r14, [r14 + 8]
                dec             r10
                jnz             .loop2
                
                add             [r14], rdx
                lea             r11, [r11 + 8]
                lea             rdi, [rdi + 8]
                dec             r9
                jnz             .loop1
                
                pop             rdi
                ret


; assigns a zero to long number
;    rdi -- argument (long number)
;    rcx -- length of long number in qwords
set_zero:
                push            rax
                push            rdi
                push            rcx

                xor             rax, rax
                rep stosq

                pop             rcx
                pop             rdi
                pop             rax
                ret

; checks if a long number is a zero
;    rdi -- argument (long number)
;    rcx -- length of long number in qwords
; result:
;    ZF=1 if zero
is_zero:
                push            rax
                push            rdi
                push            rcx

                xor             rax, rax
                rep scasq

                pop             rcx
                pop             rdi
                pop             rax
                ret

; read long number from stdin
;    rdi -- location for output (long number)
;    rcx -- length of long number in qwords
read_long:
                push            rcx
                push            rdi

                call            set_zero
.loop:
                call            read_char
                or              rax, rax
                js              exit
                cmp             rax, 0x0a
                je              .done
                cmp             rax, '0'
                jb              .invalid_char
                cmp             rax, '9'
                ja              .invalid_char

                sub             rax, '0'
                mov             rbx, 10
                call            mul_long_short
                call            add_long_short
                jmp             .loop

.done:
                pop             rdi
                pop             rcx
                ret

.invalid_char:
                mov             rsi, invalid_char_msg
                mov             rdx, invalid_char_msg_size
                call            print_string
                call            write_char
                mov             al, 0x0a
                call            write_char

.skip_loop:
                call            read_char
                or              rax, rax
                js              exit
                cmp             rax, 0x0a
                je              exit
                jmp             .skip_loop

; write long number to stdout
;    rdi -- argument (long number)
;    rcx -- length of long number in qwords
write_long:
                push            rax
                push            rcx

                mov             rax, 20
                mul             rcx
                mov             rbp, rsp
                sub             rsp, rax

                mov             rsi, rbp

.loop:
                mov             rbx, 10
                call            div_long_short
                add             rdx, '0'
                dec             rsi
                mov             [rsi], dl
                call            is_zero
                jnz             .loop

                mov             rdx, rbp
                sub             rdx, rsi
                call            print_string

                mov             rsp, rbp
                pop             rcx
                pop             rax
                ret

; read one char from stdin
; result:
;    rax == -1 if error occurs
;    rax \in [0; 255] if OK
read_char:
                push            rcx
                push            rdi

                sub             rsp, 1
                xor             rax, rax
                xor             rdi, rdi
                mov             rsi, rsp
                mov             rdx, 1
                syscall

                cmp             rax, 1
                jne             .error
                xor             rax, rax
                mov             al, [rsp]
                add             rsp, 1

                pop             rdi
                pop             rcx
                ret
.error:
                mov             rax, -1
                add             rsp, 1
                pop             rdi
                pop             rcx
                ret

; write one char to stdout, errors are ignored
;    al -- char
write_char:
                sub             rsp, 1
                mov             [rsp], al

                mov             rax, 1
                mov             rdi, 1
                mov             rsi, rsp
                mov             rdx, 1
                syscall
                add             rsp, 1
                ret

exit:
                mov             rax, 60
                xor             rdi, rdi
                syscall

; print string to stdout
;    rsi -- string
;    rdx -- size
print_string:
                push            rax

                mov             rax, 1
                mov             rdi, 1
                syscall

                pop             rax
                ret


                section         .rodata
long_integer_size: equ          128
invalid_char_msg:
                db              "Invalid character: "
invalid_char_msg_size: equ             $ - invalid_char_msg
