.local
screen_1_data:
screen_1_background:
.asciz "┌──────────────────┐"
.asciz "│    α              "
.asciz "│           ∩      │"
.asciz "│                  │"
.asciz "│                  │"
.asciz "│         ∩        │"
.asciz "│∩∩          α     │"
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
    DEFINE_INTERACTABLE blank_3, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_4, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_5, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_6, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_7, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_8, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_9, 0, 0, 0, 0
    DEFINE_INTERACTABLE blank_0, 0, 0, 0, 0
screen_1_interact_callback: .dw on_interact

test_string: .asciz "TEST STRING HERE"

screen_1::
    ld hl, test_characters
    ld a, (party_size)
    ld bc, screen_1_data
    call exploration_ui

    ret

on_interact:
    PRINT_AT_LOCATION 4, 21, test_string
    ret

.endlocal
