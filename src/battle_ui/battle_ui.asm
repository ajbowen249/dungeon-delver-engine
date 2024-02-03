.local
#include "./battle_ui_data.asm"
#include "./initiative.asm"
#include "./combatant_window.asm"

; Displays the combat screen until the encounter is resolved
; HL should contain a pointer to an array of player data for the controlled party, and A the size of the party
; BC should contain a pointer to an array of player data for the enemy party, and D the number of enemies
; Both groups are capped at 4, for now.
battle_ui::
    ld (party_location), hl
    ld (party_size), a

    ld hl, bc
    ld (enemy_party_location), hl
    ld a, d
    ld (enemy_party_size), a

    ld a, 0
    ld (should_exit), a

    ld a, (party_size)
    ld b, a
    ld a, (enemy_party_size)
    add a, b
    ld (total_number_of_combatants), a

    call init_screen

read_loop:
    ld a, (should_exit)
    cp a, 0
    jp z, keep_reading

    ret

keep_reading:
    call rom_kyread
    jp z, read_loop

    ON_KEY_JUMP ch_down_arrow, on_down_arrow
    ON_KEY_JUMP ch_s, on_down_arrow
    ON_KEY_JUMP ch_S, on_down_arrow

    ON_KEY_JUMP ch_up_arrow, on_up_arrow
    ON_KEY_JUMP ch_w, on_up_arrow
    ON_KEY_JUMP ch_W, on_up_arrow

    ON_KEY_JUMP ch_left_arrow, on_left_arrow
    ON_KEY_JUMP ch_a, on_left_arrow
    ON_KEY_JUMP ch_A, on_left_arrow

    ON_KEY_JUMP ch_right_arrow, on_right_arrow
    ON_KEY_JUMP ch_d, on_right_arrow
    ON_KEY_JUMP ch_D, on_right_arrow

    ON_KEY_JUMP ch_enter, on_press_enter

on_down_arrow:
    call handle_down_arrow
    jp read_loop_continue
on_up_arrow:
    call handle_up_arrow
    jp read_loop_continue
on_left_arrow:
    call handle_left_arrow
    jp read_loop_continue
on_right_arrow:
    call handle_right_arrow
    jp read_loop_continue

on_press_enter:
    call handle_press_enter

    jp read_loop_continue

read_loop_continue:
    jp read_loop

    ret

init_screen:
    call initialize_combatants
    call display_initiative_order
    call rom_clear_screen
    call draw_combatants
    ret

handle_down_arrow:
    ret

handle_up_arrow:
    ret

handle_left_arrow:
    ret

handle_right_arrow:
    ret

handle_press_enter:
    ld a, 1
    ld (should_exit), a
    ret

clear_message_area:
    PRINT_AT_LOCATION 2, message_column, blank_message_string
    PRINT_AT_LOCATION 3, message_column, blank_message_string
    PRINT_AT_LOCATION 4, message_column, blank_message_string
    PRINT_AT_LOCATION 5, message_column, blank_message_string
    PRINT_AT_LOCATION 6, message_column, blank_message_string
    PRINT_AT_LOCATION 7, message_column, blank_message_string
    PRINT_AT_LOCATION 8, message_column, blank_message_string
    ret


.endlocal
