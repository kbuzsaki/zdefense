sound_effect_entry:
	di		; 4
	call increment_frame_counters	; 17 + 136 = 153
	call increment_frame_counters	; 17 + 136 = 153
	call increment_frame_counters	; 17 + 136 = 153

; frame management : 310 T

	push iy
	ld iy, chan_3_is_music
	exx		; 4
	push bc		; 11
	push de		; 11
	push hl		; 11
	exx		; 4

; hidden register saving : 41 T

	ld a, (sound_effect_flags)	; 13
	ld de, 14
	ld b, 7
	ld c, 3
	ld hl, laser_sequence-14

sound_effect_find_next_bit:
	djnz sound_effect_inc_address
	ld a, c
	cp 1
	jp z, sound_effect_music_channel_3
	cp 2
	jp z, sound_effect_channel_2_empty
	jp sound_effect_channel_1_empty
sound_effect_inc_address:
	add hl, de
	rrca
	jp nc, sound_effect_find_next_bit
	
	push hl
	dec c
	jp z, sound_effect_retrieve_pointers
	jp sound_effect_find_next_bit

sound_effect_channel_1_empty:
	ld hl, sound_effect_empty_sequence
	push hl

sound_effect_channel_2_empty:
	ld hl, sound_effect_empty_sequence
	push hl

sound_effect_music_channel_3:
	ld hl, sound_effect_music_sequence		; 10
	ld a, (sound_effect_music_sequence_index)
	ld e, a
	ld d, 0
	add hl, de
	ld (iy+0), 1
	push hl

; sfx pointer loading total with all sfx: 90 (+ 20) + 13 = 103 (+ 20)

sound_effect_retrieve_pointers:
	pop hl				; 10
	exx				; 4
	pop de				; 10
	exx				; 4
	pop bc				; 10

; pointer popping : 38 T

sound_effect_play_sfx:
	; load channel 1 base freq into de : 66 T
	ld a, (bc)			; 7
	ld e, a				; 4
	inc bc				; 6
	ld a, (bc)			; 7
	ld d, a				; 4
	and e				; 4
	cp $ff				; 7
	jp z, sound_effect_exit		; 10
	inc bc				; 6
	push bc				; 11
	; load channel 2 base freq into bc' : 53 T
	exx				; 4
	ld a, (de)			; 7
	ld c, a				; 4
	inc de				; 6
	ld a, (de)			; 7
	inc de				; 6
	push de				; 11
	ld b, a				; 4
	exx				; 4
	; load channel 3 base freq into bc : 45 T
	ld a, (hl)			; 7
	ld c, a				; 4
	inc hl				; 6
	ld a, (hl)			; 7
	ld b, a				; 4
	xor a
	add a, (iy+0)
	jp z, sound_effect_dont_dec_not_music
	dec hl
	dec hl
sound_effect_dont_dec_not_music:
	inc hl				; 6
	push hl				; 11

	; reg initialization : 56 T
	ld ix, $0			; 14
	ld hl, $0			; 14

	exx				; 4
	ld hl, $0			; 10
	ld de, 300			; 10
	exx				; 4

; note duration loading total: 66 + 53 + 45 + 56 = 220 T

sound_effect_sound_loop:
	add ix, de			; 15
	sbc a, a			; 4
	and $10				; 7
	out ($fe), a			; 11

	exx				; 4
	add hl, bc			; 11
	sbc a, a			; 4
	and $10				; 7
	out ($fe), a			; 11
	exx				; 4

	add hl, bc			; 15
	sbc a, a			; 4
	and $10				; 7
	out ($fe), a			; 11

sound_effect_duration_dec:
	exx				; 4
	dec de				; 6
	ld a, d				; 4
	or e				; 4
	exx				; 4
	jp nz, sound_effect_sound_loop		; 10

; sound loop iteration: 147 T
; max total cycle ct with length ix: 300 * 147 = 44100

	jp sound_effect_retrieve_pointers		; 10

; per note iteration: 38 + 220 + 44100 + 10 = 44368 T

sound_effect_exit:
	xor a				; 4
	ld (sound_effect_flags), a	; 13
	ld (sound_effect_chan_3_is_music), a
	exx				; 4
	pop hl				; 10
	pop de				; 10
	pop bc				; 10
	exx				; 4
	ld a, (sound_effect_music_sequence_index)
	add a, 2
	and 15
	ld (sound_effect_music_sequence_index), a
	pop iy
	ret				; 10

; exit sequence: 65 T

; total ct with 3 notes: 310 + 41 + 123 + 3 * 44100 + 65 = 132839

sound_effect_flags:
	defb 0

sound_effect_music_sequence_index:
	defb 0

sound_effect_chan_3_is_music:
	defb 0

sound_effect_music_sequence:
	dw 1
	dw 1
	dw 1
	dw 1
	dw 1
	dw 1
	dw 1
	dw 1
	dw 1
	dw 1
	dw 1
	dw 1
	dw 1
	dw 1
	dw 1
	dw 1

sound_effect_music_sequence_1:
	dw 3275
	dw 0
	dw 2453
	dw 0
	dw 2599
	dw 0
	dw 1838
	dw 0
	dw 2453
	dw 0
	dw 1638
	dw 0
	dw 1838
	dw 0
	dw 2599
	dw 0
	dw 2186
	dw 0
	dw 2453
	dw 0
	dw 2754
	dw 0
	dw 3091
	dw 0

sound_effect_laser_sequence:
	dw 1000
	dw 3000
	dw 5000
	dw 7000
	dw 8000
	dw 10000
	dw $ffff

sound_effect_item_sequence:
	dw 3676
	dw 3676
	dw 3676
	dw 3676
	dw 0
	dw 0
	dw $ffff

sound_effect_zap_sequence:
	dw 423
	dw 423
	dw 423
	dw 423
	dw 423
	dw 423
	dw $ffff

sound_effect_player_dmg_sequence:
	dw 10000
	dw 10000
	dw 5000
	dw 5000
	dw 8000
	dw 8000
	dw $ffff

sound_effect_bomb_sequence:
	dw 300
	dw 300
	dw 350
	dw 370
	dw 383
	dw 300
	dw $ffff

sound_effect_enemy_death_sequence:
	dw 8800
	dw 8800
	dw 5050
	dw 1200
	dw 1
	dw 1
	dw $ffff

sound_effect_flame_sequence:
	dw 1
	dw 1
	dw 1
	dw 1
	dw 1
	dw 1
	dw $ffff

sound_effect_empty_sequence:
	dw $1
	dw $1
	dw $1
	dw $1
	dw $1
	dw $1
	dw $ffff
