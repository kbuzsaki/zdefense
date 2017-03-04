; code based off randomflux 1-bit audio tutorial
; song: bergentruckung - undertale
	org 32768
	di

; get sequence address into hl
init:
	ld hl, sequence
	push hl

; get pattern address from sequence
read_sequence:
	pop hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld a, d
	or e
	jr nz, next_step
	ei
	ret

next_step:
	inc hl
	push hl
	push de

; get first channel frequency
read_pattern:
	pop de
	ld a, (de)
	ld c, a
	inc de
	ld a, (de)
	ld b, a
	inc de
	ld a, c
	and b
	; end sentinel is $ffff
	cp $ff
	jr z, read_sequence

; get second channel frequency
second_channel:
	ld a, (de)
	ld l, a
	inc de
	ld a, (de)
	ld h, a
	inc de
	push de
	ex de, hl

	; load note duration and counters
	ld hl, 2350
	ld ix, 0
	ld iy, 0
	call soundLoop
	jr read_pattern

soundLoop:
	add ix, bc	; add frequency to counter per iteration
	sbc a, a	; if carry, output 1 to beeper
	and $10		; else, 0 to beeper
	out ($fe), a

	add iy, de	; same for second channel
	sbc a, a
	and $10
	out ($fe), a

	dec hl		; decrement note duration counter
	ld a, h
	or l
	jr nz, soundLoop

	ret

; note sequences
sequence:
	defw pattern00
	defw pattern01
	defw pattern02
	defw pattern03
	defw pattern00
	defw pattern04
	defw pattern05
	defw pattern06
	defw $0000

pattern00:
	defw $0278, $018e
	defw $0278, $018e
	defw $0000, $0000
	defw $0000, $0000
	defw $0000, $018e
	defw $0000, $018e
	defw $0000, $0000
	defw $0000, $0000
	defw $031e, $01da
	defw $031e, $01da
	defw $0000, $0000
	defw $0000, $0000
	defw $0000, $01da
	defw $0000, $01da
	defw $0000, $0000
	defw $0000, $0000
	defw $02c6, $0214
	defw $02c6, $0214
	defw $02c6, $0214
	defw $02c6, $0214
	defw $02c6, $0214
	defw $02c6, $0214
	defw $02c6, $0214
	defw $02c6, $0214
	defw $02c6, $0214
	defw $02c6, $0214
	defw $02c6, $0214
	defw $02c6, $0214
	defw $02c6, $0214
	defw $02c6, $0214
	defw $02c6, $0214
	defw $0000, $0000
	defw $ffff

pattern01:
	defw $0254, $0164
	defw $0254, $0164
	defw $0000, $0000
	defw $0000, $0000
	defw $0000, $0164
	defw $0000, $0164
	defw $0000, $0000
	defw $0000, $0000
	defw $02c6, $01da
	defw $02c6, $01da
	defw $0000, $0000
	defw $0000, $0000
	defw $0000, $01da
	defw $0000, $01da
	defw $0000, $0000
	defw $0000, $0000
	defw $0278, $018e
	defw $0278, $018e
	defw $0278, $018e
	defw $0278, $018e
	defw $0278, $018e
	defw $0278, $018e
	defw $0278, $018e
	defw $0278, $018e
	defw $0278, $018e
	defw $0278, $018e
	defw $0278, $018e
	defw $0278, $018e
	defw $0278, $018e
	defw $0278, $018e
	defw $0278, $018e
	defw $0000, $0000
	defw $ffff

pattern02:
	defw $0214, $0164
	defw $0214, $0164
	defw $0000, $0000
	defw $0000, $0000
	defw $0000, $0164
	defw $0000, $0164
	defw $0000, $0000
	defw $0000, $0000
	defw $0278, $01da
	defw $0278, $01da
	defw $0000, $0000
	defw $0000, $0000
	defw $0000, $01da
	defw $0000, $01da
	defw $0000, $0000
	defw $0000, $0000
	defw $0254, $01da
	defw $0254, $01da
	defw $0254, $0000
	defw $0254, $0000
	defw $0254, $01a6
	defw $0254, $01a6
	defw $0254, $0000
	defw $0254, $0000
	defw $0254, $0164
	defw $0254, $0164
	defw $0254, $0000
	defw $0254, $0000
	defw $0254, $018e
	defw $0254, $018e
	defw $0254, $0000
	defw $0000, $0000
	defw $ffff

pattern03:
	defw $01da, $0164
	defw $01da, $0164
	defw $0000, $0000
	defw $0000, $0000
	defw $0000, $013c
	defw $0000, $013c
	defw $0000, $0000
	defw $0000, $0000
	defw $0214, $0164
	defw $0214, $0164
	defw $0000, $0000
	defw $0000, $0000
	defw $0000, $018e
	defw $0000, $018e
	defw $0000, $0000
	defw $0000, $0000
	defw $018e, $010a
	defw $018e, $010a
	defw $018e, $010a
	defw $018e, $010a
	defw $018e, $010a
	defw $018e, $010a
	defw $018e, $010a
	defw $018e, $010a
	defw $018e, $010a
	defw $018e, $010a
	defw $018e, $010a
	defw $018e, $010a
	defw $018e, $010a
	defw $018e, $010a
	defw $018e, $010a
	defw $0000, $0000
	defw $ffff

pattern04:
	defw $03b4, $0256
	defw $03b4, $0256
	defw $0000, $0000
	defw $0000, $0000
	defw $0000, $0256
	defw $0000, $0256
	defw $0000, $0000
	defw $0000, $0000
	defw $02c6, $01da
	defw $02c6, $01da
	defw $0000, $0000
	defw $0000, $0000
	defw $0000, $01da
	defw $0000, $01da
	defw $0000, $0000
	defw $0000, $0000
	defw $031e, $0256
	defw $031e, $0256
	defw $031e, $0256
	defw $031e, $0256
	defw $031e, $0256
	defw $031e, $0256
	defw $031e, $0256
	defw $031e, $0256
	defw $031e, $0278
	defw $031e, $0278
	defw $031e, $0278
	defw $031e, $0278
	defw $031e, $0278
	defw $031e, $0278
	defw $031e, $0278
	defw $0000, $0000
	defw $ffff

pattern05:
	defw $031e, $0256
	defw $031e, $0256
	defw $0000, $0000
	defw $0000, $0000
	defw $02c6, $0214
	defw $02c6, $0214
	defw $0000, $0000
	defw $0000, $0000
	defw $031e, $01da
	defw $031e, $01da
	defw $0000, $0000
	defw $0000, $0000
	defw $03b4, $0256
	defw $03b4, $0256
	defw $0000, $0000
	defw $0000, $0000
	defw $0429, $0256
	defw $0429, $0256
	defw $0429, $0256
	defw $0429, $0256
	defw $0429, $0256
	defw $0429, $0256
	defw $0429, $0256
	defw $0429, $0256
	defw $04f2, $0214
	defw $04f2, $0214
	defw $0000, $0214
	defw $0000, $0214
	defw $04f2, $0214
	defw $04f2, $0214
	defw $0000, $0214
	defw $0000, $0000
	defw $ffff

pattern06:
	defw $04ab, $01da
	defw $04ab, $01da
	defw $04ab, $0000
	defw $04ab, $0000
	defw $04ab, $013c
	defw $04f2, $013c
	defw $04ab, $0000
	defw $0429, $0000
	defw $03b4, $0163
	defw $03b4, $0163
	defw $0000, $0000
	defw $0000, $0000
	defw $04ab, $01da
	defw $04ab, $01da
	defw $0000, $0000
	defw $0000, $0000
	defw $0429, $018e
	defw $0429, $018e
	defw $0429, $018e
	defw $0429, $018e
	defw $0429, $018e
	defw $0429, $018e
	defw $0429, $018e
	defw $0429, $018e
	defw $0429, $018e
	defw $0429, $018e
	defw $0429, $018e
	defw $0429, $018e
	defw $0429, $018e
	defw $0429, $018e
	defw $0429, $018e
	defw $0000, $0000
	defw $ffff
