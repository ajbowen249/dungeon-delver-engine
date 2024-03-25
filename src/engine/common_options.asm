#define default_options_flags $01

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

.db class_m_badger
.db default_options_flags
.dw opt_class_m_badger_label

.db class_m_hobgoblin
.db default_options_flags
.dw opt_class_m_hobgoblin_label

.db class_m_goblin
.db default_options_flags
.dw opt_class_m_goblin_label

.db class_m_drow_elf
.db default_options_flags
.dw opt_class_m_drow_elf_label

.macro CAMPAIGN_CLASS &IDX
campaign_class_&IDX:
campaign_class_&IDX_value: .db 0
campaign_class_&IDX_flags: .db 0
campaign_class_&IDX_label: .dw 0
.endm

campaign_classes:
    CAMPAIGN_CLASS 0
    CAMPAIGN_CLASS 1
    CAMPAIGN_CLASS 2
    CAMPAIGN_CLASS 3
    CAMPAIGN_CLASS 4

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

.db race_tiefling
.db default_options_flags
.dw opt_race_tiefling_label

.db race_monster
.db 0
.dw opt_race_monster_label

; Leave space for 5 campaign-defined monsters
opt_campaign_race::
.block mi_data_size * 5

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

opt_yes_no:
.db 0
.db default_options_flags
.dw opt_yes_no_label_yes

.db 1
.db default_options_flags
.dw opt_yes_no_label_no

#define opt_stub_value 1

opt_stub:
.db opt_stub_value
.db default_options_flags
.dw opt_stub_label

stub_menu:
    ld a, 1
    ld hl, opt_stub
    ld b, 21
    ld c, 8
    call menu_ui
    ret
