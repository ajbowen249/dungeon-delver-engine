#include "./consolidate_menu.asm"

; loads BC to set the enum menu at column 2, row 2
.macro LOAD_ENUM_MENU_DEFAULT_COORDS
    ld bc, $0202
.endm


.local
menu_address: .dw 0
option_count: .db 0
selected_index: .db 0
should_exit: .db 0
selected_value: .db 0

menu_address_counter: .dw 0
menu_column: .db 0
menu_row: .db 0

; Displays a simple menu with data starting at HL of option length A and stores the selected value in A.
; The menu is rendered starting at column, row BC. The column is the column where the arrow is drawn, and the text is
; one column to the right of that.
; Menu options are defined as a single byte value followed by the two-byte address of a string.
; This is the same format as enums in "enums.asm"
; Destroys all registers
menu_ui::
    ld (menu_address), hl
    ld (menu_address_counter), hl
    ld (option_count), a
    ld a, b
    ld (menu_column), a
    ld a, c
    ld (menu_row), a

    ld b, 0

list_loop:
    ld a, (menu_column)
    ld h, a
    inc h ; one column to the right of the arrow
    ld a, (menu_row)
    add a, b
    ld l, a
    call rom_set_cursor

    ld hl, (menu_address_counter)
    inc hl ; skip value

    ; IMPROVE: For now, just skip printing if it's disabled and disallow selection
    ld a, (hl)
    ld c, $01
    and a, c
    cp a, 0
    jp z, list_loop_continue

    inc hl ; pass flags
    ld de, (hl)
    ld hl, de
    call print_string

list_loop_continue:
    ; move up to next option
    ld hl, (menu_address_counter)
    inc hl
    inc hl
    inc hl
    inc hl
    ld (menu_address_counter), hl

    inc b
    ld a, (option_count)
    cp b
    jp nz, list_loop

    ld a, 0
    ld (selected_index), a
    ld (should_exit), a
    ld (selected_value), a

    REGISTER_INPUTS on_up_arrow, on_down_arrow, 0, 0, on_confirm, 0, 0

    call draw_arrow
read_loop:
    call iterate_input_table

    ld a, (should_exit)
    cp a, 0
    jp z, read_loop

    ld a, (selected_value)
    ret


.macro ENUM_MENU_ARROW_UP_DOWN &LIMIT, &INC_OR_DEC
    cp a, &LIMIT
    jp z, arrow_&INC_OR_DEC_exit

    call clear_arrow
    ld a, (selected_index)
    &INC_OR_DEC a
    ld (selected_index), a
    call draw_arrow

arrow_&INC_OR_DEC_exit:
    ret
.endm

on_down_arrow:
    ld a, (selected_index)
    ld b, a
    ld a, (option_count)
    dec a ; because max index is option_count - 1

    ENUM_MENU_ARROW_UP_DOWN b, inc

on_up_arrow:
    ld a, (selected_index)
    ENUM_MENU_ARROW_UP_DOWN 0, dec

on_confirm:
    ld hl, (menu_address)
    ld a, (selected_index)
    ld b, mi_data_size
    call get_array_item
    ld de, hl

    LOAD_A_WITH_ATTR_THROUGH_HL mi_offs_flags
    ld b, $01
    and a, b
    jp z, on_confirm_exit

    ld hl, de
    ld a, (hl)
    ld (selected_value), a

    ld a, 1
    ld (should_exit), a

on_confirm_exit:
    ret

draw_arrow:
    ld a, (selected_index)
    ld b, a
    ld a, (menu_row)
    add a, b
    ld l, a
    ld a, (menu_column)
    ld h, a
    call rom_set_cursor

    ld a, ch_printable_arrow_right
    call rom_print_a
    ret

clear_arrow:
    ld a, (selected_index)
    ld b, a
    ld a, (menu_row)
    add a, b
    ld l, a
    ld a, (menu_column)
    ld h, a
    call rom_set_cursor

    ld a, " "
    call rom_print_a

    ret
.endlocal

; Helpers for other things using menu options
.local
; Sets the address of the label portion of the enum in HL with the value in A to BC
get_option_label::
    ld b, a

search:
    ld a, (hl)

    cp a, b
    jp z, found
    inc hl
    inc hl
    inc hl
    inc hl
    jp search

found:
    inc hl
    inc hl
    ld bc, hl
    ret
.endlocal
