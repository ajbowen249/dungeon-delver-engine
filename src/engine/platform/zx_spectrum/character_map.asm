
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
#define ch_delete $0C
#define ch_left_arrow $08
#define ch_right_arrow $09
#define ch_up_arrow $0B
#define ch_down_arrow $0A

#define ch_line_feed $0A
#define ch_carriage_return $0D

#define ch_printable_arrow_right $3E
#define ch_printable_arrow_left $3C

#define ch_corner_upper_left $9A
#define ch_corner_upper_right $9B
#define ch_corner_lower_left $9C
#define ch_corner_lower_right $9D

#define ch_stick_person_1 $9E
#define ch_stick_person_2 $9F

#define ch_house $A0
#define ch_cross $A1
#define ch_quad_thing $A2
#define ch_pound_sterling $A3
#define ch_paragraph $A4
#define ch_mushroom $A5
#define ch_chest $A6
#define ch_diamond $A7
#define ch_up_down_arrows $A8

; custom table entries
#charset map "┌" = $80
#charset map "┐" = $81
#charset map "└" = $82
#charset map "┘" = $83
#charset map "┬" = $84
#charset map "├" = $85
#charset map "┴" = $86
#charset map "┤" = $87
#charset map "┼" = $88
#charset map "│" = $89
#charset map "─" = $8A
; TODO: These thick block characters are supposed to be in ROM somewhere, but I can't find them ¯\_(ツ)_/¯
#charset map "▛" = $8B
#charset map "▜" = $8C
#charset map "▙" = $8D
#charset map "▟" = $8E
#charset map "▌" = $8F
#charset map "▐" = $90
#charset map "▀" = $91
#charset map "▄" = $92
#charset map "█" = $93
#charset map "▘" = $94
#charset map "▝" = $95
#charset map "▗" = $96
#charset map "▖" = $97
#charset map "▚" = $98
#charset map "▞" = $99
#charset map "◤" = ch_corner_upper_left
#charset map "◥" = ch_corner_upper_right
#charset map "◣" = ch_corner_lower_left
#charset map "◢" = ch_corner_lower_right
#charset map "옷" = ch_stick_person_1
#charset map "왓" = ch_stick_person_2
#charset map "⌂" = ch_house
#charset map "✝" = ch_cross
#charset map "ㅑ" = ch_quad_thing
#charset map "£" = ch_pound_sterling
#charset map "¶" = ch_paragraph
#charset map "€" = ch_mushroom
#charset map "∩" = ch_chest
#charset map "◇" = ch_diamond
#charset map "↕" = ch_up_down_arrows
#charset map "▓" = $A9
#charset map "▔" = $AA
#charset map "▂" = $AB

custom_character_table:
; ┌
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b00011111
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b00010000
; ┐
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b11110000
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b00010000
; └
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b00011111
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b00000000
; ┘
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b11110000
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b00000000
; ┬
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b11111111
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b00010000
; ├
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b00011111
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b00010000
; ┴
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b11111111
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b00000000
; ┤
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b11110000
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b00010000
; ┼
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b11111111
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b00010000
; │
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b00010000
; ─
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b11111111
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b00000000
; ▛
.db 0b11111111
.db 0b11111111
.db 0b11111111
.db 0b11111111
.db 0b11110000
.db 0b11110000
.db 0b11110000
.db 0b11110000
; ▜
.db 0b11111111
.db 0b11111111
.db 0b11111111
.db 0b11111111
.db 0b00001111
.db 0b00001111
.db 0b00001111
.db 0b00001111
; ▙
.db 0b11110000
.db 0b11110000
.db 0b11110000
.db 0b11110000
.db 0b11111111
.db 0b11111111
.db 0b11111111
.db 0b11111111
; ▟
.db 0b00001111
.db 0b00001111
.db 0b00001111
.db 0b00001111
.db 0b11111111
.db 0b11111111
.db 0b11111111
.db 0b11111111
; ▌
.db 0b11110000
.db 0b11110000
.db 0b11110000
.db 0b11110000
.db 0b11110000
.db 0b11110000
.db 0b11110000
.db 0b11110000
; ▐
.db 0b00001111
.db 0b00001111
.db 0b00001111
.db 0b00001111
.db 0b00001111
.db 0b00001111
.db 0b00001111
.db 0b00001111
;▀
.db 0b11111111
.db 0b11111111
.db 0b11111111
.db 0b11111111
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b00000000
; ▄
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b11111111
.db 0b11111111
.db 0b11111111
.db 0b11111111
; █
.db 0b11111111
.db 0b11111111
.db 0b11111111
.db 0b11111111
.db 0b11111111
.db 0b11111111
.db 0b11111111
.db 0b11111111
; ▘
.db 0b11110000
.db 0b11110000
.db 0b11110000
.db 0b11110000
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b00000000
; ▝
.db 0b00001111
.db 0b00001111
.db 0b00001111
.db 0b00001111
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b00000000
; ▗
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b00001111
.db 0b00001111
.db 0b00001111
.db 0b00001111
; ▖
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b11110000
.db 0b11110000
.db 0b11110000
.db 0b11110000
; ▚
.db 0b11110000
.db 0b11110000
.db 0b11110000
.db 0b11110000
.db 0b00001111
.db 0b00001111
.db 0b00001111
.db 0b00001111
; ▞
.db 0b00001111
.db 0b00001111
.db 0b00001111
.db 0b00001111
.db 0b11110000
.db 0b11110000
.db 0b11110000
.db 0b11110000
; ◤
.db 0b11111110
.db 0b11111100
.db 0b11111000
.db 0b11110000
.db 0b11100000
.db 0b11000000
.db 0b10000000
.db 0b00000000
; ◥
.db 0b01111111
.db 0b00111111
.db 0b00011111
.db 0b00001111
.db 0b00000111
.db 0b00000011
.db 0b00000001
.db 0b00000000
; ◣
.db 0b00000000
.db 0b10000000
.db 0b11000000
.db 0b11100000
.db 0b11110000
.db 0b11111000
.db 0b11111100
.db 0b11111110
; ◢
.db 0b00000000
.db 0b00000001
.db 0b00000011
.db 0b00000111
.db 0b00001111
.db 0b00011111
.db 0b00111111
.db 0b01111111
; 옷
.db 0b00010000
.db 0b00101000
.db 0b00010000
.db 0b00111000
.db 0b01010100
.db 0b00010000
.db 0b00101000
.db 0b01000100
; 왓
.db 0b00010000
.db 0b00101000
.db 0b10010000
.db 0b01111000
.db 0b00010100
.db 0b00010000
.db 0b00101000
.db 0b01000100
; ⌂
.db 0b00010000
.db 0b00111000
.db 0b01111100
.db 0b01010100
.db 0b01111100
.db 0b01010100
.db 0b01111100
.db 0b00000000
; ✝
.db 0b00010000
.db 0b00010000
.db 0b00111000
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b00010000
.db 0b00000000
; ㅑ
.db 0b01011010
.db 0b01111110
.db 0b01011010
.db 0b00011000
.db 0b00011000
.db 0b01011010
.db 0b01111110
.db 0b01011010
; £
.db 0b00000000
.db 0b00011100
.db 0b00100010
.db 0b00100000
.db 0b01110000
.db 0b00100000
.db 0b00100000
.db 0b01110000
; ¶
.db 0b00000000
.db 0b01111100
.db 0b10101000
.db 0b10101000
.db 0b01111100
.db 0b00101000
.db 0b00101000
.db 0b00101000
; € (mushroom)
.db 0b00000000
.db 0b00110000
.db 0b01001000
.db 0b10000100
.db 0b11111100
.db 0b01001000
.db 0b01001000
.db 0b11001100
; ∩ (chest)
.db 0b00000000
.db 0b00111100
.db 0b01000010
.db 0b10000001
.db 0b11111111
.db 0b10000001
.db 0b10000001
.db 0b11000011
; ◇
.db 0b00010000
.db 0b00101000
.db 0b01000100
.db 0b10000010
.db 0b01000100
.db 0b00101000
.db 0b00010000
.db 0b00000000
; ↕
.db 0b00010000
.db 0b00111000
.db 0b01010100
.db 0b00010000
.db 0b00010000
.db 0b01010100
.db 0b00111000
.db 0b00010000
; ▓
.db 0b10101010
.db 0b01010101
.db 0b10101010
.db 0b01010101
.db 0b10101010
.db 0b01010101
.db 0b10101010
.db 0b01010101
; ▔
.db 0b11111111
.db 0b11111111
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b00000000
; ▂
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b00000000
.db 0b11111111
.db 0b11111111
