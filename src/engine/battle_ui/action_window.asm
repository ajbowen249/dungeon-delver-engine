#include "./battle_menu_options.asm"

should_end_turn: .db 0
current_menu_address: .dw 0
current_menu_option_count: .db 0
character_in_turn: .dw 0
menu_proc_func: .dw 0

; shows menus needed for the player to take actions on their turn, and returns when their turn is over
execute_player_turn:
    call get_combatant_in_turn
    LOAD_A_WITH_ATTR_THROUGH_HL cbt_offs_flags
    ld b, cbt_flag_alive
    and a, b
    jp nz, continue_turn

    ret

continue_turn:
    ; enable all options since this is the start of the turn
    ld a, default_options_flags
    ld (bm_root_attack_flags), a
    ld (bm_root_cast_flags), a
    ld (bm_root_move_flags), a

    ld a, 0
    ld (should_end_turn), a

    call get_character_in_turn
    ld (character_in_turn), hl

    call is_party_turn
    jp nz, enemy_turn

    call set_up_root_menu
menu_loop:
    call clear_action_window
    call draw_combatants
    call show_selected_menu
    ld hl, (menu_proc_func)
    call call_hl

    ld a, (should_end_turn)
    cp a, 0
    jp z, menu_loop
    ret

enemy_turn:
    call clear_action_window
    call print_turn_header

    call get_combatant_in_turn
    LOAD_A_WITH_ATTR_THROUGH_HL cbt_offs_flags
    ld b, $04
    and a, b
    cp a, 0
    jp z, enemy_turn_pick_target ; already up front

    ld hl, (character_in_turn)
    call should_enemy_move_front
    cp a, 0
    jp z, enemy_turn_pick_target ; shouldn't move up

    call handle_move

enemy_turn_pick_target:
    call pick_automatic_target
    ld b, a
    push bc
    call get_combatant_at_index_a
    ld (selected_combatant_location), hl

    pop bc
    ld a, b
    call get_character_at_index_a
    ld (selected_character_location), hl

    ld h, ba_action_menu_column
    ld l, ba_action_menu_row + 1
    call set_cursor_hl

    ld hl, str_attacking
    call print_compressed_string

    ld hl, (selected_character_location)
    POINT_HL_TO_ATTR pl_offs_name
    call print_compressed_string

    call attack_selected_enemy
    call await_any_keypress
    call clear_message_rows

    ret

clear_action_window:
    ld a, 6
    ld hl, clear_action_window_callback
    call iterate_a
    ret

clear_action_window_callback:
    add a, ba_action_menu_row
    PRINT_COMPRESSED_AT_LOCATION a, ba_action_menu_column, blank_window_string
    ret

clear_message_rows:
    ld a, 2
    ld hl, clear_message_rows_callback
    call iterate_a
    ret

clear_message_rows_callback:
    add a, ba_message_row
    PRINT_COMPRESSED_AT_LOCATION a, 1, blank_message_row_string
    ret

print_turn_header:
    ld h, ba_action_menu_column
    ld l, ba_action_menu_row
    call set_cursor_hl

    call get_character_in_turn
    POINT_HL_TO_ATTR pl_offs_name
    call print_compressed_string

    ld hl, turn_header
    call print_compressed_string
    ret

show_selected_menu:
    call print_turn_header

    ld b, ba_action_menu_column
    ld c, ba_action_menu_row + 1

    ld a, (current_menu_option_count)
    ld hl, (current_menu_address)
    ld bc, common_consolidated_menu

    call consolidate_menu_hl_bc
    ld b, ba_action_menu_column
    ld c, ba_action_menu_row + 1
    ld hl, common_consolidated_menu
    call menu_ui

    ret

process_root_option:
    cp a, bm_option_end_turn_value
    jp z, handle_end_turn

    cp a, bm_option_move_value
    jp z, handle_move

    cp a, bm_option_inspect_value
    jp z, handle_inspect

    cp a, bm_option_attack_value
    jp z, handle_attack

    cp a, bm_option_cast_value
    jp z, handle_cast

    ret

handle_end_turn:
    ld a, 1
    ld (should_end_turn), a
    ret

handle_move:
    ld a, 0
    ld (bm_root_move_flags), a

    ; toggle the line flag
    call get_combatant_in_turn
    LOAD_A_WITH_ATTR_THROUGH_HL cbt_offs_flags
    ld b, $04
    and a, b
    jp z, set_flag

    ld a, (hl)
    ld b, $FB
    and a, b

    jp handle_move_done

set_flag:
    ld a, (hl)
    ld b, $04
    or a, b

handle_move_done:
    ld (hl), a

    ret

handle_inspect:
    call get_index_of_player_in_turn
    ld (last_inspected_index), a
    call inspect_ui
    ret

attack_result: .db 0
damage_result: .db 0
handle_attack:
    call select_enemy
    cp a, 0
    jp z, handle_attack_end

    call get_selected_enemy_distance
    cp a, 2
    jp z, forbid_attack

    ld a, 0
    ld (bm_root_attack_flags), a
    ld (bm_root_cast_flags), a

    call attack_selected_enemy
handle_attack_end:
    ret

forbid_attack:
    call clear_message_rows
    ld h, 1
    ld l, ba_message_row
    call set_cursor_hl

    ld hl, str_too_far
    call print_compressed_string
    ret

handle_cast:
    ld a, spell_menu_total_options
    ld (current_menu_option_count), a

    ld hl, spell_menu_root
    ld (current_menu_address), hl

    ld hl, process_cast_option
    ld (menu_proc_func), hl
    ret

selected_spell: .db 0
saving_throw: .db 0
process_cast_option:
    ld (selected_spell), a
    cp a, 0
    jp z, process_cast_cancel

    call select_enemy
    cp a, 0
    jp z, process_cast_cancel

    ld a, (selected_spell)
    call get_spell_check_type
    cp a, spell_type_ranged
    jp z, cast_ranged_spell

    ; enemy needs to make an A saving throw
    ld hl, (selected_character_location)
    call roll_ability_check
    ld (saving_throw), a

    call clear_message_rows
    ld h, 1
    ld l, ba_message_row
    call set_cursor_hl

    ld hl, spell_save_str
    call print_compressed_string

    ld hl, (character_in_turn)
    call get_spell_save_bonus
    ld d, 0
    ld e, a
    call de_to_decimal_string
    ld hl, bc
    call print_string

    ld h, 1
    ld l, ba_message_row + 1
    call set_cursor_hl

    ld hl, saving_throw_str
    call print_compressed_string

    ld a, (saving_throw)
    ld d, 0
    ld e, a
    call de_to_decimal_string
    ld hl, bc
    call print_string

    ld hl, (character_in_turn)
    call get_spell_save_bonus
    ld b, a
    ld a, (saving_throw)
    cp a, b
    jp p, enemy_saved
    jp z, enemy_saved

    ld hl, hit_str
    call print_compressed_string

    ld h, ba_cast_damage_colum
    ld l, ba_message_row
    call set_cursor_hl
    jp process_cast_deal_damage

enemy_saved:
    ld hl, saved_str
    call print_compressed_string
    jp process_cast_done

cast_ranged_spell:
    ld hl, get_ranged_spell_attack_bonus
    ld (hit_bonus_func), hl
    call try_hit_selected_enemy
    cp a, 0
    jp z, process_cast_done

    ld h, 1
    ld l, ba_message_row + 1
    call set_cursor_hl

process_cast_deal_damage:
    ld hl, (character_in_turn)
    ld b, 1
    ld a, (selected_spell)
    call get_spell_damage_dice
    call roll_b_a
    ld (damage_result), a

    call handle_damage_result

process_cast_done:
    call set_up_root_menu
    ld a, 0
    ld (bm_root_cast_flags), a
    ld (bm_root_attack_flags), a
    ret
process_cast_cancel:
    call set_up_root_menu
    ret

set_up_root_menu:
    call get_character_in_turn
    call configure_spell_menu
    cp a, 0
    jp z, disable_cast

    ld a, default_options_flags
    jp select_root

disable_cast:
    ld a, 0

select_root:
    ld (bm_root_cast_flags), a
    ld hl, opt_bm_root
    ld (current_menu_address), hl

    ld a, opt_bm_root_option_count
    ld (current_menu_option_count), a

    ld hl, process_root_option
    ld (menu_proc_func), hl
    ret

hit_bonus_func: .dw 0

; returns 0, 1, or 2 in A
get_selected_enemy_distance:
    ld bc, 0
    push bc
    call get_combatant_in_turn
    LOAD_A_WITH_ATTR_THROUGH_HL cbt_offs_flags
    and a, cbt_flag_line
    cp a, 0
    jp z, add_enemy_distance
    pop bc
    inc bc
    push bc

add_enemy_distance:
    ld hl, (selected_combatant_location)
    LOAD_A_WITH_ATTR_THROUGH_HL cbt_offs_flags
    and a, cbt_flag_line
    cp a, 0
    jp z, return_distance
    pop bc
    inc bc
    push bc

return_distance:
    pop bc
    ld a, c
    ret

roll_d20_with_advantage:
    ld hl, str_advantage_parenthetical
    call print_compressed_string

    call roll_d20
    ld b, a
    push bc
    call roll_d20
    pop bc

    cp a, b
    jp c, return_b
    ret

return_b:
    ld a, b
    ret

try_hit_selected_enemy:
    call clear_message_rows
    ld h, 1
    ld l, ba_message_row
    call set_cursor_hl

    ld hl, attack_roll_str
    call print_compressed_string

    call get_selected_enemy_distance
    cp a, 0

    call nz, roll_d20
    call z, roll_d20_with_advantage

    ld (attack_result), a

    cp a, 1
    jp z, critical_miss

    cp a, 20
    jp z, critical_hit

    ld hl, (character_in_turn)
    ld bc, hl
    ld hl, (hit_bonus_func)
    call call_hl

    ld b, a
    ld a, (attack_result)
    add a, b
    ld (attack_result), a

    ld a, (attack_result)
    ld d, 0
    ld e, a
    call de_to_decimal_string
    ld hl, bc
    call print_string

    ld hl, (selected_combatant_location)
    LOAD_A_WITH_ATTR_THROUGH_HL cbt_offs_armor_class
    ld b, a
    ld a, (attack_result)
    cp a, b
    jp z, hit
    jp m, miss
    jp hit

critical_miss:
    ld hl, critical_str
    call print_compressed_string
miss:
    ld hl, miss_str
    call print_compressed_string
    ld a, 0
    ret

critical_hit:
    ld hl, critical_str
    call print_compressed_string
hit:
    ld a, 1
    ret

select_enemy:
    ld a, (party_size) ; start at first enemy
    ld (last_inspected_index), a
    call inspect_ui
    ret

no_bonus:
    ld a, 0
    ret

handle_damage_result:
    ld hl, damage_roll_str
    call print_compressed_string

    ld a, (damage_result)
    ld d, 0
    ld e, a
    call de_to_decimal_string
    ld hl, bc
    call print_string

    ld hl, (selected_combatant_location)
    LOAD_A_WITH_ATTR_THROUGH_HL cbt_offst_hit_points
    ld b, a
    ld a, (damage_result)
    ld d, a
    ld a, b ; a now has HP
    ld b, d ; b now has damage

    cp a, b
    jp m, set_hp_0

    sub a, b
    jp write_a_to_health

set_hp_0:
    ld a, 0

write_a_to_health:
    ld hl, (selected_combatant_location)
    ld bc, cbt_offst_hit_points
    add hl, bc
    ld (hl), a

    cp a, 0
    jp z, attack_killed_attackee
    ret

attack_killed_attackee:
    ; player characters have a chance at a saving throw on their turn, so only set the death flag right away if it's not
    ; part of the player party

    ld hl, (selected_combatant_location)
    LOAD_A_WITH_ATTR_THROUGH_HL cbt_offs_flags
    ld b, cbt_flag_faction
    and a, b
    cp a, 0
    jp nz, non_player_killed

    ; TODO: saving throw isn't implemented yet. Just kill them, too, for now.
    ld hl, (selected_combatant_location)
    LOAD_A_WITH_ATTR_THROUGH_HL cbt_offs_flags
    ld b, $fd
    and a, b

    ld hl, (selected_combatant_location)
    ld bc, cbt_offs_flags
    add hl, bc
    ld (hl), a
    ret

non_player_killed:
    ld hl, (selected_combatant_location)
    LOAD_A_WITH_ATTR_THROUGH_HL cbt_offs_flags
    ld b, $fd
    and a, b

    ld hl, (selected_combatant_location)
    ld bc, cbt_offs_flags
    add hl, bc
    ld (hl), a

    call is_enemy_party_dead
    cp a, 0
    jp z, battle_done
    ret

battle_done:
    ld a, 1
    ld (should_end_turn), a
    ret

pick_automatic_target:
    ; tried a handful of times to pick a random living player, but falls back to get_first_living_player
    ld bc, 10
    push bc

pick_automatic_target_loop:
    pop bc
    dec bc
    push bc
    ld a, c
    cp a, 0
    jp z, pick_automatic_target_fallback

    call roll_d4
    cp a, 0
    jp z, pick_automatic_target_loop

    dec a ; zero-based

    ld b, a
    ld a, (party_size)
    cp a, b
    jp z, pick_automatic_target_loop
    jp m, pick_automatic_target_loop

    push bc
    ld a, b
    call get_combatant_at_index_a
    LOAD_A_WITH_ATTR_THROUGH_HL cbt_offst_hit_points
    cp a, 0
    pop bc
    ld a, b
    jp z, pick_automatic_target_loop

    pop bc
    ret

pick_automatic_target_fallback:
    pop bc
    call get_first_living_player
    ret

get_first_living_player:
    ld bc, 0
    push bc

get_first_living_player_loop:
    pop bc
    push bc
    ld a, b
    call get_combatant_at_index_a
    LOAD_A_WITH_ATTR_THROUGH_HL cbt_offst_hit_points
    cp a, 0
    jp z, player_dead

    pop bc
    ld a, b
    ret

player_dead:
    pop bc
    inc b
    push bc

    ld b, a
    ld a, (party_size)
    cp a, b
    jp z, no_players
    jp get_first_living_player_loop

no_players:
    pop bc
    ld a, 0
    ret

attack_selected_enemy:
    ld hl, no_bonus ; TODO: attack roll bonuses
    ld (hit_bonus_func), hl
    call try_hit_selected_enemy
    cp a, 0
    jp z, attack_no_hit

    ld h, 1
    ld l, ba_message_row + 1
    call set_cursor_hl

    ld hl, (character_in_turn)
    call get_damage_value
    ld (damage_result), a

    call handle_damage_result

attack_no_hit:
    ret
