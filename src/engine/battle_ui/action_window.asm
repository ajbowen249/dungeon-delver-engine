#include "./battle_menu_options.asm"

#define action_menu_column 8
blank_window_string: .asciz "                               "
blank_message_row_string: .asciz "                                       "
turn_header: .asciz "'s turn"
hit_roll_str: .asciz "Attack Roll: "
damage_roll_str: .asciz "Damage Roll: "
critical_str: .asciz "Critical"
hit_str: .asciz " Hit"
miss_str: .asciz " Miss"

should_end_turn: .db 0
current_menu_address: .dw 0
character_in_turn: .dw 0

; shows menus needed for the player to take actions on their turn, and returns when their turn is over
execute_player_turn:

    ; enable all options since this is the start of the turn
    ld a, default_options_flags
    ld (bm_root_move_flags), a
    ld (bm_root_attack_flags), a

    ld a, 0
    ld (should_end_turn), a

    ld hl, opt_bm_root
    ld (current_menu_address), hl

    call get_character_in_turn
    ld (character_in_turn), hl

menu_loop:
    call clear_action_window
    call show_selected_menu
    call process_option

    ld a, (should_end_turn)
    cp a, 0
    jp z, menu_loop

    ret

clear_action_window:
    PRINT_AT_LOCATION 1, action_menu_column, blank_window_string
    PRINT_AT_LOCATION 2, action_menu_column, blank_window_string
    PRINT_AT_LOCATION 3, action_menu_column, blank_window_string
    PRINT_AT_LOCATION 4, action_menu_column, blank_window_string
    PRINT_AT_LOCATION 5, action_menu_column, blank_window_string
    PRINT_AT_LOCATION 6, action_menu_column, blank_window_string
    ret

clear_message_rows:
    PRINT_AT_LOCATION 7, 1, blank_message_row_string
    PRINT_AT_LOCATION 8, 1, blank_message_row_string
    ret

show_selected_menu:
    ld h, action_menu_column
    ld l, 1
    call rom_set_cursor

    call get_character_in_turn
    POINT_HL_TO_ATTR pl_offs_name
    call print_string

    ld hl, turn_header
    call print_string

    ld b, action_menu_column
    ld c, 2

    ld a, opt_bm_root_option_count
    ld hl, opt_bm_root
    ld bc, consolidated_battle_menu

    call consolidate_menu_hl_bc
    ld b, action_menu_column
    ld c, 2
    ld hl, consolidated_battle_menu
    call menu_ui

    ret

process_option:
    ld b, bm_option_end_turn_value
    cp a, b
    jp z, handle_end_turn

    ld b, bm_option_move_value
    cp a, b
    jp z, handle_move

    ld b, bm_option_inspect_value
    cp a, b
    jp z, handle_inspect

    ld b, bm_option_attack_value
    cp a, b
    jp z, handle_attack

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
    call draw_combatants

    ret

handle_inspect:
    call get_index_of_player_in_turn
    ld (last_inspected_index), a
    call inspect_ui
    ret

hit_result: .db 0
damage_result: .db 0
handle_attack:
    ; TODO: Forbid attack if both players are in the back, and apply disadvantage if one is in the back.
    ld a, 0
    ld (bm_root_attack_flags), a

    ld a, (party_size) ; start at first enemy
    ld (last_inspected_index), a
    call inspect_ui

    call clear_message_rows
    ld h, 1
    ld l, 7
    call rom_set_cursor

    ld hl, hit_roll_str
    call print_string

    ld hl, (character_in_turn)
    call roll_hit_dice
    ld (hit_result), a

    cp a, 1
    jp z, critical_miss

    cp a, 20
    jp z, critical_hit

    ; TODO: Apply attack bonuses here.
    ; The raw roll needs to be separate as critical hit/miss is only dice-based.

    ld a, (hit_result)
    ld d, 0
    ld e, a
    call de_to_decimal_string
    ld hl, bc
    call print_string

    ld hl, (selected_combatant_location)
    LOAD_A_WITH_ATTR_THROUGH_HL cbt_offs_armor_class
    ld b, a
    ld a, (hit_result)
    cp a, b
    jp z, hit
    jp m, miss
    jp hit

critical_miss:
    ld hl, critical_str
    call print_string
miss:
    ld hl, miss_str
    call print_string
    ret

critical_hit:
    ld hl, critical_str
    call print_string
hit:
    ld hl, hit_str
    call print_string

    ld h, 1
    ld l, 8
    call rom_set_cursor

    ld hl, damage_roll_str
    call print_string

    ld hl, (character_in_turn)
    call get_damage_value
    ld (damage_result), a
    ld d, 0
    ld e, a
    call de_to_decimal_string
    ld hl, bc
    call print_string

    call deal_damage

    ret

deal_damage:
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