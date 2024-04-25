.local
#define abilities_first_row 2
#define abilities_column 16

ability_values:
str_val: .db 0
dex_val: .db 0
con_val: .db 0
int_val: .db 0
wis_val: .db 0
chr_val: .db 0

padded_ability_label_pointers:
.dw padded_str_label
.dw padded_dex_label
.dw padded_con_label
.dw padded_int_label
.dw padded_wis_label
.dw padded_chr_label

remaining_points: .db 0

ability_index: .db 0
ability_roll_total: .db 0

should_exit: .db 0

; rolls abilities for a new character
; At exit, HL is set to the beginning of the Abilities array
roll_abilities_ui::
    call init_screen ; Everything from here is a modification to what this draws
    call update_points

    ld a, 0
    ld (ability_index), a
    ld (should_exit), a

    REGISTER_INPUTS on_up_arrow, on_down_arrow, on_left_arrow, on_right_arrow, on_confirm, 0, on_btn_1, 0

screen_loop:
    call draw_arrows
    call iterate_input_table

    ld a, (should_exit)
    cp a, 0
    jp z, screen_loop

    ; give the caller the location of our abilities array
    ld hl, ability_values
    ret

.macro ROLL_ABILITIES_ARROW_UP_DOWN &LIMIT, &INC_OR_DEC
    ld a, (ability_index)
    cp a, &LIMIT
    jp z, ON_&INC_OR_DEC_END
    call clear_arrows

    ld a, (ability_index)
    &INC_OR_DEC a
    ld (ability_index), a

ON_&INC_OR_DEC_END:
    ret
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

    cp 1
    jp z, on_left_arrow_end

    dec a
    ld (hl), a

    ld a, (remaining_points)
    inc a
    ld (remaining_points), a

    call update_points

on_left_arrow_end:
    ret

on_right_arrow:
    ; can't increment if 20
    ld hl, ability_values
    ld a, (ability_index)
    ld b, 0
    ld c, a
    add hl, bc
    ld a, (hl)

    cp ability_max_value
    jp z, on_right_arrow_end

    ld b, a ; save ability value since we're about to check remaining

    ; don't increment if we have no points to pull from
    ld a, (remaining_points)
    cp 0
    jp z, on_right_arrow_end

    dec a
    ld (remaining_points), a

    ld a, b
    inc a
    ld (hl), a

    call update_points

on_right_arrow_end:
    ret

on_confirm:
    ld a, 1
    ld (should_exit), a
    ret

on_btn_1:
    call init_screen
    call update_points
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

    ld h, abilities_column + 3
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

    ld h, abilities_column + 3
    ; l should still have row
    call rom_set_cursor

    ld a, " "
    call rom_print_a

    ret

print_ability_label_callback:
    ld b, 0
    ld c, a
    push bc

    ld h, 2
    ld l, abilities_first_row
    add a, l
    ld l, a
    call rom_set_cursor

    pop bc
    ld a, c
    ld b, 2
    call mul_a_b
    ld hl, padded_ability_label_pointers
    ld b, 0
    ld c, a
    add hl, bc
    ld bc, (hl)
    ld hl, bc
    call print_compressed_string

    ret

init_screen:
    call rom_clear_screen

    ; draw static labels
    PRINT_COMPRESSED_AT_LOCATION 1, 1, roll_abilities_header
    PRINT_COMPRESSED_AT_LOCATION abilities_first_row, abilities_column + 6, padded_total_label
    PRINT_COMPRESSED_AT_LOCATION abilities_first_row + 1, abilities_column + 6, remaining_label

    PRINT_COMPRESSED_AT_LOCATION abilities_first_row + 3, abilities_column + 6, padded_re_roll_label
    PRINT_COMPRESSED_AT_LOCATION abilities_first_row + 4, abilities_column + 6, enter_to_continue_label

    ld a, 6
    ld hl, print_ability_label_callback
    call iterate_a

    ; Initialize ability scores
    ld a, 0

roll_loop:
    ld (ability_index), a
    ; You're supposed to roll 4 and add the highest 3. Just gonna roll 3 for simplicity for now.
    ld a, 6
    ld b, 3
    call roll_b_a

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
    call de_to_decimal_string
    PRINT_AT_LOCATION abilities_first_row, abilities_column + 17, bc

    ld a, 6
    ld hl, print_ability_score_callback
    call iterate_a

    ret

print_ability_score_callback:
    ld b, 0
    ld c, a
    push bc

    ld h, abilities_column
    add a, 2
    ld l, a
    call rom_set_cursor

    pop bc
    ld hl, ability_values
    add hl, bc
    ld a, (hl)
    ld d, 0
    ld e, a
    call de_to_decimal_string
    ld hl, bc
    call print_string

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
    call de_to_decimal_string

    ld hl, bc
    call print_string

    ; move to remaining points position
    ld h, abilities_column + 17
    ld l, abilities_first_row + 1
    call rom_set_cursor

    ; load remaining points
    ld a, (remaining_points)
    ld d, 0
    ld e, a
    call de_to_decimal_string

    ld hl, bc
    call print_string

    ret
.endlocal
