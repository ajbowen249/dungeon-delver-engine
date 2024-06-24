; ldhx - a faster serial hex loader
; Currently the assembly language equivalent of utils/loadhx.ba, since the BASIC version gets overloaded after a while
; with a delay of any less than 50ms per character.

    call main

#define start_address $B200
#include "../../engine/constants.asm"
#include "./old_rom_api.asm"
#include "../../engine/util.asm"
#include "../../engine/hex_string.asm"

loading_message: .asciz "Loading"
done_message: .asciz "Done"

expected_line_length: .db 0
current_byte_index: .db 0
current_sum: .db 0
writing_address: .dw 0

main:
    ld hl, start_address
    ld (writing_address), hl
    call clear_screen
    ld h, 1
    ld l, 1
    call set_cursor_hl

    ld hl, loading_message
    call print_string

    call initialize_rs232

main_read_loop:
    ld h, 1
    ld l, 1
    call set_cursor_hl

    ld hl, newline_string
    call print_string
    ld hl, (writing_address)
    ld de, hl
    ld bc, glob_de_to_hex_str_buffer
    call de_to_hex_str
    ld hl, bc
    call print_string

    call read_line_header
    ld a, (expected_line_length)
    ld (current_sum), a ; sum actually includes line length
    cp a, 0
    jp z, done_reading

    call read_hex_pair ; address byte 1
    ld b, a
    ld a, (current_sum)
    add a, b
    ld (current_sum), a

    call read_hex_pair ; address byte 2
    ld b, a
    ld a, (current_sum)
    add a, b
    ld (current_sum), a

    call read_hex_pair ; type byte
    ld b, a
    ld a, (current_sum)
    add a, b
    ld (current_sum), a

    ld a, 0
    ld (current_byte_index), a

line_read_loop:
    call read_hex_pair

    ld hl, (writing_address)
    ld (hl), a
    inc hl
    ld (writing_address), hl

    ld b, a
    ld a, (current_sum)
    add a, b
    ld (current_sum), a

    ld a, (current_byte_index)
    inc a
    ld (current_byte_index), a

    ld b, a
    ld a, (expected_line_length)
    cp a, b
    jp nz, line_read_loop

    ; finalize our calculated checksum
    ld a, (current_sum)
    cpl
    inc a
    ld (current_sum), a

    ; read the checksum
    call read_hex_pair
    ld b, a
    ld (current_sum), a
    cp a, b
    call nz, checksum_warning

    jp main_read_loop

done_reading:
    ld hl, done_message
    call print_string

    call rom_clscom
    ret

com_connection_string: .asciz "88N1E"

initialize_rs232:
    ; set the carry flag to indicate RS232-C (reset would select modem)
    ld a, 5
    cp a, 10
    ld hl, com_connection_string
    call rom_setser
    ret

read_line_header:
    ; wait for the colon (skip whitespace)
colon_loop:
    call rom_rv232c
    cp a, ":"
    jp nz, colon_loop

    call read_hex_pair
    ld (expected_line_length), a
    ret

read_hex_pair:
    call rom_rv232c
    call parse_a_as_hex_digit
    rla
    rla
    rla
    rla
    and a, $F0
    ld b, a

    call rom_rv232c
    call parse_a_as_hex_digit

    add a, b
    ret

check_warning_string: .asciz "Checksum warning!"
checksum_warning:
    ld hl, check_warning_string
    call print_string
    ret
