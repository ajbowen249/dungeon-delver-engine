.local

character_loc: .dw 0
counter: .db 0

enum_buffer:  .asciz "          "

; Presents the Character Sheet for the character data beginning in HL
; Currently display-only and will exit on keypress.
character_sheet_ui::
    ld (character_loc), hl
    call init_screen

read_loop:
    call rom_kyread
    jp z, read_loop

    ret

init_screen:
    call rom_clear_screen
    PRINT_COMPRESSED_AT_LOCATION 1, 1, character_sheet_header

    ld hl, (character_loc)
    ld bc, pl_offs_name
    add hl, bc
    call print_compressed_string

    PRINT_COMPRESSED_AT_LOCATION 2, 1, str_label
    PRINT_COMPRESSED_AT_LOCATION 3, 1, dex_label
    PRINT_COMPRESSED_AT_LOCATION 4, 1, con_label
    PRINT_COMPRESSED_AT_LOCATION 5, 1, int_label
    PRINT_COMPRESSED_AT_LOCATION 6, 1, wis_label
    PRINT_COMPRESSED_AT_LOCATION 7, 1, chr_label

    ld a, 0
    ld (counter), a
stats_loop:

    ld hl, (character_loc)
    ld b, 0
    ld a, (counter)
    ld c, a
    add hl, bc
    ld a, (hl)

    ld d, 0
    ld e, a
    call de_to_decimal_string

    ld h, 5
    ld a, (counter)
    add a, 2
    ld l, a
    call rom_set_cursor

    ld hl, bc
    call print_string

    ld a, (counter)
    inc a
    ld (counter), a

    cp 6
    jp nz, stats_loop

    ; print race
    ld h, 10
    ld l, 2
    call rom_set_cursor

    ld hl, (character_loc)
    ld bc, pl_offs_race
    add hl, bc

    ld a, (hl)
    ld hl, opt_race
    call get_option_label

    ld hl, bc
    ld bc, (hl)
    ld hl, bc
    call print_compressed_string

    ; print class
    ld h, 10
    ld l, 3
    call rom_set_cursor

    ld hl, (character_loc)
    ld bc, pl_offs_class
    add hl, bc

    ld a, (hl)
    ld hl, opt_class
    call get_option_label

    ld hl, bc
    ld bc, (hl)
    ld hl, bc
    call print_compressed_string

    ld hl, str_lvl
    call print_compressed_string

    ld hl, (character_loc)
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_level
    ld d, 0
    ld e, a
    call de_to_decimal_string
    ld hl, bc
    call print_string

    ret
.endlocal
