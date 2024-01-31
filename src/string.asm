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
