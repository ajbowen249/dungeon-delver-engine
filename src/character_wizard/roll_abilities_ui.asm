.local
header: .asciz "Roll Abilities"
total_label:     .asciz "    Total: "
remaining_label: .asciz "Remaining: "
re_roll_label:   .asciz "    R: Re-Roll"
continue_label:  .asciz "Enter: Continue"

str_label: .asciz "    Strength"
dex_label: .asciz "   Dexterity"
con_label: .asciz "Constitution"
int_label: .asciz "Intelligence"
wis_label: .asciz "      Wisdom"
chr_label: .asciz "    Charisma"

#define abilities_first_row 2
#define abilities_column 16

ability_values:
str_val: .db 0
dex_val: .db 0
con_val: .db 0
int_val: .db 0
wis_val: .db 0
chr_val: .db 0

remaining_points: .db 0

ability_index: .db 0
ability_roll_total: .db 0

; rolls abilities for a new character
; At exit, HL is set to the beginning of the Abilities array
roll_abilities_ui::
    call init_screen ; Everything from here is a modification to what this draws
    call update_points

    ld a, 0
    ld (ability_index), a

screen_loop:
    call draw_arrows
read_loop:
    call rom_kyread
    jp z, read_loop

    ON_KEY_JUMP ch_down_arrow, on_down_arrow
    ON_KEY_JUMP ch_s, on_down_arrow
    ON_KEY_JUMP ch_S, on_down_arrow

    ON_KEY_JUMP ch_up_arrow, on_up_arrow
    ON_KEY_JUMP ch_w, on_up_arrow
    ON_KEY_JUMP ch_W, on_up_arrow

    ON_KEY_JUMP ch_left_arrow, on_left_arrow
    ON_KEY_JUMP ch_a, on_left_arrow
    ON_KEY_JUMP ch_A, on_left_arrow

    ON_KEY_JUMP ch_right_arrow, on_right_arrow
    ON_KEY_JUMP ch_d, on_right_arrow
    ON_KEY_JUMP ch_D, on_right_arrow

    ON_KEY_JUMP ch_R, roll_abilities_ui
    ON_KEY_JUMP ch_r, roll_abilities_ui

    ON_KEY_JUMP ch_enter, exit_ability_ui

    jp screen_loop

.macro ROLL_ABILITIES_ARROW_UP_DOWN &LIMIT, &INC_OR_DEC
    ld a, (ability_index)
    cp a, &LIMIT
    jp z, screen_loop
    call clear_arrows

    ld a, (ability_index)
    &INC_OR_DEC a
    ld (ability_index), a

    jp screen_loop
.endm

on_down_arrow:
    ROLL_ABILITIES_ARROW_UP_DOWN 5, inc

on_up_arrow:
    ROLL_ABILITIES_ARROW_UP_DOWN 0, dec

on_left_arrow:
    ; can't decrement if 0
    ld hl, ability_values
    ld a, (ability_index)
    ld b, 0
    ld c, a
    add hl, bc
    ld a, (hl)

    cp 0
    jp z, screen_loop

    dec a
    ld (hl), a

    ld a, (remaining_points)
    inc a
    ld (remaining_points), a

    call update_points

    jp screen_loop

on_right_arrow:
    ; can't increment if 20
    ld hl, ability_values
    ld a, (ability_index)
    ld b, 0
    ld c, a
    add hl, bc
    ld a, (hl)

    cp ability_max_value
    jp z, screen_loop

    ld b, a ; save ability value since we're about to check remaining

    ; don't increment if we have no points to pull from
    ld a, (remaining_points)
    cp 0
    jp z, screen_loop

    dec a
    ld (remaining_points), a

    ld a, b
    inc a
    ld (hl), a

    call update_points

    jp screen_loop

exit_ability_ui:
    ; give the caller the location of our abilities array
    ld hl, ability_values
    ret

draw_arrows:
    ld a, (ability_index)
    ld b, abilities_first_row
    add b
    ld l, a

    ld h, abilities_column - 1
    call rom_set_cursor

    ld a, ch_printable_arrow_left
    call rom_print_a

    ld h, abilities_column + 4
    ; l should still have row
    call rom_set_cursor

    ld a, ch_printable_arrow_right
    call rom_print_a

    ret

clear_arrows:
    ld a, (ability_index)
    ld b, abilities_first_row
    add b
    ld l, a

    ld h, abilities_column - 1
    call rom_set_cursor

    ld a, " "
    call rom_print_a

    ld h, abilities_column + 4
    ; l should still have row
    call rom_set_cursor

    ld a, " "
    call rom_print_a

    ret

init_screen:
    call rom_clear_screen

    ; draw static labels
    PRINT_AT_LOCATION 1, 1, header
    PRINT_AT_LOCATION abilities_first_row, abilities_column + 6, total_label
    PRINT_AT_LOCATION abilities_first_row + 1, abilities_column + 6, remaining_label

    PRINT_AT_LOCATION abilities_first_row + 3, abilities_column + 6, re_roll_label
    PRINT_AT_LOCATION abilities_first_row + 4, abilities_column + 6, continue_label

    PRINT_AT_LOCATION abilities_first_row + 0, 2, str_label
    PRINT_AT_LOCATION abilities_first_row + 1, 2, dex_label
    PRINT_AT_LOCATION abilities_first_row + 2, 2, con_label
    PRINT_AT_LOCATION abilities_first_row + 3, 2, int_label
    PRINT_AT_LOCATION abilities_first_row + 4, 2, wis_label
    PRINT_AT_LOCATION abilities_first_row + 5, 2, chr_label

    ; Initialize ability scores
    ld a, 0

roll_loop:
    ld (ability_index), a
    ; You're supposed to roll 4 and add the highest 3. Just gonna roll 3 for simplicity for now.
    call roll_d6
    ld a, l
    ld (ability_roll_total), a
    call roll_d6
    ld a, (ability_roll_total)
    add l
    ld (ability_roll_total), a
    call roll_d6
    ld a, (ability_roll_total)
    add l

    ld d, a

    ld b, 0
    ld a, (ability_index)
    ld c, a

    ld hl, ability_values
    add hl, bc

    ld (hl), d

    inc a
    cp 6

    jp nz, roll_loop

    ld a, 0
    ld (remaining_points), a

    ld hl, ability_values
    ld b, 0
    ld c, 0
total_loop:
    ld a, (hl)
    add a, b
    ld b, a
    inc hl
    ld a, c
    inc a
    cp 6
    ld c, a
    jp nz, total_loop

    ld a, b
    ld (ability_roll_total), a
    ld d, 0
    ld e, a
    ld bc, glob_de_to_hex_str_buffer
    call de_to_hex_str
    PRINT_AT_LOCATION abilities_first_row, abilities_column + 17, glob_de_to_hex_str_buffer

.macro PRINT_ABILITY_SCORE &VALUE, &ROW
    ld d, 0
    ld a, (&VALUE)
    ld e, a
    ld bc, glob_de_to_hex_str_buffer
    call de_to_hex_str

    PRINT_AT_LOCATION &ROW, abilities_column, glob_de_to_hex_str_buffer
.endm

    PRINT_ABILITY_SCORE str_val, 2
    PRINT_ABILITY_SCORE dex_val, 3
    PRINT_ABILITY_SCORE con_val, 4
    PRINT_ABILITY_SCORE int_val, 5
    PRINT_ABILITY_SCORE wis_val, 6
    PRINT_ABILITY_SCORE chr_val, 7

    ret

update_points:
    ; move to current cell
    ld a, (ability_index)
    ld b, abilities_first_row
    add b
    ld l, a

    ld h, abilities_column
    call rom_set_cursor

    ; load ability value
    ld hl, ability_values
    ld a, (ability_index)
    ld b, 0
    ld c, a
    add hl, bc
    ld a, (hl)

    ; ability value to string
    ld d, 0
    ld e, a
    ld bc, glob_de_to_hex_str_buffer
    call de_to_hex_str

    ld hl, glob_de_to_hex_str_buffer
    call print_string

    ; move to remaining points position
    ld h, abilities_column + 17
    ld l, abilities_first_row + 1
    call rom_set_cursor

    ; load remaining points
    ld a, (remaining_points)
    ld d, 0
    ld e, a
    ld bc, glob_de_to_hex_str_buffer
    call de_to_hex_str

    ld hl, glob_de_to_hex_str_buffer
    call print_string

    ret
.endlocal
