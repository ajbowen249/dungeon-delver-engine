
combat_row_buffer: .asciz "      "
draw_combatants:
    ld a, 0
    ld (general_counter), a

draw_combatants_loop:
    ; blank out the buffer
    ld hl, combat_row_buffer
    ld a, " "
    ld (hl), a
    inc hl
    ld (hl), a
    inc hl
    ld (hl), a
    inc hl
    ld (hl), a
    inc hl
    ld (hl), a
    inc hl
    ld (hl), a
    inc hl

    ; start with player side
    ld a, (general_counter)
    inc a
    ld b, a
    ld a, (party_size)
    cp a, b
    jp m, draw_combatants_loop_enemy_side

    ld a, (general_counter)
    ld b, a
    ld a, cbt_data_length
    ld hl, party_combatants
    call get_array_item

    ld bc, cbt_offs_flags
    add hl, bc
    ld a, (hl)

    ld b, $04
    and a, b
    cp a, 0
    ; flag $04 set for player means index 4, reset is 3
    jp z, draw_combatants_player_front
    ld d, 4
    jp draw_combatants_player_continue
draw_combatants_player_front:
    ld d, 3

draw_combatants_player_continue:
    ld hl, combat_row_buffer
    ld b, 0
    ld c, d
    add hl, bc
    ld a, ch_stick_person_1
    ld (hl), a

draw_combatants_loop_enemy_side:
    ; now do enemies
    ld a, (general_counter)
    inc a
    ld b, a
    ld a, (enemy_party_size)
    cp a, b
    jp m, draw_combatants_continue

    ld a, (general_counter)
    ld b, a
    ld a, cbt_data_length
    ld hl, enemy_combatants
    call get_array_item

    ld bc, cbt_offs_flags
    add hl, bc
    ld a, (hl)

    ld b, $04
    and a, b
    cp a, 0
    ; flag $04 set for enemy means index 1, reset is 2
    ; (opposite of player side)
    jp z, draw_combatants_enemy_front
    ld d, 1
    jp draw_combatants_loop_enemy_continue
draw_combatants_enemy_front:
    ld d, 2
draw_combatants_loop_enemy_continue:
    ld hl, combat_row_buffer
    ld b, 0
    ld c, d
    add hl, bc
    ld a, ch_stick_person_1
    ld (hl), a

draw_combatants_continue:
    ld a, (general_counter)
    ld b, combatants_first_row
    add a, b
    ld h, 1
    ld l, a
    call rom_set_cursor

    ld hl, combat_row_buffer
    call print_string

    ld a, (general_counter)
    inc a
    ld (general_counter), a
    cp a, 4
    jp nz, draw_combatants_loop

    ret
