.local
header: .asciz "Character Sheet: "

str_label: .asciz "STR"
dex_label: .asciz "DEX"
con_label: .asciz "CON"
int_label: .asciz "INT"
wis_label: .asciz "WIS"
chr_label: .asciz "CHR"

character_loc: .dw 0
counter: .db 0

; Presents the Character Sheet for the character data beginning in HL
; Currently display-only and will exit on keypress.
character_sheet_ui::
    ld (character_loc), hl
    call init_screen

    call rom_chget

    ret

init_screen:
    call rom_clear_screen
    PRINT_AT_LOCATION 1, 1, header

    ld hl, (character_loc)
    ld bc, pl_offs_name
    add hl, bc
    call print_string

    PRINT_AT_LOCATION 2, 1, str_label
    PRINT_AT_LOCATION 3, 1, dex_label
    PRINT_AT_LOCATION 4, 1, con_label
    PRINT_AT_LOCATION 5, 1, int_label
    PRINT_AT_LOCATION 6, 1, wis_label
    PRINT_AT_LOCATION 7, 1, chr_label

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
    ld bc, glob_de_to_hex_str_buffer
    call de_to_hex_str

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

    ret
.endlocal
