; Code based off randomflux forum 1-bit audio tutorial
; Song: Megalovania from Undertale
	org 32768
	di

init:
	ld hl, sequence
	push hl

read_sequence:
	pop hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	xor a
	or d
	or e
	ret z

	inc hl
	push hl
	push de

read_pattern:
	pop de
	ld a, (de)
	ld b, a
	cp $ff
	jr z, read_sequence

	ld c, b

	inc de
	ld a, (de)
	inc de
	push de
	ld d, a
	ld e, d

	ld hl, 5000
	call soundLoop
	jr read_pattern

soundLoop:
	xor a
	dec b
	jr nz, skip1
	ld a, $10
	ld b, c
skip1:
	out ($fe), a

	xor a
	dec d
	jr nz, skip2
	ld a, $10
	ld d, e
skip2:
	out ($fe), a

	dec hl
	ld a, h
	or l
	jr nz, soundLoop

	ei
	ret

sequence:
	dw pattern00
	dw pattern00
	dw pattern00
	dw $0000

pattern00:
	db $fe, $fe
	db $fe, $fe
	db $7f, $7f
	db $7f, $7f
	db $aa, $aa
	db $aa, $aa
	db $aa, $aa
	db $b4, $b4
	db $b4, $b4
	db $be, $be
	db $be, $be
	db $d6, $d6
	db $d6, $d6
	db $fe, $fe
	db $d6, $d6
	db $be, $be
	db $ff
