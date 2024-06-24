combat_string_buffer: .asciz "   "
#define enemy_screen_column 1
#define party_screen_column 4
#define combat_start_row 1
#define back_index 1
#define enemy_front_index 2
#define party_front_index 0

combat_draw_player_sprite: .db 0
draw_combatants:
    ld a, (total_number_of_combatants)
    ld hl, draw_combatants_callback
    call iterate_a
    ret

draw_combatants_callback:
    ld b, a
    push bc

    ; clear the buffer
    ld a, " "
    ld (combat_string_buffer + 0), a
    ld (combat_string_buffer + 1), a
    ld (combat_string_buffer + 2), a

    ; read flags
    pop bc
    push bc
    ld a, b
    call get_combatant_at_index_a
    LOAD_A_WITH_ATTR_THROUGH_HL cbt_offs_flags
    ld c, a

    ld b, cbt_flag_alive
    and a, b
    jp z, draw_dead

    ld a, ch_stick_person_1
    ld (combat_draw_player_sprite), a
    jp check_line

draw_dead:
    ld a, ch_cross
    ld (combat_draw_player_sprite), a
    jp check_line

check_line:
    ld a, c
    ld b, cbt_flag_line
    and a, b
    jp z, draw_combatant_front
    ; back is same index on either side
    ld a, (combat_draw_player_sprite)
    ld (combat_string_buffer + back_index), a
    jp draw_combatants_continue

draw_combatant_front:
    ld a, c
    ld b, cbt_flag_faction
    and a, b
    jp nz, draw_combatant_front_enemy
    ld a, (combat_draw_player_sprite)
    ld (combat_string_buffer + party_front_index), a
    jp draw_combatants_continue

draw_combatant_front_enemy:
    ld a, (combat_draw_player_sprite)
    ld (combat_string_buffer + enemy_front_index), a

draw_combatants_continue:
    ld hl, 1
    add hl, sp
    ld a, (hl)
    ld b, combat_start_row
    add a, b
    ld l, a

    ld a, c
    ld b, cbt_flag_faction
    and a, b
    jp nz, draw_combatant_enemy_column
    ld h, party_screen_column
    jp draw_combatants_print

draw_combatant_enemy_column:
    ld h, enemy_screen_column
    ld a, (party_size)
    ld b, a
    ld a, l
    sub a, b
    ld l, a

draw_combatants_print:
    call set_cursor_hl
    ld hl, combat_string_buffer
    call print_string

    pop bc
    ret
