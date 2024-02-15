.local
#define opt_skill_demo_lockpick 1
#define opt_skill_demo_smash_chest 2
#define opt_skill_demo_root_leave_alone 0

dialog_skill_demo_intro: .asciz "It's locked"

label_pick_lock: .asciz "[D]Pick lock"
label_smash_chest: .asciz "[S]Smash the chest"
label_leave_alone: .asciz "Leave it alone"

skill_demo:
.db opt_skill_demo_lockpick
.db default_options_flags
.dw label_pick_lock

.db opt_skill_demo_smash_chest
.db default_options_flags
.dw label_smash_chest

.db opt_skill_demo_root_leave_alone
.db default_options_flags
.dw label_leave_alone

skill_demo_choice: .db 0

dialog_skill_demo::
    PRINT_AT_LOCATION 2, 21, dialog_skill_demo_intro

    ld a, 3
    ld hl, skill_demo
    ld b, 21
    ld c, 3
    call menu_ui
    ld (skill_demo_choice), a

    call clear_exploration_message_area

    ld a, (skill_demo_choice)
    cp a, opt_skill_demo_root_leave_alone
    jp z, leave_alone

    cp a, opt_skill_demo_lockpick
    jp z, pick_lock

    cp a, opt_skill_demo_smash_chest
    jp z, smash_chest

    ret

pick_lock:
    ld a, skill_index_dex
    ld b, 11
    ld hl, test_character1
    ld d, 21
    ld e, 2
    call skill_check_ui
    ret

smash_chest:
    ld a, skill_index_str
    ld b, 5
    ld hl, test_character1
    ld d, 21
    ld e, 2
    call skill_check_ui
    ret

leave_alone:
    ret
.endlocal
