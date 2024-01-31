en_class_fighter_label: .asciz "Fighter"
en_class_wizard_label: .asciz "Wizard"
en_class_cleric_label: .asciz "Cleric"
en_class_barbarian_label: .asciz "Barbarian"

en_class:
.db class_fighter
.dw en_class_fighter_label

.db class_wizard
.dw en_class_wizard_label

.db class_cleric
.dw en_class_cleric_label

.db class_barbarian
.dw en_class_barbarian_label

en_race_human_label: .asciz "Human"
en_race_elf_label: .asciz "Elf"
en_race_dwarf_label: .asciz "Dwarf"
en_race_half_elf_label: .asciz "Half-Elf"

en_race:
.db race_human
.dw en_race_human_label

.db race_elf
.dw en_race_elf_label

.db race_dwarf
.dw en_race_dwarf_label

.db race_half_elf
.dw en_race_half_elf_label

.local
; Sets the address of the label portion of the enum in HL with the value in A to BC
get_enum_label::
    ld b, a

search:
    ld a, (hl)

    cp a, b
    jp z, found
    inc hl
    inc hl
    inc hl
    jp search

found:
    inc hl
    ld bc, hl
    ret
.endlocal
