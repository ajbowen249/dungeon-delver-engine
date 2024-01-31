.local
header: .asciz "How many adventurers will join?"

; Presents the party size selection screen.
; A is set to the selected number of players on exit
party_size_ui::
    call init_screen

    ld a, 4
    ld hl, en_count_selection
    call enum_menu_ui
    ret

init_screen:
    call rom_clear_screen
    PRINT_AT_LOCATION 1, 1, header
    ret
.endlocal
