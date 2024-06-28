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

#define ex_view_col 1
#define ex_view_row 1

#define ex_message_col 21
#define ex_message_row 1

#define ex_title_col 21
#define ex_title_row 1

#define ra_ability_label_col 2
#define ra_ability_label_row 2
#define ra_instructions_col 22
#define ra_instructions_row 2

#define ba_action_menu_column 8
#define ba_action_menu_row 1
#define ba_message_row 7
#define ba_cast_damage_colum 23
#define ba_victory_col 16
#define ba_game_over_col 15
#define ba_end_msg_row 4

#define ch_pause_escape_key ch_escape

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

; analogous mappings
#charset map "▛" = $EB
#charset map "▜" = $EC
#charset map "▙" = $ED
#charset map "▟" = $EE
#charset map "▌" = $E9
#charset map "▐" = $EA
#charset map "▀" = $E7
#charset map "▄" = $E8
#charset map "█" = $EF
#charset map "▘" = $E1
#charset map "▝" = $E2
#charset map "▗" = $E4
#charset map "▖" = $E3
#charset map "▚" = $E5
#charset map "▞" = $E6
#charset map "▔" = $E7
#charset map "▂" = $E8
#charset map "▓" = $FF

#charset map "┌" = $F0
#charset map "┐" = $F2
#charset map "└" = $F6
#charset map "┘" = $F7
#charset map "│" = $F5
#charset map "─" = $F1
#charset map "┬" = $F3
#charset map "├" = $F4
#charset map "┴" = $F8
#charset map "┤" = $F9
#charset map "┼" = $FA

#charset map "◤" = ch_corner_upper_left
#charset map "◥" = ch_corner_upper_right
#charset map "◣" = ch_corner_lower_left
#charset map "◢" = ch_corner_lower_right

#charset map "↕" = ch_up_down_arrows
#charset map "◇" = ch_diamond
#charset map "✝" = ch_cross

#charset map "⌂" = ch_house
#charset map "£" = ch_pound_sterling
#charset map "¶" = ch_paragraph

#charset map "옷" = ch_stick_person_1
#charset map "왓" = ch_stick_person_2

; replacement mappings (character in source doesn't resemble character in game)
#charset map "∩" = ch_chest
#charset map "€" = ch_mushroom
#charset map "ㅑ" = ch_quad_thing

#define ex_avatar_char ch_stick_person_1
