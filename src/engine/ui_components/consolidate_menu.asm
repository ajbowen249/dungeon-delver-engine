common_consolidated_menu: ; Can show up to 7 options at the moment
.block mi_data_size * 7, 0

.local
; Given a set of menu options starting at HL of length A, copy each element into the array starting at BC, skipping
; all disabled options and returning the consolidated length in A.
src_menu: .dw 0
dst_menu: .dw 0
full_item_count: .db 0
final_item_count: .db 0

consolidate_menu_hl_bc::
    ld (src_menu), hl
    ld hl, bc
    ld (dst_menu), hl

    ld (full_item_count), a
    ld a, 0
    ld (final_item_count), a

    ld a, (full_item_count)
    ld hl, consolidate_callback
    call iterate_a

    ld a, (final_item_count)
    ret

consolidate_callback:
    ld b, a
    ld a, mi_data_size
    ld hl, (src_menu)
    call get_array_item
    ld de, hl

    LOAD_A_WITH_ATTR_THROUGH_HL mi_offs_flags
    ld c, $01
    and a, c
    jp z, consolidate_callback_done

    ld hl, (dst_menu)
    ld bc, hl
    ld hl, de
    ld a, mi_data_size
    call copy_hl_bc

    ld hl, (dst_menu)
    ld bc, mi_data_size
    add hl, bc
    ld (dst_menu), hl

    ld a, (final_item_count)
    inc a
    ld (final_item_count), a

consolidate_callback_done:
    ret
.endlocal
