; Dungeon Delver Engine
; This is a CRPG engine that implements a subset of OGL SRD 5.1

; Test assembly program for Model 100
.org $E290

; Keep this at the top; this is the entry point
    call main
    ret

#include "util.asm"
#include "constants.asm"
#include "rom_api.asm"
#include "random.asm"
#include "dice.asm"
#include "string.asm"
#include "simple_menu.asm"

#include "character_builder/character_builder.asm"

test_character:
tc_str: .db 0
tc_dex: .db 0
tc_con: .db 0
tc_int: .db 0
tc_wis: .db 0
tc_chr: .db 0
tc_race: .db 0
tc_class: .db 0
tc_name: .asciz "          "

main:
    call seed_random

    ld hl, test_character
    call create_character_ui

    ret
