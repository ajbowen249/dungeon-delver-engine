.local
header: .asciz "Create a custom party?"

; Asks the player if they would like to create a custom party, or use the default.
; If they wish to create a custom party, A will be set to 0. Otherwise, A is non-zero
default_party_ui::
    call init_screen

    ld a, 2
    ld hl, en_yes_no
    LOAD_ENUM_MENU_DEFAULT_COORDS
    call enum_menu_ui
    ret

init_screen:
    call rom_clear_screen
    PRINT_AT_LOCATION 1, 1, header
    ret
.endlocal
