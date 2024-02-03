#include "./battle_menu_options.asm"

#define action_menu_column 8
blank_menu_string: .asciz "                               "

; shows menus needed for the player to take actions on their turn, and returns when their turn is over
execute_player_turn:
    call clear_menu_area

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
    ld a, 1
    ld hl, en_bm_root
    call enum_menu_ui

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
