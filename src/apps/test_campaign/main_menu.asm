.local
#define opt_resume 0
#define opt_exit_game 1

menu_label: .asciz "Pause"
opt_resume_label: .asciz "Resume"
opt_exit_game_label: .asciz "Exit"

menu:
.db opt_resume
.db default_options_flags
.dw opt_resume_label

.db opt_exit_game
.db default_options_flags
.dw opt_exit_game_label

main_menu::
    call clear_screen
    PRINT_AT_LOCATION 1, 1, menu_label

    ld a, 2
    ld hl, menu
    ld b, 1
    ld c, 2
    call menu_ui

    cp a, opt_exit_game
    jp z, exit_game

    ret

exit_game:
    ld a, 1
    ld (dde_should_exit), a
    ret

.endlocal
