.local

character_loc: .dw 0
counter: .db 0

; Presents the Character Sheet for the character data beginning in HL
; Currently display-only and will exit on keypress.
character_sheet_ui::
    ld (character_loc), hl
    call init_screen

read_loop:
    call rom_kyread
    jp z, read_loop

    ret

print_label_callback:
    ld b, a
    push bc

    ld h, 1
    add a, 2
    ld l, a
    call rom_set_cursor

    ld hl, skill_labels
    pop bc
    ld a, 4
    call get_array_item

    call print_compressed_string

    ret

init_screen:
    call rom_clear_screen
    PRINT_COMPRESSED_AT_LOCATION 1, 1, character_sheet_header

    ld hl, (character_loc)
    ld bc, pl_offs_name
    add hl, bc
    call print_compressed_string

    ld a, 6
    ld hl, print_label_callback
    call iterate_a

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

    ld h, 10
    ld l, 5
    call rom_set_cursor

    ld hl, hp_string
    call print_compressed_string

    ld hl, (character_loc)
    call get_hit_points

    ld d, 0
    ld e, a
    call de_to_decimal_string
    ld hl, bc
    call print_string

    ld h, 10
    ld l, 6
    call rom_set_cursor

    ld hl, ac_string
    call print_compressed_string

    ld hl, (character_loc)
    call get_character_armor_class

    ld d, 0
    ld e, a
    call de_to_decimal_string
    ld hl, bc
    call print_string

    ret
.endlocal
