initialize_combatants:
    ld hl, initialize_combatants_foreach_callback
    call for_each_combatant

    ld d, 2
    ld a, (total_number_of_combatants)
    ld bc, initiative_sort_space
    ld hl, initiative_order
    call sort_associative_array

    ld d, 2
    ld a, (total_number_of_combatants)
    ld bc, initiative_sort_space
    ld hl, initiative_order
    call reverse_array

    ret

initiative_result: .db 0
initialize_combatants_foreach_callback:
    ; roll initiative
    ld hl, (foreach_player_address)
    call roll_dexterity_check
    ld (initiative_result), a

    ld hl, (foreach_combat_address)
    ld a, (initiative_result)
    WRITE_A_TO_ATTR_THROUGH_HL cbt_offs_initiative

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

    ld hl, (foreach_player_address)
    call get_character_armor_class
    ld d, a

    ld hl, (foreach_combat_address)
    WRITE_A_TO_ATTR_THROUGH_HL cbt_offs_armor_class

    ld hl, (foreach_player_address)
    call get_hit_points
    ld d, a

    ld hl, (foreach_combat_address)
    ld bc, cbt_offst_hit_points
    add hl, bc
    ld b, 0
    ld c, d
    ld (hl), bc

    ld a, (for_each_combatant_index)
    ld b, a
    ld a, (party_size)
    dec a
    cp a, b
    jp m, init_enemy_combatant

    ld hl, (foreach_combat_address)
    ld a, cbt_initial_party_flags
    WRITE_A_TO_ATTR_THROUGH_HL cbt_offs_flags
    jp initialize_combatants_foreach_callback_done

init_enemy_combatant:
    ld hl, (foreach_combat_address)
    ld a, cbt_initial_enemy_flags
    WRITE_A_TO_ATTR_THROUGH_HL cbt_offs_flags

initialize_combatants_foreach_callback_done:
    ret

display_initiative_order:
    call rom_clear_screen

    PRINT_COMPRESSED_AT_LOCATION 1, 1, initiative_header

    ld a, (total_number_of_combatants)
    ld hl, display_initiative_order_callback
    call iterate_a

    call await_any_keypress
    ret

display_initiative_order_callback:
    ld b, a
    push bc

    ld h, 25
    ld l, a
    inc l
    call rom_set_cursor

    pop bc
    push bc
    ld a, b
    ld b, 2
    ld hl, initiative_order
    call get_array_item
    ld a, (hl)

    ld d, 0
    ld e, a
    call de_to_decimal_string

    ld hl, bc
    call print_string

    pop bc
    push bc
    ld l, b
    inc l
    ld h, 14
    call rom_set_cursor

    pop bc
    ld a, b
    ld b, 2
    ld hl, initiative_order
    call get_array_item
    inc hl
    ld a, (hl)

    call get_character_at_index_a
    POINT_HL_TO_ATTR pl_offs_name
    call print_compressed_string

    ret
