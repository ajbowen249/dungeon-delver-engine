; Dungeon Delver Engine Test Campaign
; This is a CRPG built on the Dungeon Delver Engine

.org $C000

; Keep this at the top; this is the entry point
    call main
    ret

#include "../dde.asm"

test_characters:
    DEFINE_PLAYER test_character1, 1, 2, 3, 4, 5, 6, race_human, class_barbarian, "Fronk"
.db 0
.db 0
.db 0
.db 0
.db 0
    DEFINE_PLAYER test_character2, 7, 8, 9, 10, 11, 12, race_elf, class_cleric, "Elfy"
.db 0
.db 0
.db 0
.db 0
.db 0
.db 0
    DEFINE_PLAYER test_character3, 13, 14, 15, 16, 17, 18, race_dwarf, class_fighter, "Grumble"
.db 0
.db 0
.db 0
    DEFINE_PLAYER test_character4, 19, 20, 1, 2, 3, 4, race_half_elf, class_wizard, "Sparkle"
.db 0
.db 0
.db 0

party_size: .db 0

main:
    call seed_random

    ld hl, test_characters
    call party_wizard
    cp a, 0
    jp nz, show_sheets
    ld a, 4

show_sheets:
    ld (party_size), a

    ld hl, test_character1
    call character_sheet_ui

    ld a, (party_size)
    cp a, 2
    jp m, sheets_done

    ld hl, test_character2
    call character_sheet_ui

    ld a, (party_size)
    cp a, 3
    jp m, sheets_done

    ld hl, test_character3
    call character_sheet_ui

    ld a, (party_size)
    cp a, 4
    jp m, sheets_done

    ld hl, test_character4
    call character_sheet_ui

sheets_done:

    ld hl, test_characters
    ld a, (party_size)
    call exploration_ui
    ret
