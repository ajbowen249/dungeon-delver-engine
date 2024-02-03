
; combat_row_buffer: .asciz "      "
combat_string_buffer: .asciz "   "

draw_combatants:
    call draw_party_combatants
    call draw_enemy_combatants
    ret

.macro DRAW_COMBATANTS_SIDE &SIDE, &SIZE_FIELD, &BLANK_INDEX, &FRONT_INDEX, &BACK_INDEX, &COLUMN

draw_&SIDE_combatants:
    ld a, 0
    ld (general_counter), a

draw_&SIDE_combatants_loop:
    ld a, " "
    ld (combat_string_buffer + &BLANK_INDEX), a

    ld hl, &SIDE_combatants
    ld b, cbt_data_length
    ld a, (general_counter)
    call get_array_item
    ld b, 0
    ld c, cbt_offs_flags
    add hl, bc

    ld a, (hl)
    ld b, $04
    and a, b
    jp z, draw_&SIDE_front
    ld a, ch_stick_person_1
    ld (combat_string_buffer + &BACK_INDEX), a
    jp draw_&SIDE_continue

draw_&SIDE_front:
    ld a, ch_stick_person_1
    ld (combat_string_buffer + &FRONT_INDEX), a
draw_&SIDE_continue:

    ld a, (general_counter)
    inc a
    inc a
    ld l, a
    ld h, &COLUMN
    call rom_set_cursor
    ld hl, combat_string_buffer
    call print_string

    ld a, (general_counter)
    inc a
    ld (general_counter), a
    ld b, a
    ld a, (&SIZE_FIELD)
    cp a, b
    jp nz, draw_&SIDE_combatants_loop

    ret

.endm

    DRAW_COMBATANTS_SIDE party, party_size, 2, 0, 1, 4
    DRAW_COMBATANTS_SIDE enemy, enemy_party_size, 0, 2, 1, 1
