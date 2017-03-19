sound_effect_entry:
	di		; 4
	call increment_frame_counters	; 17 + 136 = 153
	call increment_frame_counters	; 17 + 136 = 153

; frame management : 310 T

	exx		; 4
	push bc		; 11
	push de		; 11
	push hl		; 11
	exx		; 4

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
	exx
	rrca				; 4
	jp nc, empty_bomb		; 10
	ld de, bomb_sequence		; 10
	jp slow_sfx			; 10 (optional)

empty_bomb:
	ld de, empty_sequence		; 10

slow_sfx:
	exx
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
	exx
	pop de				; 10
	exx
	pop bc				; 10

; pointer popping : 30 T

play_sfx:
	; load channel 1 base freq into de
	ld a, (bc)			; 13
	ld e, a
	inc bc
	ld a, (bc)
	ld d, a
	and e				; 4
	cp $ff
	jp z, sound_effect_exit		; 10
	inc bc				; 4
	push bc				; 11
	; load channel 2 base freq into bc'
	exx
	ld a, (de)			; 13
	ld c, a
	inc de
	ld a, (de)
	inc de				; 4
	push de				; 11
	ld b, a
	exx
	; load channel 3 base freq into bc
	ld a, (hl)			; 13
	ld c, a
	inc hl
	ld a, (hl)
	inc hl
	push hl				; 11
	ld b, a				; 4

	ld ix, $0
	ld iy, $0
	;ld b, c				; 4
	;ld d, e				; 4
	;ld h, l				; 4

	exx
	ld hl, $0
	ld de, 300			; 14
	exx

; note duration loading total: 136 T

sound_loop:
;	xor a				; 4
;	dec b				; 4
;	jp nz, skip1			; 10
;	ld a, $10			; 7
;	ld b, c				; 4
;skip1:
;	out ($fe), a			; 11
	add ix, de
	sbc a, a
	and $10
	out ($fe), a

;channel_2:
;	xor a				; 4
;	dec d				; 4
;	jp nz, skip2			; 10
;	ld a, $10			; 7
;	ld d, e				; 4
;skip2:
;	out ($fe), a			; 11
	exx
	add hl, bc
	sbc a, a
	and $10
	out ($fe), a
	exx

;channel_3:
;	xor a				; 4
;	dec h				; 4
;	jp nz, skip3			; 10
;	ld a, $10			; 7
;	ld h, l				; 4
;skip3:
;	out ($fe), a			; 11
	add iy, bc
	sbc a, a
	and $10
	out ($fe), a

duration_dec:
	exx
	dec de				; 10
	ld a, d
	or e				; 8
	exx
	jp nz, sound_loop		; 10

; sound loop iteration: 102 T
; max total cycle ct with length ix: 300 * 160 = 28500

	jp retrieve_pointers		; 10

; per note iteration: 30 + 136 + 28500 + 10 = 28676 T

sound_effect_exit:
	xor a				; 4
	ld (sound_effect_flags), a	; 13
	exx
	pop hl
	pop de
	pop bc
	exx
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
	dw 800
	dw 800
	dw 800
	dw $ffff
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
	dw $1
	dw $1
	dw $1
	dw $ffff
	defb 1
	defb 1
	defb 1
	defb 255
