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
    call rom_print_a
    inc hl
    jp loop
return:
    ret
.endlocal

.local
; Prints the compressed string starting at HL
; Destroys HL, a, bc
print_compressed_string::
loop:
    ld a, (hl)
    cp a, 0
    jp z, return

    ld b, a
    and a, $80
    cp a, 0
    ld a, b
    jp nz, compressed_sequence

    ; it's just a regular character
    call rom_print_a
    inc hl
    jp loop

compressed_sequence:
    push hl

    ld bc, (hl)
    ; the pointer is stored big-endian so the flag can live in the MSB
    ; we don't need to clear the flag, since we load at $b200 and we know it'll always be set anyway
    ld h, c
    ld l, b
    call print_string

    pop hl
    inc hl
    inc hl
    jp loop

return:
    ret
.endlocal

.local
current_string: .dw 0
screen_coords: .dw 0

; Given a sequence of compressed strings starting at HL of length A, print them in a block starting at column B row C
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
    call print_compressed_string
    inc hl ; careful... assumes print_compressed_string left HL at the last string's terminator
    ld (current_string), hl

    ret
.endlocal

.macro BLOCK_PRINT &BLOCK_NAME, &COL, &START_ROW
    ld hl, &BLOCK_NAME
    ld a, &BLOCK_NAME_lines
    ld b, &COL
    ld c, &START_ROW
    call block_print
.endm
