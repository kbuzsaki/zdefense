; this program uses the attr cells to make a black and white display
; where a box is moved around with wasd
; it's sort of like an etchasketch

org 32768

	; set border to etch-a-sketch red
	ld a, 2
	call 8859

	call clear_pixels
	call clear_attrs

	ld d, 128
	ld e, 96
	call draw_square

main_loop:
	call is_r_down
	cp 1
	jp nz, no_clear
	call clear_pixels

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

	; wrap e at 192
	bit 7, e
	jp z, no_wrap_e
	bit 6, e
	jp z, no_wrap_e
	bit 5, e
	jp z, wrap_to_top
wrap_to_bottom:
	ld e, 191
	jp no_wrap_e
wrap_to_top:
	ld e, 0
no_wrap_e:

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
	call get_pixel_addr
	call get_pixel_bit
	or (hl)
	ld (hl), a
	ret

clear_square:
	call get_attr_coord
	ld (hl), 255
	ret

; takes x and y coordinates of cell
; gets address of attribute byte for that cell
;
; read coordinates from d = x, e = y
; set address to hl
get_attr_coord:
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

; read coordinates from d = x, e = y
; set address to hl
get_pixel_addr:
	ld a, d
	and $f8
	srl a
	srl a
	srl a
	ld l, a
	ld a, e
	and $38
	sla a
	sla a
	or l
	ld l, a
	ld a, e
	and $7
	ld h, a
	ld a, e
	and $c0
	srl a
	srl a
	srl a
	add a, $40
	or h
	ld h, a
	ret

get_pixel_bit:
	ld a, d
	and $07
	jp z, get_pixel_bit_ret_one
	ld b, a
	ld a, $80
get_pixel_bit_loop:
	srl a
	djnz get_pixel_bit_loop
	ret
get_pixel_bit_ret_one:
	ld a, $80
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

clear_pixels:
	ld hl, $4000
	ld c, 24
clear_pixels_outer_loop:
	ld (hl), 0
	inc hl
	ld b, 255
clear_pixels_inner_loop:
	ld (hl), 0
	inc hl
	djnz clear_pixels_inner_loop
	dec c
	jp nz, clear_pixels_outer_loop
	ret


clear_attrs:
	ld hl, $5800
	ld c, 3
clear_attrs_outer_loop:
	ld (hl), $38
	inc hl
	ld b, 255
clear_attrs_inner_loop:
	ld (hl), $38
	inc hl
	djnz clear_attrs_inner_loop
	dec c
	jp nz, clear_attrs_outer_loop
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
