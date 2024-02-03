#define default_options_flags $01

opt_class_fighter_label: .asciz "Fighter"
opt_class_wizard_label: .asciz "Wizard"
opt_class_cleric_label: .asciz "Cleric"
opt_class_barbarian_label: .asciz "Barbarian"

opt_class:
.db class_fighter
.db default_options_flags
.dw opt_class_fighter_label

.db class_wizard
.db default_options_flags
.dw opt_class_wizard_label

.db class_cleric
.db default_options_flags
.dw opt_class_cleric_label

.db class_barbarian
.db default_options_flags
.dw opt_class_barbarian_label

opt_race_human_label: .asciz "Human"
opt_race_elf_label: .asciz "Elf"
opt_race_dwarf_label: .asciz "Dwarf"
opt_race_half_elf_label: .asciz "Half-Elf"

opt_race:
.db race_human
.db default_options_flags
.dw opt_race_human_label

.db race_elf
.db default_options_flags
.dw opt_race_elf_label

.db race_dwarf
.db default_options_flags
.dw opt_race_dwarf_label

.db race_half_elf
.db default_options_flags
.dw opt_race_half_elf_label

opt_count_selection_label_1: .asciz "1"
opt_count_selection_label_2: .asciz "2"
opt_count_selection_label_3: .asciz "3"
opt_count_selection_label_4: .asciz "4"

opt_count_selection:
.db 1
.db default_options_flags
.dw opt_count_selection_label_1

.db 2
.db default_options_flags
.dw opt_count_selection_label_2

.db 3
.db default_options_flags
.dw opt_count_selection_label_3

.db 4
.db default_options_flags
.dw opt_count_selection_label_4

opt_yes_no_label_yes .asciz "Yes"
opt_yes_no_label_no .asciz "No"

opt_yes_no:
.db 0
.db default_options_flags
.dw opt_yes_no_label_yes

.db 1
.db default_options_flags
.dw opt_yes_no_label_no
