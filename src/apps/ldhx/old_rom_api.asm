; Only continuing to support this for the Model 100 for now, so re-using the old rom_api.asm to keep it decoupled

#define print_a $4B44
#define set_cursor_hl $427C
#define clear_screen $4231
#define keyread_a $7242
#define rom_setser $17E6
#define rom_clscom $6ECB
#define rom_rcvx $6D6D
#define rom_rv232c $6D7E

newline_string:
.db ch_line_feed
.db ch_carriage_return
.db 0

.local
; Prints the string starting at HL
; Destroys HL, a
print_string::
loop:
    ld a, (hl) ; read character
    cp a, 0    ; if it's zero...
    jp z, return ; ...we're done
    call print_a
    inc hl
    jp loop
return:
    ret
.endlocal

.macro PRINT_AT_LOCATION &ROW, &COL, &STRING_ADDR
    ld h, &COL
    ld l, &ROW
    call set_cursor_hl

    ld hl, &STRING_ADDR
    call print_string
.endm

.macro PRINT_COMPRESSED_AT_LOCATION &ROW, &COL, &STRING_ADDR
    ld h, &COL
    ld l, &ROW
    call set_cursor_hl

    ld hl, &STRING_ADDR
    call print_compressed_string
.endm

; character set
#charset ascii

#define ch_line_feed $0A
#define ch_carriage_return $0D
