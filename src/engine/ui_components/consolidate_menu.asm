.local
; Given a set of menu options starting at HL of length A, copy each element into the array starting at BC, skipping
; all disabled options and returning the consolidated length in A.
src_menu: .dw 0
dst_menu: .dw 0
full_item_count: .db 0
final_item_count: .db 0
scan_index: .db 0

consolidate_menu_hl_bc::
    ld (src_menu), hl
    ld hl, bc
    ld (dst_menu), hl

    ld (full_item_count), a
    ld a, 0
    ld (final_item_count), a
    ld (scan_index), a

consolidate_loop:
    ld hl, (src_menu)
    ld bc, mi_offs_flags
    add hl, bc
    ld a, (hl)
    ld b, $01
    and a, b
    jp z, consolidate_loop_continue

    ld hl, (dst_menu)
    ld bc, hl
    ld hl, (src_menu)
    ld a, mi_data_size
    call copy_hl_bc

    ld hl, (dst_menu)
    ld bc, mi_data_size
    add hl, bc
    ld (dst_menu), hl

    ld a, (final_item_count)
    inc a
    ld (final_item_count), a

consolidate_loop_continue:
    ld hl, (src_menu)
    ld bc, mi_data_size
    add hl, bc
    ld (src_menu), hl

    ld a, (scan_index)
    inc a
    ld (scan_index), a
    ld b, a
    ld a, (full_item_count)
    cp a, b
    jp nz, consolidate_loop

    ld a, (final_item_count)
    ret
.endlocal
