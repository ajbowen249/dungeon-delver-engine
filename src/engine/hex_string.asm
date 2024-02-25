glob_de_to_hex_str_buffer: .asciz "    "

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
; parses A into its numeric value
parse_a_as_hex_digit::
    ; ascii 0-9 is 48-57. A-F is 65-70
    cp a, 58
    jp m, val_0_9

    ; it's A-F. Only subtract 55 (not 65) since A is 10
    sub a, 55
    ret

val_0_9:
    sub a, 48
    ret
.endlocal
