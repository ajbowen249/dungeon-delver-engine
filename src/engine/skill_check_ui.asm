.local
; Performs a skill check with the player at HL, against the skill in A, requiring a value of B or above
; A should be 0-5, in typical STR, DEX... order
; The menu will be displayed at column, row offset DE.
; Like menu, this does not clear its own area.
skill_check_player: .dw 0
skill_check_skill: .db 0
skill_check_required: .db 0
skill_check_loc: .dw 0

check_str: .asciz " check: "

skill_check_ui::
    ld (skill_check_skill), a
    ld a, b
    ld (skill_check_required), a

    ld (skill_check_player), hl
    ld hl, de
    ld (skill_check_loc), hl
    call rom_set_cursor

    ld hl, skill_labels
    ld a, (skill_check_skill)
    ld b, 4
    call get_array_item
    call print_string

    ld hl, check_str
    call print_string

    ld a, (skill_check_required)
    ld d, 0
    ld e, a
    call de_to_decimal_string
    ld hl, bc
    call print_string

    ret
.endlocal
