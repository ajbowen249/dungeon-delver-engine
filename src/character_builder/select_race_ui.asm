.local
header: .asciz "Select Your Race"

; Presents the race selection screen.
; A is set to the selected race_x enum value on exit
select_race_ui::
    call init_screen

    ld a, 4
    ld hl, en_race
    call simple_menu_ui
    ret

init_screen:
    call rom_clear_screen
    PRINT_AT_LOCATION 1, 1, header
    ret
.endlocal
