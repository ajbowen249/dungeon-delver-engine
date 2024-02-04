initiative_header: .asciz "Initiative:"

initialize_combatants:
    ld hl, initialize_combatants_foreach_callback
    call for_each_combatant

    ld d, 2
    ld a, (total_number_of_combatants)
    ld bc, initiative_sort_space
    ld hl, initiative_order
    call sort_associative_array

    ret

initiative_result: .db 0
initialize_combatants_foreach_callback:
    ; roll initiative
    ld hl, (foreach_player_address)
    call roll_dexterity_check
    ld (initiative_result), a

    ld hl, (foreach_combat_address)
    ld b, 0
    ld c, cbt_offs_initiative
    add hl, bc
    ld a, (initiative_result)
    ld (hl), a

    ; save initiative for future sort
    ld a, (for_each_combatant_index)
    ld b, 2
    ld hl, initiative_order
    call get_array_item

    ld a, (initiative_result)
    ld (hl), a
    inc hl
    ld a, (for_each_combatant_index)
    ld (hl), a

    ld hl, (foreach_combat_address)
    ld b, 0
    ld c, cbt_offst_hit_points
    add hl, bc
    ld b, 0
    ld c, 20 ; TODO: Get from class+level
    ld (hl), bc

    ld b, a
    ld a, (party_size)
    dec a
    cp a, b
    jp m, init_enemy_combatant

    ld hl, (foreach_combat_address)
    ld b, 0
    ld c, cbt_offs_flags
    add hl, bc
    ld a, cbt_initial_party_flags
    ld (hl), a
    jp initialize_combatants_foreach_callback_done

init_enemy_combatant:
    ld hl, (foreach_combat_address)
    ld b, 0
    ld c, cbt_offs_flags
    add hl, bc
    ld a, cbt_initial_enemy_flags
    ld (hl), a

initialize_combatants_foreach_callback_done:
    ret


initiative_counter: .db 0
display_initiative_order:
    call rom_clear_screen

    PRINT_AT_LOCATION 1, 1, initiative_header

    ld a, 0
    ld (initiative_counter), a

display_initiative_order_loop:
    ld a, (initiative_counter)
    inc a

    ld h, 24
    ld l, a
    call rom_set_cursor

    ld hl, initiative_order
    ld a, (initiative_counter)
    ld b, 2
    call get_array_item
    ld a, (hl)

    ld d, 0
    ld e, a
    call de_to_decimal_string

    ld hl, bc
    call print_string

    ld a, (initiative_counter)
    inc a

    ld h, 14
    ld l, a
    call rom_set_cursor

    ld hl, initiative_order
    ld a, (initiative_counter)
    ld b, 2
    call get_array_item
    inc hl
    ld a, (hl)

    call get_character_at_index_a
    ld b, 0
    ld c, pl_offs_name
    add hl, bc
    call print_string

    ld a, (initiative_counter)
    inc a
    ld (initiative_counter), a
    ld b, a
    ld a, (total_number_of_combatants)
    cp a, b
    jp nz, display_initiative_order_loop

initiative_order_wait_loop:
    call rom_kyread
    jp z, initiative_order_wait_loop

    ret
