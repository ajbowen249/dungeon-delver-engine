.local
; Performs a skill check with the player at HL, against the skill in A, requiring a value of B or above
; A should be 0-5, in typical STR, DEX... order
; The menu will be displayed at column, row offset DE.
; Like menu, this does not clear its own area.
; A will be non-zero if the check passes, and zero if it fails.
skill_check_player: .dw 0
skill_check_skill: .db 0
skill_check_required: .db 0
skill_check_loc: .dw 0
skill_check_result: .db 0

skill_check_ui::
    ld (skill_check_skill), a
    ld a, b
    ld (skill_check_required), a

    ld (skill_check_player), hl
    ld hl, de
    ld (skill_check_loc), hl
    call set_cursor_hl

    ld hl, skill_labels
    ld a, (skill_check_skill)
    ld b, 4
    call get_array_item
    call print_compressed_string

    ld hl, check_str
    call print_compressed_string

    ld a, (skill_check_required)
    ld d, 0
    ld e, a
    call de_to_decimal_string
    ld hl, bc
    call print_string

    ld hl, (skill_check_loc)
    inc l
    call set_cursor_hl
    ld hl, roll_str
    call print_compressed_string

    ld a, (skill_check_skill)
    ld hl, (skill_check_player)
    call roll_ability_check
    ld (skill_check_result), a
    ld e, a
    ld d, 0
    call de_to_decimal_string
    ld hl, bc
    call print_string

    ld hl, (skill_check_loc)
    inc l
    inc l
    call set_cursor_hl

    ld a, (skill_check_required)
    ld b, a
    ld a, (skill_check_result)
    cp a, b
    jp m, fail

    ld hl, str_success
    call print_compressed_string
    ld a, 1
    ret

fail:
    ld hl, str_fail
    call print_compressed_string
    ld a, 0
    ret
.endlocal
