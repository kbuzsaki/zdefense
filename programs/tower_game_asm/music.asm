music_entry_point:
	di					; 4
	push ix
	push iy
	call increment_frame_counters		; 17 + 138 = 153
	;call increment_frame_counters		; 17 + 138 = 153
	;call increment_frame_counters		; 17 + 138 = 153

; frame management: 463 T

music_init:
	ld hl, music_sequence			; 10
	ld a, (music_sequence_index)		; 13
	rlca					; 4
	ld e, a					; 4
	ld d, 0					; 7
	add hl, de				; 11

; music init: 49 T

music_read_sequence:
	ld e, (hl)				; 7
	inc hl					; 6
	ld d, (hl)				; 7
	ld a, (music_note_index)		; 13
	rlca					; 4
	rlca					; 4
	ex de, hl				; 4
	ld e, a					; 4
	ld d, 0					; 7
	add hl, de				; 11
	ex de, hl

; read sequence: 67 T

music_read_pattern:
	ld a, (de)				; 7
	ld c, a					; 4
	inc de					; 6
	ld a, (de)				; 7
	ld b, a					; 4
	inc de					; 6

; read pattern channel 1: 34 T

music_second_channel:
	ld a, (de)				; 7
	ld l, a					; 4
	inc de					; 6
	ld a, (de)				; 7
	ld h, a					; 4
	ex de, hl				; 4

	ld a, (music_note_index)		; 13
	inc a					; 4
	cp 16					; 7
	jr nz, music_skip_carry			; 12 usually
	xor a					; 4 (optional)
	ld (music_note_index), a		; 13
	ld a, (music_sequence_index)		; 13 (optional)
	inc a					; 4
	and 15					; 7 (optional)
	ld (music_sequence_index), a		; 13 (optional)
	jr music_set_up_note			; 12 (optional)

music_skip_carry:
	ld (music_note_index), a		; 13

; read pattern channel 2: 81 T usually

music_set_up_note:
	ld hl, 1700				; 10
	ld ix, 0				; 14
	ld iy, 0				; 14

; note setup: 38 T

music_sound_loop:
	add ix, bc				; 15
	sbc a, a				; 4
	and $10					; 7
	inc a					; 4
	out ($fe), a				; 11

	add iy, de				; 15
	sbc a, a				; 4
	and $10					; 7
	inc a					; 4
	out ($fe), a				; 11

	dec hl					; 6
	ld a, h					; 4
	or l					; 4
	jr nz, music_sound_loop			; (12 * 1999) + 7

	pop iy
	pop ix
	ret					; 10

; sound loop per iteration: 108 T
; total per note: (108 * 1999) + (113) = 216005 T

music_sequence_index:
	defb 0

music_note_index:
	defb 0

music_sequence:
	dw music_pattern00
	dw music_pattern01
	dw music_pattern00
	dw music_pattern01
	dw music_pattern00
	dw music_pattern02
	dw music_pattern03
	dw music_pattern04

	dw music_pattern05
	dw music_pattern06
	dw music_pattern03
	dw music_pattern04
	dw music_pattern03
	dw music_pattern07
	dw music_pattern08
	dw music_pattern09

music_pattern00:
	dw 771, 0
	dw 0, 0
	dw 917, 0
	dw 0, 0
	dw 1029, 0
	dw 0, 0
	dw 771, 0
	dw 0, 0
	dw 917, 0
	dw 0, 0
	dw 1029, 0
	dw 1090, 0
	dw 0, 0
	dw 1155, 0
	dw 1455, 0
	dw 0, 0

music_pattern01:
	dw 771, 0
	dw 0, 0
	dw 917, 0
	dw 0, 0
	dw 1029, 0
	dw 0, 0
	dw 771, 0
	dw 0, 0
	dw 917, 0
	dw 0, 0
	dw 1029, 0
	dw 1090, 0
	dw 0, 0
	dw 1374, 0
	dw 1731, 0
	dw 0, 0

music_pattern02:
	dw 771, 0
	dw 0, 0
	dw 917, 0
	dw 0, 0
	dw 728, 0
	dw 0, 0
	dw 865, 0
	dw 0, 0
	dw 687, 0
	dw 0, 0
	dw 817, 0
	dw 0, 0
	dw 578, 0
	dw 0, 0
	dw 728, 0
	dw 0, 0

music_pattern03:
	dw 771, 386
	dw 0, 386
	dw 917, 344
	dw 0, 0
	dw 1029, 325
	dw 0, 0
	dw 771, 325
	dw 0, 0
	dw 917, 289
	dw 0, 0
	dw 1029, 243
	dw 1090, 0
	dw 0, 193
	dw 1155, 0
	dw 1455, 162
	dw 0, 0

music_pattern04:
	dw 917, 289
	dw 0, 0
	dw 1029, 243
	dw 1090, 0
	dw 0, 193
	dw 1155, 0
	dw 1455, 162
	dw 0, 0
	dw 917, 289
	dw 0, 0
	dw 1029, 243
	dw 1090, 0
	dw 0, 193
	dw 1155, 0
	dw 1455, 162
	dw 0, 0

music_pattern05:
	dw 771, 386
	dw 0, 386
	dw 917, 344
	dw 0, 0
	dw 1029, 325
	dw 0, 0
	dw 771, 325
	dw 0, 0
	dw 917, 289
	dw 0, 0
	dw 1029, 386
	dw 1090, 0
	dw 0, 364
	dw 1374, 0
	dw 1731, 289
	dw 0, 0

music_pattern06:
	dw 917, 289
	dw 0, 0
	dw 1029, 386
	dw 1090, 0
	dw 0, 364
	dw 1374, 0
	dw 1731, 289
	dw 0, 0
	dw 917, 289
	dw 0, 0
	dw 1029, 386
	dw 1090, 0
	dw 0, 364
	dw 1374, 0
	dw 1731, 289
	dw 0, 0

music_pattern07:
	dw 771, 258
	dw 0, 258
	dw 917, 230
	dw 0, 0
	dw 1029, 258
	dw 0, 0
	dw 1224, 243
	dw 0, 0
	dw 1155, 258
	dw 1224, 0
	dw 0, 289
	dw 1155, 0
	dw 1455, 364
	dw 0, 0
	dw 0, 258
	dw 0, 0

music_pattern08:
	dw 1542, 386
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0

music_pattern09:
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
	dw 0, 0
