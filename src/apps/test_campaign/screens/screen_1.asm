#define screen_id_screen_1 1

.local
screen_1_data:
screen_1_background:
.asciz "┌──────────────────┐"
.asciz "│    왓              "
.asciz "│           ∩      │"
.asciz "│                  │"
.asciz "│                  │"
.asciz "│                  │"
.asciz "│∩∩          왓     │"
.asciz "└──────────────────┘"
screen_1_title: .asciz "Test Room"
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
screen_1_start_x: .db 2 ; 1-indexed since it's screen coordinates!
screen_1_start_y: .db 2
screen_1_interactables:
    DEFINE_INTERACTABLE chest_1, in_chest, 0, 3, 13
    DEFINE_INTERACTABLE door_1, in_door, $01, 2, 20
    DEFINE_INTERACTABLE test_npc, in_npc, 0, 2, 6
    DEFINE_INTERACTABLE blank_4, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_5, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_6, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_7, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_8, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_9, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_0, 0, 0, 0, 0
screen_1_get_interaction_prompt: .dw get_interaction_prompt
screen_1_interact_callback: .dw on_interact
screen_1_menu_callback: .dw main_menu

empty_prompt: .db 0
chest_prompt: .asciz "Open Chest"

test_npc_prompt .asciz "Test Fight"

screen_1::
    ld hl, player_party
    ld a, (party_size)
    ld bc, screen_1_data
    call exploration_ui

    ret

get_interaction_prompt:
    cp a, 0
    jp z, ret_chest_prompt
    cp a, 2
    jp z, ret_test_npc_prompt

    ld hl, empty_prompt
    ret

ret_chest_prompt:
    ld hl, chest_prompt
    ret

ret_test_npc_prompt:
    ld hl, test_npc_prompt
    ret

on_interact:
    cp a, 0
    jp z, chest_interact

    cp a, 1
    jp z, door_interact

    cp a, 2
    jp z, test_npc_interact

chest_interact:
    call dialog_skill_demo
    ld a, 0
    ret

door_interact:
    EXIT_EXPLORATION ec_door, screen_id_screen_2
    ret

test_npc_interact:
    EXIT_EXPLORATION ec_encounter, encounter_id_badger
    ret

.endlocal
