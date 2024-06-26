resolving_character: .dw 0

#define class_fighter   0
#define class_wizard    1
#define class_cleric    2
#define class_barbarian 3
; leave room after built-in classes for the campaign to define its own
#define class_cutoff 8
#define class_m_badger 8
#define class_m_hobgoblin 9
#define class_m_goblin 10
#define class_m_drow_elf 11
#define class_m_duergar 12
#define campaign_monster_cutoff 16
#define monster_mask $F8

#define monster_size_tiny 0
#define monster_size_small 1
#define monster_size_medium 2
#define monster_size_large 3
#define monster_size_huge 4
#define monster_size_gargantuan 5

#define max_builtin_monsters 8
#define actual_builtin_monsters 5
#define remaining_builtin_monsters max_builtin_monsters - actual_builtin_monsters

#define max_campaign_monsters 2
