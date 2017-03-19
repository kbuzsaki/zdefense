sound_effect_entry:
	di		; 4
	call increment_frame_counters	; 17 + 136 = 153
	call increment_frame_counters	; 17 + 136 = 153

; frame management : 310 T

;	ld c, 13	; 7
;loop_lol:
;	ld b, 255	; 7
;lol_loop:
;	nop	; 4 * 8 = 32 cycles
;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
;	nop
;	djnz lol_loop	; 254 * (32 + 13) + (32 + 8) = 11470 T
;
;	dec c 		; 4
;	jr nz, loop_lol	; 12 * (11481 + 12) + (11481 + 7) = 149404 T
;
;	ei		; 4
;	ret		; 10
;
;sound_effect_entry_1:

	ld a, (sound_effect_flags)	; 13

laser_sfx:
	rrca				; 4
	jp nc, empty_laser		; 10
	ld bc, laser_sequence		; 10
	jp bomb_sfx			; 10 (optional)

empty_laser:
	ld bc, empty_sequence		; 10

bomb_sfx:
	rrca				; 4
	jp nc, empty_bomb		; 10
	ld de, bomb_sequence		; 10
	jp slow_sfx			; 10 (optional)

empty_bomb:
	ld de, empty_sequence		; 10

slow_sfx:
	rrca				; 4
	jp nc, empty_slow		; 10
	ld hl, slow_sequence		; 10
	jp play_sfx			; 10

empty_slow:
	ld hl, empty_sequence		; 10
	jp play_sfx			; 10

; sfx pointer loading total with all sfx: 82 (+ 20) + 13

retrieve_pointers:
	pop hl				; 10
	pop de				; 10
	pop bc				; 10

; pointer popping : 30 T

play_sfx:
	ld a, (bc)			; 13
	cp $ff				; 4
	jp z, sound_effect_exit		; 10
	inc bc				; 4
	push bc				; 11
	ld c, a				; 4
	ld a, (de)			; 13
	inc de				; 4
	push de				; 11
	ld e, a				; 4
	ld a, (hl)			; 13
	inc hl				; 4
	push hl				; 11
	ld l, a				; 4

	ld b, c				; 4
	ld d, e				; 4
	ld h, l				; 4

	ld ix, 300			; 14

; note duration loading total: 136 T

sound_loop:
	xor a				; 4
	dec b				; 4
	jp nz, skip1			; 10
	ld a, $10			; 7
	ld b, c				; 4
skip1:
	out ($fe), a			; 11

channel_2:
	xor a				; 4
	dec d				; 4
	jp nz, skip2			; 10
	ld a, $10			; 7
	ld d, e				; 4
skip2:
	out ($fe), a			; 11

channel_3:
	xor a				; 4
	dec h				; 4
	jp nz, skip3			; 10
	ld a, $10			; 7
	ld h, l				; 4
skip3:
	out ($fe), a			; 11

duration_dec:
	dec ix				; 10
	xor a				; 4
	or ixh				; 8
	or ixl				; 8
	jp nz, sound_loop		; 10

; sound loop iteration: 190 T
; max total cycle ct with length ix: 300 * 160 = 28500

	jp retrieve_pointers		; 10

; per note iteration: 30 + 136 + 28500 + 10 = 28676 T

sound_effect_exit:
	xor a				; 4
	ld (sound_effect_flags), a	; 13
	ret				; 10

; exit sequence: 27 T

; total ct with 6 notes: 310 + 115 + 6 * 28676 + 27 = 172508

sound_effect_flags:
	defb 0

; b c d e b' c' d' e' h' l' ixh ixl iyh iyl
; hl - timer
; d e ixl iyl - b c ixh iyh
; d' e' h' - b' c' l'

laser_sequence:
	defb 50
	defb 50
	defb 50
	defb 255
	defb 101
	defb 101
	defb 101
	defb 101
	defb 101
	defb 255

bomb_sequence:
	defb 200
	defb 250
	defb 220
	defb 230
	defb 245
	defb 190
	defb 1
	defb 255

slow_sequence:
	defb 90

empty_sequence:
	defb 1
	defb 1
	defb 1
	defb 255
	defb 1
	defb 1
	defb 1
	defb 255
