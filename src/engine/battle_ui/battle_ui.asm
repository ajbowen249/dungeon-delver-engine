.local
#include "./battle_ui_data.asm"
#include "./initiative.asm"
#include "./combatant_window.asm"
#include "./inspect_ui.asm"
#include "./action_window.asm"

; Displays the combat screen until the encounter is resolved
; HL should contain a pointer to an array of player data for the controlled party, and A the size of the party
; BC should contain a pointer to an array of player data for the enemy party, and D the number of enemies
; Both groups are capped at 4, for now.
; This UI is sort of a UI/Wizard hybred in that it has custom controls sometimes, but relies heavily on menu.
; To that end, it breaks the UI not calling UI rule, but is safe in doing so since it's not recursive.
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

    call initialize_combatants
    call display_initiative_order
    call init_screen_graphics

    ld a, 0
    ld (player_turn_index), a

battle_loop:
    call execute_player_turn

    ld a, (total_number_of_combatants)
    ld b, a
    ld a, (player_turn_index)
    inc a
    cp a, b
    jp nz, battle_loop_continue
    ld a, 0

battle_loop_continue:
    ld (player_turn_index), a

    call is_player_party_dead
    cp a, 0
    jp z, on_player_party_dead

    call is_enemy_party_dead
    cp a, 0
    jp z, on_enemy_party_dead

    jp battle_loop

on_player_party_dead:
    call rom_clear_screen

    ld h, 15
    ld l, 4
    call rom_set_cursor

    ld hl, str_game_over
    call print_compressed_string

    call await_any_keypress

    ld a, 1
    ld (dde_should_exit), a
    ret

on_enemy_party_dead:
    call rom_clear_screen

    ld h, 16
    ld l, 4
    call rom_set_cursor

    ld hl, str_victory
    call print_compressed_string

    call await_any_keypress

    ld a, 1
    ret

init_screen_graphics:
    call rom_clear_screen
    call draw_combatants
    ret

.endlocal
