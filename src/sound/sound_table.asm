; ============================================================================
; Sound player - The table of sounds
; ============================================================================

	public sound_table
	extrn empty_sound,sound_01,sound_02,sound_03,sound_04,sound_05
	extrn sound_06,sound_07,sound_08,sound_09,sound_10,sound_11
	extrn sound_12,sound_13,sound_14,sound_15,sound_16,sound_17
	extrn sound_18,sound_19,sound_20,sound_21,sound_22,sound_23
	extrn sound_24,sound_25,sound_26,sound_27,sound_28,sound_29
	extrn sound_30,sound_31,sound_32,sound_33,sound_34,sound_35
	extrn sound_36,sound_37,sound_38,sound_39,sound_40,sound_41
	extrn sound_42,sound_43,sound_44,sound_45,sound_46,sound_47
	extrn sound_48,sound_49,sound_50,sound_51,sound_52,sound_53
	extrn sound_54,sound_55,sound_56,sound_57,sound_58,sound_59
	extrn sound_60,sound_61,sound_62,sound_63,sound_64,sound_65
	extrn sound_66,sound_67,sound_68,sound_69,sound_70,sound_71
	extrn sound_72,sound_73,sound_74,sound_75,sound_76

;
; Eighty words: the address of each sound. Read by bank 0 at 0x4A49 with
; `ld de,sound_table` and `call add_a_to_de` (DE += A), with A = sound number times two.
; It is public: the main image would get its address from the symbols file
; instead of writing sound_table.

; ----------------------------------------------------------------------
; DATA sound_table: Eighty words: the address of each sound. Read by 0x4A49 in
;   bank 0 with `ld de,0x8328` and `call add_a_to_de` (DE += A), with A = sound
;   number times two. Entry 0 (0x393C) is not a cartridge address: sound 0
;   does not exist. The last three point to empty_sound, the first filler byte of
;   bank 8, that is, to an empty sound.
sound_table:
	defw 0393Ch		; 0: not an address, sound 0 does not exist
	defw sound_01
	defw sound_02
	defw sound_03
	defw sound_04
	defw sound_05
	defw sound_06
	defw sound_07
	defw sound_08
	defw sound_09
	defw sound_10
	defw sound_11
	defw sound_12
	defw sound_13
	defw sound_14
	defw sound_15
	defw sound_16
	defw sound_17
	defw sound_18
	defw sound_19
	defw sound_20
	defw sound_21
	defw sound_22
	defw sound_23
	defw sound_24
	defw sound_25
	defw sound_26
	defw sound_27
	defw sound_28
	defw sound_29
	defw sound_30
	defw sound_31
	defw sound_32
	defw sound_33
	defw sound_34
	defw sound_35
	defw sound_36
	defw sound_37
	defw sound_38
	defw sound_39
	defw sound_40
	defw sound_41
	defw sound_42
	defw sound_43
	defw sound_44
	defw sound_45
	defw sound_46
	defw sound_47
	defw sound_48
	defw sound_49
	defw sound_50
	defw sound_51
	defw sound_52
	defw sound_53
	defw sound_54
	defw sound_55
	defw sound_56
	defw sound_57
	defw sound_58
	defw sound_59
	defw sound_60
	defw sound_61
	defw sound_62
	defw sound_63
	defw sound_64
	defw sound_65
	defw sound_66
	defw sound_67
	defw sound_68
	defw sound_69
	defw sound_70
	defw sound_71
	defw sound_72
	defw sound_73
	defw sound_74
	defw sound_75
	defw sound_76
	defw empty_sound	; 77
	defw empty_sound	; 78
	defw empty_sound	; 79

	end
