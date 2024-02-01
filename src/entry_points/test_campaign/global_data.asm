player_party:
    DEFINE_PLAYER test_character1, 1, 2, 3, 4, 5, 6, race_human, class_barbarian, 1, "Fronk"
.db 0
.db 0
.db 0
.db 0
.db 0
    DEFINE_PLAYER test_character2, 7, 8, 9, 10, 11, 12, race_elf, class_cleric, 1, "Elfy"
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
    DEFINE_PLAYER test_character3, 13, 14, 15, 16, 17, 18, race_dwarf, class_fighter, 1, "Grumble"
.db 0
.db 0
.db 0
    DEFINE_PLAYER test_character4, 19, 20, 1, 2, 3, 4, race_half_elf, class_wizard, 1, "Sparkle"
.db 0
.db 0
.db 0

party_size: .db 0

    DEFINE_PLAYER test_npc_1, 1, 2, 3, 4, 5, 6, race_human, class_barbarian, 1, "Bossman"
.db 0
.db 0
.db 0

last_screen_exit_code: .db 0
last_screen_exit_argument: .db 0
