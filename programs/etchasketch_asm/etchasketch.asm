; this program uses the attr cells to make a black and white display
; where a box is moved around with wasd
; it's sort of like an etchasketch

org 32768

	; set border to etch-a-sketch red
	ld a, 2
	call 8859

	call clear_screen

	ld d, 10
	ld e, 9
	call draw_square

main_loop:
	call is_r_down
	cp 1
	jp nz, no_clear
	call clear_screen

no_clear:

	call is_w_down
	ld c, a
	ld a, e
	sub c
	ld e, a

	call is_s_down
	add a, e
	ld e, a

	call is_a_down
	ld c, a
	ld a, d
	sub c
	ld d, a

	call is_d_down
	add a, d
	ld d, a

	call wait_dur

	call draw_square

	jp main_loop


wait_dur:
	ld c, 20
wait_dur_outer_loop:
	ld b, 255
wait_dur_inner_loop:
	set 1, a
	djnz wait_dur_inner_loop
	dec c
	jp nz, wait_dur_outer_loop
	ret

draw_square:
	call get_coord
	ld (hl), 0
	ret

clear_square:
	call get_coord
	ld (hl), 255
	ret

; d = x, e = y
get_coord:
	ld a, d
	and $1f
	ld l, a
	ld a, e
	and $07
	rrc a
	rrc a
	rrc a
	add a, l
	ld l, a
	ld a, e
	and $18
	srl a
	srl a
	srl a
	add a, $58
	ld h, a
	ret

is_w_down:
    ld bc, $fbfe
    in b, (c)
	bit 1, b
	jp z, set_a
	ld a, 0
	ret
is_r_down:
    ld bc, $fbfe
    in b, (c)
	bit 3, b
	jp z, set_a
	ld a, 0
	ret
is_a_down:
    ld bc, $fdfe
    in b, (c)
	bit 0, b
	jp z, set_a
	ld a, 0
	ret
is_s_down:
    ld bc, $fdfe
    in b, (c)
	bit 1, b
	jp z, set_a
	ld a, 0
	ret
is_d_down:
    ld bc, $fdfe
    in b, (c)
	bit 2, b
	jp z, set_a
	ld a, 0
	ret
set_a:
	ld a, 1
	ret

; unused
get_attr:
	xor a
	ld h, $54
	ld l, a
	ld a, d
	srl a
	srl a
	srl a
	ld l, a
	ld a, e
	and $f8
	sla a
	sla a
	add a, l
	ld l, a
	ld a, e
	srl a
	srl a
	srl a
	srl a
	srl a
	add a, h
	ld h, a
	ret

clear_screen:
	ld hl, $5800
	ld c, 5
clear_screen_outer_loop:
	ld b, 255
clear_screen_inner_loop:
	ld (hl), 255
	inc hl
	djnz clear_screen_inner_loop
	dec c
	jp nz, clear_screen_outer_loop
	ret

end:
