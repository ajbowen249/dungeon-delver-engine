; rom routines
#define rom_print_a $4B44
#define rom_escape_a $4270
#define rom_home_cursor $422D
#define rom_set_cursor $427C
#define rom_lock_display $423F
#define rom_unlock_display $4244
#define rom_cursor_on $4249
#define rom_cursor_off $424E
#define rom_clear_screen $4231
#define rom_disable_interrupt_7_5 $765C
#define rom_enable_interrupt_7_5 $743C
#define rom_chget $12CB
#define rom_kyread $7242
#define rom_inlin $4644
#define rom_enter_reverse_video $4269
#define rom_exit_reverse_video $426E
#define rom_setser $17E6
#define rom_clscom $6ECB
#define rom_rcvx $6D6D
#define rom_rv232c $6D7E

; memory locations
#define seconds_10s $F934
#define seconds_1s $F933
#define inlin_result $F685

.macro PRINT_AT_LOCATION &ROW, &COL, &STRING_ADDR
    ld h, &COL
    ld l, &ROW
    call rom_set_cursor

    ld hl, &STRING_ADDR
    call print_string
.endm

; Prints the string starting at HL
; Destroys HL, a
.local
print_string::
loop:
    ld a, (hl) ; read character
    cp a, 0    ; if it's zero...
    jp z, return ; ...we're done
    call rom_print_a
    inc hl
    jp loop
return:
    ret
.endlocal

newline_string:
.db ch_line_feed
.db ch_carriage_return
.db 0
