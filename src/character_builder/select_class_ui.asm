.local
header: .asciz "Select Your Class"

fighter_label: .asciz "Fighter"
wizard_label: .asciz "Wizard"
cleric_label: .asciz "Cleric"
barbarian_label: .asciz "Barbarian"

menu_options:
.db class_fighter
.dw fighter_label

.db class_wizard
.dw wizard_label

.db class_cleric
.dw cleric_label

.db class_barbarian
.dw barbarian_label

; Presents the class selection screen.
; A is set to the selected race_x enum value on exit
select_class_ui::
    call init_screen

    ld a, 4
    ld hl, menu_options
    call simple_menu_ui
    ret

init_screen:
    call rom_clear_screen
    PRINT_AT_LOCATION 1, 1, header
    ret
.endlocal
