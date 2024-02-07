newline_string:
.db 10
.db 13
.db 0

glob_de_to_hex_str_buffer: .asciz "    "

.macro PRINT_AT_LOCATION &ROW, &COL, &STRING_ADDR
    ld h, &COL
    ld l, &ROW
    call rom_set_cursor

    ld hl, &STRING_ADDR
    call print_string
.endm

; Prints the string starting at HL
; Destroys HL, a
.local
print_string::
loop:
    ld a, (hl) ; read character
    cp a, 0    ; if it's zero...
    jp z, return ; ...we're done
    call rom_print_a
    inc hl
    jp loop
return:
    ret
.endlocal

.local
; Writes the hex string value of DE to the buffer starting at BC
; Destroys A and HL
de_to_hex_str::
    ld hl, bc ; use HL as the counter to BC is still usable after this
    ld a, d
    rra ; shift upper nibble to lower
    rra
    rra
    rra
    and $0F ; mask off rotated-in nibble
    call write_a_to_hl

    ld a, d
    and $0F ; mask off upper nibble
    call write_a_to_hl

    ld a, e
    rra ; shift upper nibble to lower
    rra
    rra
    rra
    and $0F ; mask off rotated-in nibble
    call write_a_to_hl

    ld a, e
    and $0F ; mask off upper nibble
    call write_a_to_hl

    ld (hl), 0 ; null terminator

    ret

; (Local to de_to_hex_str) writes the hex character for A to HL
write_a_to_hl:
    cp 10
    jp m, char_0_9
    add 55 ; ascii A is 65, but we're already at at least 10
    jp save_char

char_0_9:
    add 48 ; ascii 0 is 48
save_char:
    ld (hl), a
    inc hl
    ret
.endlocal

.local

decimal_buffer:
decimal_char_2: .db 0
decimal_char_1: .db 0
decimal_char_0: .db 0
decimal_string_terminator: .db 0

; converts the 16-bit number in DE to a 3-character string starting at BC
; Note: Pretty slow in theory; uses counting rules to increment the number into place to get around division
de_to_decimal_string::
    ; init buffer
    ld a, 0
    ld (decimal_char_2), a
    ld (decimal_char_1), a
    ld (decimal_char_0), a

    ; first convert to BCD
decimal_count_loop:
    ld a, d
    cp a, 0
    jp nz, decimal_loop_inc
    ld a, e
    cp a, 0
    jp nz, decimal_loop_inc
    jp decimal_count_loop_end

decimal_loop_inc:
    ld hl, decimal_char_0
    ld a, (hl)
    inc a
    cp a, 10
    jp nz, increment_decimal_end
    ld a, 0
    ld (hl), a

    dec hl
    ld a, (hl)
    inc a
    cp a, 10
    jp nz, increment_decimal_end

    ld a, 0
    ld (hl), a

    dec hl
    ld a, (hl)
    inc a

increment_decimal_end:
    ld (hl), a

    dec de
    jp decimal_count_loop

decimal_count_loop_end:
    ; Number is now in BCD, so convert to ASCII
    ld a, (decimal_char_0)
    add a, $30
    ld (decimal_char_0), a

    ld a, (decimal_char_1)
    add a, $30
    ld (decimal_char_1), a

    ld a, (decimal_char_2)
    add a, $30
    ld (decimal_char_2), a

    ld bc, decimal_buffer
    ret

.endlocal
