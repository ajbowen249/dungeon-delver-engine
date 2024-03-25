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
    call rom_print_a
    inc hl
    jp loop
return:
    ret
.endlocal
