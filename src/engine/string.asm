newline_string:
.db ch_line_feed
.db ch_carriage_return
.db 0

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
current_string: .dw 0
screen_coords: .dw 0

; Given a sequence of strings starting at HL of length A, print them in a block starting at column B row C
block_print::
    ld (current_string), hl
    ld hl, bc
    ld (screen_coords), hl

    ld hl, block_print_callback
    call iterate_a

    ret

block_print_callback:
    ld hl, (screen_coords)
    call rom_set_cursor
    inc l
    ld (screen_coords), hl

    ld hl, (current_string)
    call print_string
    inc hl ; careful... assumes print_string left HL at the last string's terminator
    ld (current_string), hl

    ret
.endlocal

.macro BLOCK_PRINT &FIRST_STR, &STR_COUNT, &COL, &START_ROW
    ld hl, &FIRST_STR
    ld a, &STR_COUNT
    ld b, &COL
    ld c, &START_ROW
    call block_print
.endm
