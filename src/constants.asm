; character set
#charset ascii

#define ch_A $41
#define ch_D $44
#define ch_R $52
#define ch_S $53
#define ch_W $57

#define ch_a $61
#define ch_d $64
#define ch_r $72
#define ch_s $73
#define ch_w $77

#define ch_enter $0D
#define ch_left_arrow $1D
#define ch_right_arrow $1C
#define ch_up_arrow $1E
#define ch_down_arrow $1F

#define ch_printable_arrow_right $9A
#define ch_printable_arrow_left $9B

#define ch_stick_person_1 $93
#define ch_stick_person_2 $94

#charset map "┌" = $F0
#charset map "┐" = $F2
#charset map "└" = $F6
#charset map "┘" = $F7
#charset map "│" = $F5
#charset map "─" = $F1

; SRD 5.1 stuff
#define ability_max_value 20

; none yet implemented
#define race_human      0
#define race_elf        1
#define race_dwarf      2
#define race_half_elf   3
#define race_gnome      4
#define race_halfling   5
#define race_half_orc   6
#define race_tiefling   7
#define race_dragonborn 8

; none yet implemented
#define class_fighter   0
#define class_wizard    1
#define class_cleric    2
#define class_barbarian 3
#define class_artificer 4
#define class_bard      5
#define class_druid     6
#define class_monk      7
#define class_paladin   8
#define class_ranger    9
#define class_rogue    10
#define class_sorcerer 11
#define class_warlock  12

; player attributes structure
#define pl_name_max_len 10
#define pl_name_data_len 11

#define pl_offs_str 0
#define pl_offs_dex 1
#define pl_offs_con 2
#define pl_offs_int 3
#define pl_offs_wis 4
#define pl_offs_chr 5
#define pl_offs_race 6
#define pl_offs_class 7
#define pl_offs_name 8

; screen data structure
#define sc_offs_background 0
#define sc_offs_start_x 168
#define sc_offs_start_y 169