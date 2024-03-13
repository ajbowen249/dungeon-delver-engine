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

    ld a, (decimal_char_2)
    cp a, "0"
    jp nz, string_ready

    ld a, " "
    ld (decimal_char_2), a

    ld a, (decimal_char_1)
    cp a, "0"
    jp nz, string_ready

    ld a, " "
    ld (decimal_char_1), a

string_ready:
    ld bc, decimal_buffer
    ret

.endlocal
