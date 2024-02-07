
; combat_row_buffer: .asciz "      "
combat_string_buffer: .asciz "   "
#define enemy_screen_column 1
#define party_screen_column 4
#define combat_start_row 1
#define back_index 1
#define enemy_front_index 2
#define party_front_index 0

combat_draw_player_index: .db 0
draw_combatants:
    ld a, 0
    ld (combat_draw_player_index), a

draw_combatants_loop:
    ; clear the buffer
    ld a, " "
    ld (combat_string_buffer + 0), a
    ld (combat_string_buffer + 1), a
    ld (combat_string_buffer + 2), a

    ; read flags
    ld a, (combat_draw_player_index)
    call get_combatant_at_index_a
    LOAD_A_WITH_ATTR_THROUGH_HL cbt_offs_flags
    ld c, a

    ld b, cbt_flag_line
    and a, b
    jp z, draw_combatant_front
    ; back is same index on either side
    ld a, ch_stick_person_1
    ld (combat_string_buffer + back_index), a
    jp draw_combatants_loop_continue

draw_combatant_front:
    ld a, c
    ld b, cbt_flag_faction
    and a, b
    jp nz, draw_combatant_front_enemy
    ld a, ch_stick_person_1
    ld (combat_string_buffer + party_front_index), a
    jp draw_combatants_loop_continue

draw_combatant_front_enemy:
    ld a, ch_stick_person_1
    ld (combat_string_buffer + enemy_front_index), a

draw_combatants_loop_continue:
    ld a, (combat_draw_player_index)
    ld b, combat_start_row
    add a, b
    ld l, a

    ld a, c
    ld b, cbt_flag_faction
    and a, b
    jp nz, draw_combatant_enemy_column
    ld h, party_screen_column
    jp draw_combatants_loop_print

draw_combatant_enemy_column:
    ld h, enemy_screen_column
    ld a, l
    ld b, 4
    sub a, b
    ld l, a

draw_combatants_loop_print:
    call rom_set_cursor
    ld hl, combat_string_buffer
    call print_string

    ld a, (combat_draw_player_index)
    inc a
    ld (combat_draw_player_index), a
    ld b, a
    ld a, (total_number_of_combatants)
    cp a, b
    jp nz, draw_combatants_loop

    ret
