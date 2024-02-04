#define combatants_first_row 2

screen_data: .dw 0

should_exit: .db 0

party_location: .dw 0
party_size: .db 0

enemy_party_location: .dw 0
enemy_party_size: .db 0

.macro ALLOCATE_COMBATANT &LABEL
&LABEL:
&LABEL_flags: .db 0
&LABEL_initiative: .db 0
&LABEL_armor_class: .db 0
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
for_each_combatant_index: .db 0

; Iterates across all combatants, first players, then enemies.
; Provide a callback in HL. It will be called with foreach_player_address and foreach_combat_address written
; data, and A the faction (0: party, 1: enemy)
for_each_combatant:
    ld (for_each_combatant_callback_loc), hl
    ld a, 0
    ld (for_each_combatant_index), a
for_each_combatant_loop_1:
    ld a, (for_each_combatant_index)
    call get_character_at_index_a
    ld (foreach_player_address), hl

    ld a, (for_each_combatant_index)
    call get_combatant_at_index_a
    ld (foreach_combat_address), hl

    ld hl, (for_each_combatant_callback_loc)
    call call_hl

    ld a, (for_each_combatant_index)
    inc a
    ld (for_each_combatant_index), a
    ld b, a
    ld a, (total_number_of_combatants)
    cp a, b
    jp nz, for_each_combatant_loop_1

    ret

get_index_of_player_in_turn:
    ld hl, initiative_order
    ld a, (player_turn_index)
    ld b, 2
    call get_array_item
    inc hl
    ld a, (hl)
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

get_character_in_turn:
    call get_index_of_player_in_turn
    call get_character_at_index_a
    ret

get_combatant_at_index_a:
    ld b, a
    ld a, (party_size)
    dec a

    cp a, b
    jp m, get_combatant_from_enemy_list

    ld a, cbt_data_length
    ld hl, party_combatants
    call get_array_item
    ret
get_combatant_from_enemy_list:
    ld a, (party_size)
    ld c, a
    ld a, b
    sub a, c

    ld b, a
    ld a, cbt_data_length
    ld hl, enemy_combatants
    call get_array_item
    ret

get_combatant_in_turn:
    call get_index_of_player_in_turn
    call get_combatant_at_index_a
    ret

; Returns nonzero in A if the player party is alive, Zero if all dead
is_player_party_dead:
    ld a, 1
    ret

; Returns nonzero in A if the enemy party is alive, Zero if all dead
is_enemy_party_dead:
    ld a, 1
    ret

