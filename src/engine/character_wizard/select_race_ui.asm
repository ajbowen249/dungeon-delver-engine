.local
; Presents the race selection screen.
; A is set to the selected race_x enum value on exit
select_race_ui::
    call init_screen

    ld a, 4
    ld hl, opt_race
    LOAD_ENUM_MENU_DEFAULT_COORDS
    call menu_ui
    ret

init_screen:
    call clear_screen
    PRINT_COMPRESSED_AT_LOCATION 1, 1, select_race_header
    ret
.endlocal
