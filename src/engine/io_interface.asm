newline_string:
.db ch_line_feed
.db ch_carriage_return
.db 0

.local
; Prints the string starting at HL
; Destroys HL, a
print_string::
loop:
    ld a, (hl) ; read character
    cp a, 0    ; if it's zero...
    jp z, return ; ...we're done
    call print_a
    inc hl
    jp loop
return:
    ret
.endlocal

.macro PRINT_AT_LOCATION &ROW, &COL, &STRING_ADDR
    ld h, &COL
    ld l, &ROW
    call set_cursor_hl

    ld hl, &STRING_ADDR
    call print_string
.endm

.macro PRINT_COMPRESSED_AT_LOCATION &ROW, &COL, &STRING_ADDR
    ld h, &COL
    ld l, &ROW
    call set_cursor_hl

    ld hl, &STRING_ADDR
    call print_compressed_string
.endm
