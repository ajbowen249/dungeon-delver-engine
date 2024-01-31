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

; memory locations
#define seconds_10s $F934
#define seconds_1s $F933
