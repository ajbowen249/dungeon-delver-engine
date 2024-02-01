.local
; Given an array starting at HL of data size A, return the address of the item at index B
; uses BC
get_array_item::
    call mul_a_b
    ld b, 0
    ld c, a
    add hl, bc

    ret
.endlocal
