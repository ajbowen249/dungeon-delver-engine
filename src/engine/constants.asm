; SRD 5.1 stuff
#define ability_str 0
#define ability_dex 1
#define ability_con 2
#define ability_int 3
#define ability_wis 4
#define ability_chr 5
#define ability_max_value 18

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
#define race_monster 9

; player attributes structure
#define pl_name_max_len 10
#define pl_name_data_len 11

#define pl_offs_attrs_array 0
#define pl_offs_str 0
#define pl_offs_dex pl_offs_str + 1
#define pl_offs_con pl_offs_dex + 1
#define pl_offs_int pl_offs_con + 1
#define pl_offs_wis pl_offs_int + 1
#define pl_offs_chr pl_offs_wis + 1
#define pl_offs_race pl_offs_chr + 1
#define pl_offs_class pl_offs_race + 1
#define pl_offs_level pl_offs_class + 1
#define pl_offs_name pl_offs_level + 1

#define pl_data_size pl_offs_name + pl_name_data_len

; interactables data
#define in_offs_type 0
#define in_offs_flags in_offs_type + 1
#define in_offs_row in_offs_flags + 1
#define in_offs_col in_offs_row + 1
#define in_data_size in_offs_col + 1

; flags fields (msb-lsb):
; 7: is enabled
; 6: reserved
; 5: reserved
; 4: reserved
; 3: reserved
; 2: reserved
; 1: reserved
; 0: is trigger (interact on location match)

#define iflags_normal $80
#define iflags_door $81

; screen data structure
#define sc_background_data_len 21 * 8
#define sc_title_max_len 20
#define sc_title_data_len sc_title_max_len + 1
#define sc_interactable_array_elements 10
#define sc_interactable_array_length in_data_size * sc_interactable_array_elements

#define sc_offs_background 0
#define sc_offs_title sc_background_data_len
#define sc_offs_start_x sc_offs_title + sc_title_data_len
#define sc_offs_start_y sc_offs_start_x + 1
#define sc_offs_interactables_start sc_offs_start_y + 1
; interact prompt func takes index in A and returns string in HL
#define sc_offs_get_interaction_prompt sc_offs_interactables_start + sc_interactable_array_length
; interact callback takes index in A and sets A non-zero if the area should be exited
#define sc_offs_interact_callback sc_offs_get_interaction_prompt + 2
; menu callback is fired when the escape key is pressed, and control will return to exploration_ui when it returns
#define sc_offs_menu_callback sc_offs_interact_callback + 2

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

#define ec_none 0
#define ec_door 1
#define ec_encounter 2

#define skill_index_str 0
#define skill_index_dex 1
#define skill_index_con 2
#define skill_index_int 3
#define skill_index_wis 4
#define skill_index_chr 5
