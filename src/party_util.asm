.local
; Given a party array starting at HL, update HL to the address of the player at index A
; uses BC
get_party_member::
    ld b, a
    ld a, pl_data_size
    call mul_a_b
    ld b, 0
    ld c, a
    add hl, bc

    ret
.endlocal
