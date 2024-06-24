; Direct rom routines (already match interface)
#define print_a $4B44
#define set_cursor_hl $427C
#define clear_screen $4231
#define keyread_a $7242

#define rom_inlin $4644
#define rom_inlin_result $F685
inlin_hl:
    call rom_inlin
    ld hl, rom_inlin_result
    ret

#define seconds_10s $F934
#define seconds_1s $F933

#define random_seed_0 seconds_10s
#define random_seed_1 seconds_1s

; character set
#charset ascii

#define ch_A $41
#define ch_D $44
#define ch_R $52
#define ch_S $53
#define ch_W $57
#define ch_R $52
#define ch_C $43

#define ch_a $61
#define ch_d $64
#define ch_r $72
#define ch_s $73
#define ch_w $77
#define ch_r $72
#define ch_c $63

#define ch_enter $0D
#define ch_escape $1B
#define ch_left_arrow $1D
#define ch_right_arrow $1C
#define ch_up_arrow $1E
#define ch_down_arrow $1F

#define ch_printable_arrow_right $9A
#define ch_printable_arrow_left $9B

#define ch_mushroom $90
#define ch_chest $91
#define ch_up_down_arrows $92
#define ch_stick_person_1 $93
#define ch_stick_person_2 $94
#define ch_diamond $9D

#define ch_corner_upper_left $FB
#define ch_corner_upper_right $FD
#define ch_corner_lower_left $FE
#define ch_corner_lower_right $FC

#define ch_line_feed $0A
#define ch_carriage_return $0D
#define ch_house $86
#define ch_cross $A8
#define ch_quad_thing $84
#define ch_pound_sterling $BF
#define ch_paragraph $AF

; these are reasonable accurate
#charset map "▛" = $8B
#charset map "▜" = $87
#charset map "▙" = $8E
#charset map "▟" = $8D
#charset map "▌" = $8A
#charset map "▐" = $85
#charset map "▀" = $83
#charset map "▄" = $8C
#charset map "█" = $8F
#charset map "▘" = $82
#charset map "▝" = $81
#charset map "▗" = $84
#charset map "▖" = $88
#charset map "▚" = $86
#charset map "▞" = $89
#charset map "▔" = $83
#charset map "▂" = $8C

; none of these are mppaed yet!
#charset map "┌" = $FF
#charset map "┐" = $FF
#charset map "└" = $FF
#charset map "┘" = $FF
#charset map "│" = $FF
#charset map "─" = $FF
#charset map "┬" = $FF
#charset map "├" = $FF
#charset map "┴" = $FF
#charset map "┤" = $FF
#charset map "┼" = $FF

#charset map "◤" = ch_corner_upper_left
#charset map "◥" = ch_corner_upper_right
#charset map "◣" = ch_corner_lower_left
#charset map "◢" = ch_corner_lower_right

#charset map "⌂" = ch_house
#charset map "£" = ch_pound_sterling
#charset map "¶" = ch_paragraph

#charset map "옷" = ch_stick_person_1
#charset map "왓" = ch_stick_person_2

; replacement mappings (character in source doesn't resemble character in game)
#charset map "∩" = ch_chest
#charset map "€" = ch_mushroom
#charset map "ㅑ" = ch_quad_thing
