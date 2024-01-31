.local
menu_address: .dw 0
option_count: .db 0
selected_index: .db 0

menu_address_counter: .dw 0

; Displays a simple menu with data starting at HL of option length A and stores the selected value in A.
; Menu options are defined as a single byte value followed by the two-byte address of a string.
; This is the same format as enums in "enums.asm"
; Destroys all registers
enum_menu_ui::
    ld (menu_address), hl
    ld (menu_address_counter), hl
    ld (option_count), a

    ld b, 0

list_loop:
    ; set cursor to row b+2, column 3
    ld h, 3
    ld a, b
    add a, 2
    ld l, a
    call rom_set_cursor

    ld hl, (menu_address_counter)
    inc hl ; skip value
    ld de, (hl)
    ld hl, de
    call print_string

    ; move up to next option
    ld hl, (menu_address_counter)
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

screen_loop:
    call draw_arrow
read_loop:
    call rom_kyread
    jp z, read_loop

    ON_KEY_JUMP ch_down_arrow, on_down_arrow
    ON_KEY_JUMP ch_s, on_down_arrow
    ON_KEY_JUMP ch_S, on_down_arrow

    ON_KEY_JUMP ch_up_arrow, on_up_arrow
    ON_KEY_JUMP ch_w, on_up_arrow
    ON_KEY_JUMP ch_W, on_up_arrow

    ON_KEY_JUMP ch_enter, on_enter

.macro ENUM_MENU_ARROW_UP_DOWN &LIMIT, &INC_OR_DEC
    cp a, &LIMIT
    jp z, screen_loop

    call clear_arrow
    ld a, (selected_index)
    &INC_OR_DEC a
    ld (selected_index), a

    jp screen_loop
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

on_enter:
    ; find the value of our selected choice
    ld hl, (menu_address)
    ld a, (selected_index)

seek_loop:
    cp a, 0
    jp z, found_index
    inc hl ; skip past all three values.
    inc hl
    inc hl
    dec a
    jp seek_loop

found_index:
    ld a, (hl)
    ret

draw_arrow:
    ld a, (selected_index)
    add 2
    ld l, a
    ld h, 2
    call rom_set_cursor

    ld a, ch_printable_arrow_right
    call rom_print_a
    ret

clear_arrow:
    ld a, (selected_index)
    add 2
    ld l, a
    ld h, 2
    call rom_set_cursor

    ld a, " "
    call rom_print_a

    ret
.endlocal
