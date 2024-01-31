.local
header: .asciz "Select Your Race"

human_label: .asciz "Human"
elf_label: .asciz "Elf"
dwarf_label: .asciz "Dwarf"
half_elf_label: .asciz "Half-Elf"

menu_options:
.db race_human
.dw human_label

.db race_elf
.dw elf_label

.db race_dwarf
.dw dwarf_label

.db race_half_elf
.dw half_elf_label

; Presents the race selection screen.
; A is set to the selected race_x enum value on exit
select_race_ui::
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
