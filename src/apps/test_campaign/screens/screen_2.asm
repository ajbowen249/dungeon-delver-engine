#define screen_id_screen_2 2

.local
screen_2_data:
screen_2_background:
.asciz "▛▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▜"
.asciz "     ▚▞     ↕      ▐"
.asciz "▌               ▓  ▐"
.asciz "▌         ▗▖       ▐"
.asciz "▌         ▝▘   ◇   ▐"
.asciz "▌          €     ◢◣▐"
.asciz "▌      █  ⌂✝ㅑ£¶  ◥◤▐"
.asciz "▙▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▟"
screen_2_title: .asciz "Test Room 2"
.block 9, 0
screen_2_start_x: .db 2 ; 1-indexed since it's screen coordinates!
screen_2_start_y: .db 2
screen_2_interactables:
    DEFINE_INTERACTABLE door_1, in_door, iflags_door, 2, 1
    DEFINE_INTERACTABLE blank_1, 0, iflags_normal, 0, 0
    DEFINE_INTERACTABLE blank_3, 0, iflags_normal, 0, 0
    DEFINE_INTERACTABLE blank_4, 0, iflags_normal, 0, 0
    DEFINE_INTERACTABLE blank_5, 0, iflags_normal, 0, 0
    DEFINE_INTERACTABLE blank_6, 0, iflags_normal, 0, 0
    DEFINE_INTERACTABLE blank_7, 0, iflags_normal, 0, 0
    DEFINE_INTERACTABLE blank_8, 0, iflags_normal, 0, 0
    DEFINE_INTERACTABLE blank_9, 0, iflags_normal, 0, 0
    DEFINE_INTERACTABLE blank_0, 0, iflags_normal, 0, 0
screen_2_get_interaction_prompt: .dw get_interaction_prompt
screen_2_interact_callback: .dw on_interact
screen_2_menu_callback: .dw main_menu

empty_prompt: .db 0

screen_2::
    ld hl, player_party
    ld a, (party_size)
    ld bc, screen_2_data
    call exploration_ui

    ret

get_interaction_prompt:
    ld hl, empty_prompt
    ret

on_interact:
    EXIT_EXPLORATION ec_door, screen_id_screen_1
    ret

.endlocal
