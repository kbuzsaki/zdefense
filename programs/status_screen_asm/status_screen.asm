	org 32768

; set border color
; set attrs and reset screen
scr_setup:
	ld a, 4
	call 8859

	ld hl, $5c8d
	ld (hl), $38
	call $0d6b

; display left end
set_left_bord:
	ld hl, left_end
	ld de, $5000
	
	call draw_tile

; display right end
set_right_bord:
	ld hl, right_end
	ld de, $501f

	call draw_tile

; display middle
set_bord:
	ld b, 30
	ld c, 8
	ld hl, top_down
	ld de, $5001

set_bord_loop:
	call draw_tile
	ld hl, top_down
	ld a, d
	sub 8
	ld d, a
	inc e
	ld c, 8

	djnz set_bord_loop

prnt_msg:
	ld hl, $5c89
	ld (hl), 17

	ld a, $30
	call $09f4

	ret


draw_tile:
	ldi
	inc d
	dec de
	ldi
	inc d
	dec de
	ldi
	inc d
	dec de
	ldi
	inc d
	dec de
	ldi
	inc d
	dec de
	ldi
	inc d
	dec de
	ldi
	inc d
	dec de
	ldi
	inc d
	dec de
	ret

left_end:
	defb $66, $99, $90, $80, $40, $90, $99, $66

top_down:
	defb $00, $00, $db, $2c, $2c, $db, $00, $00

right_end:
	defb $66, $99, $09, $01, $02, $09, $99, $66
