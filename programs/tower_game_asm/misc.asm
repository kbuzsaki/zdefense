
draw_tower:
	push de
	call get_cell_addr
	ex de, hl
	ld a, 1
	call lookup_and_old_draw_tile
	pop de
	ret

do_thing:
	push de
	ex de, hl
	call set_no_flash
	pop de
	ret

set_flash:
    call get_coord
	ld a, $c0
	or (hl)
	ld (hl), a
    ret

set_no_flash:
    call get_coord
	ld a, $3f
	and (hl)
	ld (hl), a
    ret

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

draw_square:
	call get_coord
	ld (hl), 0
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
get_cell_addr:
	ld a, e
	sla a
	sla a
	sla a
	ld e, a
	ld a, d
	sla a
	sla a
	sla a
	ld d, a
	call get_pixel_addr
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

