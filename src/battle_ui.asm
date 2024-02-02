.local

#define message_column 8
blank_message_string: .asciz "                               "
#define combatants_first_row 2

initiative_header: .asciz "Initiative:"

screen_data: .dw 0

should_exit: .db 0

party_location: .dw 0
party_size: .db 0

enemy_party_location: .dw 0
enemy_party_size: .db 0

.macro ALLOCATE_COMBATANT &LABEL
&LABEL:
&LABEL_initiative: .db 0
&LABEL_flags: .db 0
&LABEL_hit_points: .dw 0
.endm

party_combatants:
    ALLOCATE_COMBATANT party_combatant_0
    ALLOCATE_COMBATANT party_combatant_1
    ALLOCATE_COMBATANT party_combatant_2
    ALLOCATE_COMBATANT party_combatant_3

enemy_combatants:
    ALLOCATE_COMBATANT enemy_combatant_0
    ALLOCATE_COMBATANT enemy_combatant_1
    ALLOCATE_COMBATANT enemy_combatant_2
    ALLOCATE_COMBATANT enemy_combatant_3

general_counter: .db 0

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
    call display_initiative_results
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

initialize_combatants:
    ld hl, initialize_combatants_foreach_callback
    call for_each_combatant
    ret

initialize_combatants_foreach_callback:
    ; roll initiative
    ld hl, (foreach_player_address)
    call roll_dexterity_check

    ld hl, (foreach_combat_address)
    ld b, 0
    ld c, cbt_offs_initiative
    add hl, bc
    ld b, 0
    ld c, a; from roll_dexterity_check
    ld (hl), bc

    ld hl, (foreach_combat_address)
    ld b, 0
    ld c, cbt_offst_hit_points
    add hl, bc
    ld b, 0
    ld c, 20 ; TODO: Get from class+level
    ld (hl), bc

    cp a, 0
    jp nz, init_enemy_combatant

    ld hl, (foreach_combat_address)
    ld b, 0
    ld c, cbt_offs_flags
    add hl, bc
    ld a, cbt_initial_party_flags
    ld (hl), a

    ret

init_enemy_combatant:
    ld hl, (foreach_combat_address)
    ld b, 0
    ld c, cbt_offs_flags
    add hl, bc
    ld a, cbt_initial_enemy_flags
    ld (hl), a
    ret

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

for_each_combatant_callback_loc: .dw 0
foreach_player_address: .dw 0
foreach_combat_address: .dw 0

; Iterates across all combatants, first players, then enemies.
; Provide a callback in HL. It will be called with foreach_player_address and foreach_combat_address written
; data, and A the faction (0: party, 1: enemy)
for_each_combatant:
    ld (for_each_combatant_callback_loc), hl

.macro FOR_EACH_COMBATANT_FACTION_LOOP &PL_DATA, &CB_DATA, &PARTY_SIZE, &FACTION, &LABEL
    ld a, 0
    ld (general_counter), a
for_each_&LABEL_combatant:
    ld a, (general_counter)
    ld b, cbt_data_length
    ld hl, &CB_DATA
    call get_array_item
    ld (foreach_combat_address), hl

    ld a, (general_counter)
    ld b, pl_data_size
    ld hl, (&PL_DATA)
    call get_array_item
    ld (foreach_player_address), hl

    ld hl, (for_each_combatant_callback_loc)
    ld a, &FACTION
    call call_hl

    ld a, (general_counter)
    inc a
    ld (general_counter), a
    ld b, a
    ld a, (&PARTY_SIZE)
    cp a, b
    jp nz, for_each_&LABEL_combatant
.endm

    FOR_EACH_COMBATANT_FACTION_LOOP party_location, party_combatants, party_size, 0, player
    FOR_EACH_COMBATANT_FACTION_LOOP enemy_party_location, enemy_combatants, enemy_party_size, 1, enemy

    ret

initiative_display_counter: .db 0
display_initiative_results:
    call rom_clear_screen

    PRINT_AT_LOCATION 1, 1, initiative_header

    ld a, 0
    ld (initiative_display_counter), a

    ld hl, display_initiative_results_foreach_callback
    call for_each_combatant


initiative_wait_loop:
    call rom_kyread
    jp z, initiative_wait_loop
    ret

display_initiative_results_foreach_callback:
    ld a, (initiative_display_counter)
    add a, 1
    ld l, a
    ld h, 14
    call rom_set_cursor

    ld hl, (foreach_player_address)
    ld bc, pl_offs_name
    add hl, bc
    call print_string

    ld a, (initiative_display_counter)
    add a, 1
    ld l, a
    ld h, 24
    call rom_set_cursor

    ld hl, (foreach_combat_address)
    ld bc, cbt_offs_initiative
    add hl, bc
    ld a, (hl)
    ld d, 0
    ld e, a
    call de_to_decimal_string

    ld hl, bc
    call print_string

    ld a, (initiative_display_counter)
    inc a
    ld (initiative_display_counter), a

    ret

call_hl:
    jp hl
    ret
.endlocal
