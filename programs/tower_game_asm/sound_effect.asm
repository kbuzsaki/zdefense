; Sound effect engine based on randomflux's 1-bit audio tutorial
sound_effect_entry:
	; disable interrupts for uninterrupted playing
	; and increment the correct number of frames
	di		; 4
	call increment_frame_counters	; 17 + 136 = 153
	call increment_frame_counters	; 17 + 136 = 153
	call increment_frame_counters	; 17 + 136 = 153

; frame management : 310 T

	; music requires special treatment
	; so set a flag to tell us if we're playing music
	push iy
	ld iy, sound_effect_chan_3_is_music

	; save the alternate registers
	exx		; 4
	push bc		; 11
	push de		; 11
	push hl		; 11
	exx		; 4

; hidden register saving : 41 T

	; load the flags into a
	; de: size of each sfx sequence
	; b: # of sound effects available
	; c: # of channels available
	; hl: address of sfx sequence
	ld a, (sound_effect_flags)	; 13
	ld de, 14
	ld b, 7
	ld c, 3
	ld hl, sound_effect_laser_sequence-14

; this setup requires that the sfx lay contiguous to
; each other in memory, separated by 14 bytes

; we loop across the flags, finding which ones are set
; the LSb has the highest priority, while the MSb has the
; lowest priority
; The layout of the flag byte is as follows:
;
; MSb                                                         LSb
; ___________________________________________________________________
;|      |       |           |      |            |     |      |       |
;| none | flame | enemy die | bomb | player dmg | zap | item | laser |
;|______|_______|___________|______|____________|_____|______|_______|
;
sound_effect_find_next_bit:
	; if there are still more sfx to check, keep going
	djnz sound_effect_inc_address
	; otherwise, check how many channels are left
	ld a, c
	; 1 channel left - use for music
	cp 1
	jp z, sound_effect_music_channel_3
	; 2 channels left - channel 2: blank, channel 3: music
	cp 2
	jp z, sound_effect_channel_2_empty
	; all channels left - channel 1+2: blank, channel 3: music
	jp sound_effect_channel_1_empty

sound_effect_inc_address:
	; increment the sound effect address
	add hl, de
	; rotate the next bit to see if we are playing this sfx
	rrca
	; if it's not set, go on to the next iteration
	jp nc, sound_effect_find_next_bit
	
	; if it is set, push the address onto the stack
	; decrement # of available channels
	push hl
	dec c
	; if we have no more channels left, go on to sound production
	jp z, sound_effect_retrieve_pointers
	; otherwise, look for more sfx
	jp sound_effect_find_next_bit

; load channel 1 with an empty sound
sound_effect_channel_1_empty:
	ld hl, sound_effect_empty_sequence
	push hl

; load channel 2 with an empty sound
sound_effect_channel_2_empty:
	ld hl, sound_effect_empty_sequence
	push hl

; if channel 3 is not filled, use it to play music
sound_effect_music_channel_3:
	; find the correct offset
	ld hl, sound_effect_music_sequence		; 10
	ld a, (sound_effect_music_sequence_index)
	ld e, a
	ld d, 0
	add hl, de
	; set the music playing flag
	ld (iy+0), 1
	; push the address onto the stack
	push hl

; sfx pointer loading total with all sfx: 90 (+ 20) + 13 = 103 (+ 20)

sound_effect_retrieve_pointers:
	; get the sfx sequence addresses from the stack
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
	; check if we have hit the end ($ffff sentinel)
	and e				; 4
	cp $ff				; 7
	jp z, sound_effect_exit		; 10
	; increment and save to stack
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
	; music requires special treatment
	; we stay on the same note the whole period
	; so we do not increment the music pointer
	; check the music playing flag in (iy)
	xor a
	add a, (iy+0)
	; if this is not music, increment the pointer
	jp z, sound_effect_dont_dec_not_music
	; if this is music, decrement twice to
	; essentially cancel out the two increments
	dec hl
	dec hl
sound_effect_dont_dec_not_music:
	inc hl				; 6
	push hl				; 11

	; reg initialization : 56 T
	; initialize the note counters
	; and note duration
	ld ix, $0			; 14
	ld hl, $0			; 14

	exx				; 4
	ld hl, $0			; 10
	ld de, 300			; 10
	exx				; 4

; note duration loading total: 66 + 53 + 45 + 56 = 220 T

sound_effect_sound_loop:
	; add to note counters and check if carry
	; output high signal if carry
	add ix, de			; 15
	sbc a, a			; 4
	and $10				; 7
	inc a
	out ($fe), a			; 11

	exx				; 4
	add hl, bc			; 11
	sbc a, a			; 4
	and $10				; 7
	inc a
	out ($fe), a			; 11
	exx				; 4

	add hl, bc			; 15
	sbc a, a			; 4
	and $10				; 7
	inc a
	out ($fe), a			; 11

sound_effect_duration_dec:
	; decrement the duration counter
	; and branch out if it hits 0
	exx				; 4
	dec de				; 6
	ld a, d				; 4
	or e				; 4
	exx				; 4
	jp nz, sound_effect_sound_loop		; 10

; sound loop iteration: 147 T
; max total cycle ct with length ix: 300 * 147 = 44100

	; go back to note setup
	; and get the pointers to the next note
	jp sound_effect_retrieve_pointers		; 10

; per note iteration: 38 + 220 + 44100 + 10 = 44368 T

sound_effect_exit:
	; clear sfx flags and music playing flag
	xor a				; 4
	ld (sound_effect_flags), a	; 13
	ld (sound_effect_chan_3_is_music), a

	; restore alternate registers
	exx				; 4
	pop hl				; 10
	pop de				; 10
	pop bc				; 10
	exx				; 4

	; increment music index
	ld a, (sound_effect_music_sequence_index)
	add a, 2
	ld (sound_effect_music_sequence_index), a

	; restore iy register
	; (used for status screen updating)
	pop iy

	; exit sfx routine
	ret				; 10

; exit sequence: 65 T

; total ct with 3 notes: 310 + 41 + 123 + 3 * 44100 + 65 = 132839

; copied from above
; The layout of the flag byte is as follows:
;
; MSb                                                         LSb
; ___________________________________________________________________
;|      |       |           |      |            |     |      |       |
;| none | flame | enemy die | bomb | player dmg | zap | item | laser |
;|______|_______|___________|______|____________|_____|______|_______|
;
sound_effect_flags:
	defb 0

; index of the music note
sound_effect_music_sequence_index:
	defb 0

; 1: channel 3 is playing music
; 0: channel 3 is playing sfx
sound_effect_chan_3_is_music:
	defb 0


; sound effect and music sequences below
;sound_effect_music_sequence_3:
;	dw 3676
;	dw 0
;	dw 2453
;	dw 0
;	dw 2754
;	dw 0
;	dw 3275
;	dw 0
;	dw 4906
;	dw 0
;	dw 4126
;	dw 0
;	dw 3676
;	dw 0
;	dw 2453
;	dw 0
;	dw 2754
;	dw 0
;	dw 3275
;	dw 0
;	dw 4906
;	dw 0
;	dw 4126
;	dw 0
;	dw 3275
;	dw 0
;	dw 3676
;	dw 0
;	dw 4126
;	dw 0
;	dw 4368
;	dw 0
;	dw 3676
;	dw 0
;	dw 2453
;	dw 0
;	dw 2754
;	dw 0
;	dw 3275
;	dw 0
;	dw 4906
;	dw 0
;	dw 4126
;	dw 0
;	dw 3676
;	dw 0
;	dw 2453
;	dw 0
;	dw 2754
;	dw 0
;	dw 3275
;	dw 0
;	dw 4906
;	dw 0
;	dw 4126
;	dw 0
;	dw 3275
;	dw 0
;	dw 3676
;	dw 0
;	dw 4126
;	dw 0
;	dw 4368
;	dw 0

sound_effect_music_sequence:
	dw 2180
	dw 1838
	dw 2180
	dw 1838
	dw 2453
	dw 1838
	dw 2453
	dw 1838
	dw 2180
	dw 1838
	dw 2180
	dw 1838
	dw 2453
	dw 1838
	dw 2453
	dw 1838
	dw 2063
	dw 2063
	dw 0
	dw 0
	dw 2063
	dw 2063
	dw 0
	dw 0
	dw 2063
	dw 2063
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
	dw 1838
	dw 2063
	dw 2180
	dw 2760
	dw 1838
	dw 2063
	dw 2180
	dw 2760
	dw 1838
	dw 2063
	dw 2180
	dw 2760
	dw 1838
	dw 2063
	dw 2180
	dw 2760
	dw 2063
	dw 2180
	dw 2453
	dw 2760
	dw 2063
	dw 2180
	dw 2453
	dw 2760
	dw 2063
	dw 2180
	dw 2453
	dw 2760
	dw 2063
	dw 2180
	dw 2453
	dw 2760
	dw 1838
	dw 1838
	dw 0
	dw 0
	dw 2760
	dw 0
	dw 0
	dw 2180
	dw 2920
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
	dw 2453
	dw 0
	dw 0
	dw 0
	dw 2453
	dw 0
	dw 0
	dw 2180
	dw 2063
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
	dw 1838
	dw 0
	dw 0
	dw 0
	dw 2760
	dw 0
	dw 0
	dw 2180
	dw 2920
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
	dw 2453
	dw 0
	dw 0
	dw 0
	dw 2453
	dw 0
	dw 0
	dw 2180
	dw 2063
	dw 3470
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
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
	dw 587
	dw 1000
	dw 384
	dw 384
	dw 999
	dw 1000
	dw $ffff

sound_effect_empty_sequence:
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
	dw 0
	dw $ffff
