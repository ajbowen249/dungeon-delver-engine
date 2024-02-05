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

#define ch_mushroom $90
#define ch_chest $91
#define ch_up_down_arrows $92
#define ch_stick_person_1 $93
#define ch_stick_person_2 $94
#define ch_diamond $9D

; analogous mappings
#charset map "┌" = $F0
#charset map "┐" = $F2
#charset map "└" = $F6
#charset map "┘" = $F7
#charset map "│" = $F5
#charset map "─" = $F1

; replacement mappings (character in source doesn't resemble character in game)
#charset map "∩" = ch_chest
#charset map "α" = ch_stick_person_2

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

#define class_fighter   0
#define class_wizard    1
#define class_cleric    2
#define class_barbarian 3
; unimplemented below here
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
#define pl_offs_level 8
#define pl_offs_name 9

#define pl_data_size pl_offs_name + pl_name_data_len

; interactables data
#define in_type_offset 0
#define in_flags_offset 1
#define in_row_offset 2
#define in_col_offset 3
#define in_data_length 4 ; type, flags, row, col

; flags fields (msb-lsb):
; 7: reserved
; 6: reserved
; 5: reserved
; 4: reserved
; 3: reserved
; 2: reserved
; 1: reserved
; 0: is trigger (interact on location match)

; screen data structure
#define sc_background_data_len 21 * 8
#define sc_title_max_len 20
#define sc_title_data_len sc_title_max_len + 1
#define sc_interactable_array_elements 10
#define sc_interactable_array_length in_data_length * sc_interactable_array_elements

#define sc_offs_background 0
#define sc_offs_title sc_background_data_len
#define sc_offs_start_x sc_offs_title + sc_title_data_len
#define sc_offs_start_y sc_offs_start_x + 1
#define sc_offs_interactables_start sc_offs_start_y + 1
; interact prompt func takes index in A and returns string in HL
#define sc_offs_get_interaction_prompt sc_offs_interactables_start + sc_interactable_array_length
; interact callback takes index in A and sets A non-zero if the area should be exited
#define sc_offs_interact_callback sc_offs_get_interaction_prompt + 2

; interactable types
#define in_none 0
#define in_chest 1
#define in_dialog 2
#define in_door 3
#define in_npc 4

; combatant data
#define cbt_offs_flags 0
; combatant flags fields (msb-lsb):
; 7: reserved
; 6: reserved
; 5: reserved
; 4: reserved
; 3: reserved
; 2: battle line (0: front, 1: back)
; 1: 0: dead, 1: alive (1 here with 0 HP is "down")
; 0: faction (0: party, 1: enemy)
#define cbt_offs_initiative cbt_offs_flags + 1
#define cbt_offs_armor_class cbt_offs_initiative + 1
#define cbt_offst_hit_points cbt_offs_armor_class + 1 ; 2 bytes!
#define cbt_data_length cbt_offst_hit_points + 2

; start everyone in the back for now.
#define cbt_initial_party_flags $06
#define cbt_initial_enemy_flags $07

#define cbt_flag_line $04
#define cbt_flag_alive $02
#define cbt_flag_faction $01

#define mi_offs_value 0
#define mi_offs_flags mi_offs_value + 1
#define mi_offs_label mi_offs_flags + 1 ; 2 bytes
#define mi_data_size mi_offs_label + 2
