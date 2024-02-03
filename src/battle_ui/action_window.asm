#include "./battle_menu_options.asm"

#define action_menu_column 8
blank_menu_string: .asciz "                               "

should_end_turn: .db 0
current_menu_address: .dw 0

; shows menus needed for the player to take actions on their turn, and returns when their turn is over
execute_player_turn:

    ; enable move since this is the start of the turn
    ld a, default_options_flags
    ld (bm_root_move_flags), a

    ld a, 0
    ld (should_end_turn), a

    ld hl, opt_bm_root
    ld (current_menu_address), hl

menu_loop:
    call clear_menu_area
    call show_selected_menu
    call process_option

    ld a, (should_end_turn)
    cp a, 0
    jp z, menu_loop

    ret

clear_menu_area:
    PRINT_AT_LOCATION 1, action_menu_column, blank_menu_string
    PRINT_AT_LOCATION 2, action_menu_column, blank_menu_string
    PRINT_AT_LOCATION 3, action_menu_column, blank_menu_string
    PRINT_AT_LOCATION 4, action_menu_column, blank_menu_string
    PRINT_AT_LOCATION 5, action_menu_column, blank_menu_string
    PRINT_AT_LOCATION 6, action_menu_column, blank_menu_string
    PRINT_AT_LOCATION 7, action_menu_column, blank_menu_string
    PRINT_AT_LOCATION 8, action_menu_column, blank_menu_string
    ret

show_selected_menu:
    ld h, action_menu_column
    ld l, 1
    call rom_set_cursor

    call get_character_in_turn

    ld b, 0
    ld c, pl_offs_name
    add hl, bc
    call print_string

    ld b, action_menu_column
    ld c, 2
    ld a, opt_bm_root_option_count
    ld hl, opt_bm_root
    call menu_ui
    ret

process_option:
    ld b, bm_option_end_turn_value
    cp a, b
    jp z, handle_end_turn

    ld b, bm_option_move_value
    cp a, b
    jp z, handle_move
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
    ld b, 0
    ld c, cbt_offs_flags
    add hl, bc
    ld a, (hl)
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
    ld a, $02
    ld (hl), a
    call draw_combatants

    ret
