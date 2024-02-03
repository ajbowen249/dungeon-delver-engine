
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

; associative array of initiative roll->player index
; will be sorted by initiative once init_screen is complete
.macro ALLOCATE_INITIATIVE
.db 0
.db 0
.endm

initiative_order:
    ALLOCATE_INITIATIVE
    ALLOCATE_INITIATIVE
    ALLOCATE_INITIATIVE
    ALLOCATE_INITIATIVE
    ALLOCATE_INITIATIVE
    ALLOCATE_INITIATIVE
    ALLOCATE_INITIATIVE
    ALLOCATE_INITIATIVE

initiative_sort_space:
    ALLOCATE_INITIATIVE

total_number_of_combatants: .db 0

player_turn_index: .db 0

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

get_character_at_index_a:
    ld b, a
    ld a, (party_size)
    dec a

    cp a, b
    jp m, get_character_from_enemy_list

    ld a, pl_data_size
    ld hl, (party_location)
    call get_array_item
    ret
get_character_from_enemy_list:
    ld a, (party_size)
    ld c, a
    ld a, b
    sub a, c

    ld b, a
    ld a, pl_data_size
    ld hl, (enemy_party_location)
    call get_array_item
    ret

call_hl:
    jp hl
    ret
