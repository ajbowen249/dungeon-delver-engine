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

.local
; common data for reverse_array and sort_associative_array
array_start: .dw 0
swap_space: .dw 0
array_length: .db 0
data_size: .db 0

; Reverse the array at HL of length A data size D
; Requires swap space of length D at BC
reverse_array::
    ld (array_start), hl
    ld hl, bc
    ld (swap_space), hl

    ld (array_length), a
    ld a, d
    ld (data_size), a

    ; Swap from [0, n >> 1).
    ; If the length is even, it'll swap up to the last index of the first half.
    ; If the length is odd, it'll skip the central index.
    ld a, (array_length)
    rra
    and a, $7F
    ld hl, reverse_array_callback
    call iterate_a

    ret

reverse_array_callback:
    ld b, a
    ld a, (array_length)
    dec a
    sub a, b
    call swap_elements_a_b

    ret

sort_index: .db 0

; Sort the array at HL of length A data size D by its first byte
; Requires swap space of length D at BC
; Be careful, it's quadratic because I'm lazy
sort_associative_array::
    ld (array_start), hl
    ld hl, bc
    ld (swap_space), hl

    ld (array_length), a
    ld a, d
    ld (data_size), a

    ld a, 0
    ld (sort_index), a

sort_loop:
    call find_lowest
    ld b, a
    ld a, (sort_index)
    cp a, b ; If sort index == index_of_lowest, this is already the lowest item
    jp z, sort_loop_continue

    ; otherwise, swap
    call swap_elements_a_b

sort_loop_continue:
    ld a, (sort_index)
    inc a
    ld (sort_index), a
    ld b, a
    ld a, (array_length)
    cp a, b
    jp nz, sort_loop

    ret

; internal helper of sort_associative_array
; finds index of lowest item after and including sort_index
; NOTE: Comparisson is a little borked; treats it signed. NBD for now
lowest_search_index: .db 0
index_of_lowest: .db 0
lowest_value: .db 0
find_lowest:
    ld a, (sort_index)
    ld (lowest_search_index), a
    ld (index_of_lowest), a

    ld a, 127
    ld (lowest_value), a

find_lowest_loop:
    ld a, (lowest_value)
    ld e, a

    ld hl, (array_start)
    ld a, (lowest_search_index)
    ld b, a
    ld a, (data_size)
    call get_array_item
    ld a, (hl)

    cp e
    jp s, find_lowest_lower
    ld a, (lowest_search_index)
    jp find_lowest_continue
find_lowest_lower:
    ld (lowest_value), a
    ld a, (lowest_search_index)
    ld (index_of_lowest), a

find_lowest_continue:

    inc a
    ld (lowest_search_index), a
    ld b, a
    ld a, (array_length)
    cp a, b
    jp nz, find_lowest_loop

    ld a, (index_of_lowest)

    ret

; internal helper of sort_associative_array
; swaps index a with index b
swap_index_a:: .db 0
swap_index_b:: .db 0
swap_elements_a_b:
    ld (swap_index_a), a
    ld a, b
    ld (swap_index_b), a

; First back up index A to swap space
    ld hl, (array_start)
    ld a, (swap_index_a)
    ld b, a
    ld a, (data_size)
    call get_array_item
    ld de, hl

    ld hl, (swap_space)
    ld bc, hl

    ld hl, de
    ld a, (data_size)
    call copy_hl_bc

; Copy B over A
    ld hl, (array_start)
    ld a, (swap_index_b)
    ld b, a
    ld a, (data_size)
    call get_array_item
    ld de, hl

    ld hl, (array_start)
    ld a, (swap_index_a)
    ld b, a
    ld a, (data_size)
    call get_array_item
    ld bc, hl

    ld hl, de
    ld a, (data_size)
    call copy_hl_bc

; Copy swap space to index B
    ld hl, (swap_space)
    ld de, hl

    ld hl, (array_start)
    ld a, (swap_index_b)
    ld b, a
    ld a, (data_size)
    call get_array_item
    ld bc, hl

    ld hl, de
    ld a, (data_size)
    call copy_hl_bc

    ret
.endlocal

.local
copy_counter: .db 0
; copies A bytes from HL to BC
; uses d
copy_hl_bc::
    ld (copy_counter), a

copy_loop:
    ld de, hl
    ld a, (hl)
    ld hl, bc
    ld (hl), a
    ld hl, de
    inc hl
    inc bc

    ld a, (copy_counter)
    dec a
    ld (copy_counter), a
    cp a, 0
    jp nz, copy_loop
    ret
.endlocal
