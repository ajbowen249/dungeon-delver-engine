.local
header: .asciz "Select Your Class"

; Presents the class selection screen.
; A is set to the selected race_x enum value on exit
select_class_ui::
    call init_screen

    ld a, 4
    ld hl, en_class
    LOAD_ENUM_MENU_DEFAULT_COORDS
    call enum_menu_ui
    ret

init_screen:
    call rom_clear_screen
    PRINT_AT_LOCATION 1, 1, header
    ret
.endlocal