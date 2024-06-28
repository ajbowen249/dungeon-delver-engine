zx_cursor_y: .db 0
zx_cursor_x: .db 0

.local
screen_regions:
.db $40
.db $48
.db $50

; Returns the address in screen memeory of the character pointed to by the Spectrum cursor.
; Check spectrum_table.md for more info.
get_spectrum_cursor_address::
    ; first byte is the region. Divide the row by 8 to get 0, 1, or 2, and index into the table
    ld a, (zx_cursor_y)
    srl a
    srl a
    srl a
    ld hl, screen_regions
    ld b, 0
    ld c, a
    add hl, bc
    ld a, (hl)
    ld b, a
    push bc

    ; next nibble is row * 2, plus 1 if the column is above 16
    ld a, (zx_cursor_y)
    sla a
    ld b, a
    ld a, (zx_cursor_x)
    ; divide by 16
    srl a
    srl a
    srl a
    srl a
    add a, b
    ; Move over to the higher nibble
    sla a
    sla a
    sla a
    sla a
    ld c, $F0
    and a, c
    ld b, a

    ; last nibble is the lower part of the column
    ld a, (zx_cursor_x)
    ld c, $0F
    and a, c
    or a, b

    ld d, a
    pop bc
    ld h, b
    ld l, d

    ret
.endlocal

.local
#define spectrum_character_table $3C00

; given a character in A, return the address in ROM of that character's bitmap
get_spectrum_character_address::
    cp a, $80
    jp nc, user_defined_character

    ; note: get_array_item only works for items less than 256 bytes away from the start
    ld h, 0
    ld l, a
    ; multiply the character by 8
    add hl, hl
    add hl, hl
    add hl, hl

    ld bc, spectrum_character_table
    add hl, bc
    ret

user_defined_character:
    sub a, $80
    ; note: get_array_item only works for items less than 256 bytes away from the start
    ld h, 0
    ld l, a
    ; multiply the character by 8
    add hl, hl
    add hl, hl
    add hl, hl
    ld bc, custom_character_table
    add hl, bc

    ret
.endlocal

.local
print_a::
    ; interface assumes HL and DE will be preserved
    push hl
    push de

    call get_spectrum_character_address
    push hl

    call get_spectrum_cursor_address
    pop de
    ld b, 8

    ; de has the location of the character bitmap, and hl has the address we need to write to
print_a_copy_loop:
    ld a, (de)
    ld (hl), a
    inc h
    inc de
    djnz print_a_copy_loop

    ; advance the cursor
    ld a, (zx_cursor_x)
    inc a
    ld (zx_cursor_x), a

    ; restore HL and DE
    pop de
    pop hl
    ret
.endlocal

.local
#define rom_keyread_af $10A8
keyread_a::
    call rom_keyread_af
    jp c, done

    ; The spectrum flags whether a key was pressed by setting carry.
    ; Since it wasn't set, clear A to match DDE's interface.
    ld a, 0

done:
    ret
.endlocal

.local
set_cursor_hl::
    push hl
    ; Interface requirement is 1-indexed, but Spectrum coordinates are 0-based at this level.
    dec h
    dec l
    ld (zx_cursor_y), hl
    pop hl
    ret
.endlocal


#define rom_clear_screen $0DAF
clear_screen:
    push hl
    call rom_clear_screen
    ld hl, $0101
    call set_cursor_hl
    pop hl
    ret

.local
#define ZX_INPUT_BUFFER_LENGTH 10
inlin_buffer: .block ZX_INPUT_BUFFER_LENGTH + 1, 0
inlin_ptr: .dw 0
inlin_len: .db 0

inlin_hl::
    ld a, 0
    ld a, (inlin_len)

    ld hl, inlin_buffer
    ld (inlin_ptr), hl

loop:
    ld a, "█"
    call print_a
    ld a, (zx_cursor_x)
    dec a
    ld (zx_cursor_x), a

    call keyread_a
    ld hl, (inlin_ptr)

    cp a, 0
    jp z, loop

    cp a, ch_delete
    jp z, on_delete

    cp a, ch_enter
    jp z, on_enter

    ld (hl), a
    call print_a

    ld a, (inlin_len)
    inc a
    cp a, ZX_INPUT_BUFFER_LENGTH + 1
    jp z, at_length

    ld (inlin_len), a
    inc hl
    ld (inlin_ptr), hl

    jp loop

at_length:
    ld a, (zx_cursor_x)
    dec a
    ld (zx_cursor_x), a
    jp loop

on_delete:
    ld a, (inlin_len)
    cp a, 0
    jp z, loop

    ld a, " "
    call print_a

    ld a, (zx_cursor_x)
    dec a
    dec a
    ld (zx_cursor_x), a
    ld a, " "
    call print_a

    ld a, (zx_cursor_x)
    dec a
    ld (zx_cursor_x), a

    ld a, (inlin_len)
    dec a
    ld (inlin_len), a

    dec hl
    ld (inlin_ptr), hl

    jp loop

on_enter:
    ld a, 0
    ld (hl), a
    ld hl, inlin_buffer
    ret
.endlocal
