
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
    call print_a

loop_continue
    inc hl
    jp loop

compressed_sequence:
    push hl

    ; clear the flag to get an index into the fragment lookup table
    and a, $7f
    ld b, a
    ld a, 2
    ld hl, compressed_string_fragment_table
    call get_array_item

    ld bc, (hl)
    ld hl, bc
    call print_string

    pop hl
    jp loop_continue

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
    call set_cursor_hl
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

.macro BLOCK_PRINT_EXPLORATION_MESSAGE &BLOCK_NAME
    BLOCK_PRINT &BLOCK_NAME, ex_message_col, ex_message_row + 1
.endm
