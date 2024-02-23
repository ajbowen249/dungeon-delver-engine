.local
; returns non-zero in A if the character in HL should move to the front row
should_enemy_move_front::
    LOAD_A_WITH_ATTR_THROUGH_HL pl_offs_class

    cp a, class_wizard
    jp z, do_not_move

    cp a, class_cleric
    jp z, do_not_move

    ld a, 1
    ret

do_not_move:
    ld a, 0
    ret
.endlocal
