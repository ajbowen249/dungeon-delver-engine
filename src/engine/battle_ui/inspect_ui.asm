; Takes over both sides of the battle UI to show arrow selection over combatants and shows their current status in the
; action window.
; Exits when confirm is pressed, and saves last_inspected_index, so it can be combined with menu actions

last_inspected_index: .db 0
selected_character_location: .dw 0
selected_combatant_location: .dw 0

#define party_inspect_column 6
#define enemy_inspect_column 1

.local
; set to 1 to exit with selection, and 0 to exit without
iui_exit_code: .db 2

; exits non-zero if a selection was made, and 0 if cancelled
inspect_ui::
    call clear_action_window

    ld a, 2
    ld (iui_exit_code), a

    call on_selection_changed

    REGISTER_INPUTS on_up_arrow, on_down_arrow, on_left_arrow, on_right_arrow, on_confirm, on_escape, 0, 0

read_loop:
    call iterate_input_table

    ld a, (iui_exit_code)
    cp a, 2
    jp z, read_loop

    call clear_diamond
    ld a, (iui_exit_code)
    ret

load_player_from_index:
    ld a, (last_inspected_index)
    call get_character_at_index_a
    ld (selected_character_location), hl

    ld a, (last_inspected_index)
    call get_combatant_at_index_a
    ld (selected_combatant_location), hl

    ret

on_up_arrow:
    ld a, (last_inspected_index)
    cp a, 0
    jp z, on_up_arrow_end

    call clear_diamond

    ld a, (last_inspected_index)
    dec a
    ld (last_inspected_index), a

    call on_selection_changed

on_up_arrow_end:
    ret

on_down_arrow:
    ld a, (total_number_of_combatants)
    dec a
    ld b, a
    ld a, (last_inspected_index)
    cp a, b
    jp z, on_down_arrow_end

    call clear_diamond

    ld a, (last_inspected_index)
    inc a
    ld (last_inspected_index), a

    call on_selection_changed

on_down_arrow_end:
    ret

on_left_arrow:
    ret

on_right_arrow:
    ret

on_confirm:
    ld a, 1
    ld (iui_exit_code), a
    ret

on_escape:
    ld a, 0
    ld (iui_exit_code), a
    ret

position_inspect_cursor_location:
    ld a, (party_size)
    ld b, a
    ld a, (last_inspected_index)
    cp a, b
    jp z, position_cursor_enemy
    jp p, position_cursor_enemy

    inc a
    ld l, a
    ld h, party_inspect_column
    call rom_set_cursor
    ret

position_cursor_enemy:
    sub a, b
    inc a
    ld l, a
    ld h, enemy_inspect_column
    call rom_set_cursor
    ret

clear_diamond:
    call position_inspect_cursor_location
    ld a, " "
    call rom_print_a

    ret

on_selection_changed:
    call load_player_from_index
    call position_inspect_cursor_location

    ld a, ch_diamond
    call rom_print_a

    PRINT_COMPRESSED_AT_LOCATION 2, action_menu_column, blank_window_string

    ld l, 2
    ld h, action_menu_column
    call rom_set_cursor

    ld hl, (selected_character_location)
    ld bc, pl_offs_name
    add hl, bc
    call print_compressed_string

    ld hl, str_lvl
    call print_compressed_string

    ld hl, (selected_character_location)
    ld bc, pl_offs_level
    add hl, bc
    ld a, (hl)
    ld d, 0
    ld e, a
    call de_to_decimal_string
    ld hl, bc
    call print_string

    ld a, " "
    call rom_print_a

    ld hl, (selected_character_location)
    ld bc, pl_offs_class
    add hl, bc

    ld a, (hl)
    ld hl, opt_class
    call get_option_label

    ld hl, bc
    ld bc, (hl)
    ld hl, bc
    call print_compressed_string

    ld l, 3
    ld h, action_menu_column
    call rom_set_cursor

    ld hl, hp_string
    call print_compressed_string

    ld hl, (selected_combatant_location)
    ld bc, cbt_offst_hit_points
    add hl, bc
    ld bc, (hl)
    ld de, bc
    call de_to_decimal_string
    ld hl, bc
    call print_string

    ld l, 4
    ld h, action_menu_column
    call rom_set_cursor

    ld hl, ac_string
    call print_compressed_string

    ld hl, (selected_combatant_location)
    ld bc, cbt_offs_armor_class
    add hl, bc
    ld a, (hl)
    ld d, 0
    ld e, a
    call de_to_decimal_string
    ld hl, bc
    call print_string

    ret
.endlocal
