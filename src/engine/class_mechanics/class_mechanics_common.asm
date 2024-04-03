resolving_character: .dw 0

.macro POINT_HL_TO_ATTR &OFFSET
    ld bc, &OFFSET
    add hl, bc
.endm

.macro LOAD_A_WITH_ATTR_THROUGH_HL &OFFSET
    POINT_HL_TO_ATTR &OFFSET
    ld a, (hl)
.endm

.macro WRITE_A_TO_ATTR_THROUGH_HL &OFFSET
    POINT_HL_TO_ATTR &OFFSET
    ld (hl), a
.endm

#define class_fighter   0
#define class_wizard    1
#define class_cleric    2
#define class_barbarian 3
; leave room after built-in classes for the campaign to define its own
; Don't want to blow 512 bytes on every table, so setting the class limit to 16
#define class_cutoff 8
#define class_m_badger 8
#define class_m_hobgoblin 9
#define class_m_goblin 10
#define class_m_drow_elf 11
#define campaign_monster_cutoff 16
#define monster_mask $F8

#define monster_size_tiny 0
#define monster_size_small 1
#define monster_size_medium 2
#define monster_size_large 3
#define monster_size_huge 4
#define monster_size_gargantuan 5

#define max_builtin_classes 8
#define actual_builtin_classes 4
#define remaining_campaign_classes max_builtin_classes - actual_builtin_classes

#define max_campaign_monsters 8
