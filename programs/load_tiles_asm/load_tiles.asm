; this program uses the attr cells to make a black and white display
; where a box is moved around with wasd
; it's sort of like an etchasketch

org 32768

	; set border to green
	ld a, 4
	call 8859

	call clear_pixels
	call clear_attrs

;	ld d, 4
;	ld e, 4
;
;	ld d, $40
;	ld e, $63
;	ld hl, some_tile
;	call draw_tile
;
;	ld d, $40
;	ld e, $64
;	ld hl, some_tile
;	call draw_tile
;
;	ld d, $40
;	ld e, $65
;	ld hl, some_tile
;	call draw_tile
;
;	ld d, $40
;	ld e, $67
;	ld hl, cross_tile
;	call draw_tile
;
;	ld d, $40
;	ld e, $69
;	ld hl, circle_tile
;	call draw_tile


	ld d, $ff
	call fill_all_pixels


	; draw upper half of map
	ld hl, tile_map
	ld d, $40
	ld e, $00
	call draw_map

	; draw lower half of map
	ld d, $48
	ld e, $00
	call draw_map

	; set a tower to red
	ld hl, $5884
	;ld (hl), 58

	; set a tower to cyan
	ld hl, $58ce
	;ld (hl), 61


	jp inf_loop


; pointers
;   position in compressed map bits
;   position on screen
;   lookup table
;   tile to print
; loop invariants
;   hl:
draw_map:
	; de is the current position in vram
	; hl is the current byte in the map bits

draw_map_loop_body:
	push hl
	; load first 4 map bits into a
	rld
	and $0f

	push de
	call lookup_and_draw_tile
	pop de
	inc e

	pop hl
	push hl
	; load second 4 map bits into a
	rld
	and $0f

	push de
	call lookup_and_draw_tile
	pop de
	inc e

	; reload
	pop hl
	inc hl
	ld a, e
	cp $00
	jp nz, draw_map_loop_body
	ret

inf_loop:
	jp inf_loop

; a = tile code
; de = tile location in vram
lookup_and_draw_tile:
	; lookup 4 bits in offset table
	ld hl, lookup
	add a, a
	add a, l
	ld l, a

	; load tile address into hl
	push de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	pop de

	; draw the tile
	call draw_tile

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

; d = x
; e = y
; hl = addr of src tile
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


wait_dur:
	ld c, 255
wait_dur_outer_loop:
	ld b, 255
wait_dur_inner_loop:
	djnz wait_dur_inner_loop
	dec c
	jp nz, wait_dur_outer_loop
	ret


; d = fill byte
clear_pixels:
	ld d, 0
	call fill_all_pixels
	ret

fill_all_pixels:
	ld hl, $4000
	ld c, 24
fill_pixels:
fill_pixels_outer_loop:
	ld (hl), d
	inc hl
	ld b, 255
fill_pixels_inner_loop:
	ld (hl), d
	inc hl
	djnz fill_pixels_inner_loop
	dec c
	jp nz, fill_pixels_outer_loop
	ret


clear_attrs:
	ld d, $38
	call fill_all_attrs
	ret

; d = fill byte
fill_all_attrs:
	ld hl, $5800
	ld c, 3
fill_attrs:
fill_attrs_outer_loop:
	ld (hl), d
	inc hl
	ld b, 255
fill_attrs_inner_loop:
	ld (hl), d
	inc hl
	djnz fill_attrs_inner_loop
	dec c
	jp nz, fill_attrs_outer_loop
	ret

tile_map:
	defb $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	defb $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	defb $00, $84, $44, $49, $00, $00, $00, $00, $00, $00, $84, $44, $44, $49, $00, $00
	defb $00, $6f, $55, $e7, $00, $00, $00, $00, $00, $00, $6f, $55, $55, $e7, $00, $00
	defb $44, $c7, $10, $67, $00, $00, $84, $44, $44, $44, $c7, $00, $00, $67, $00, $00
	defb $55, $5b, $00, $67, $00, $00, $6f, $55, $55, $55, $5b, $00, $00, $67, $00, $00
	defb $00, $00, $00, $67, $00, $00, $67, $10, $00, $00, $00, $00, $00, $67, $00, $00
	defb $00, $00, $00, $67, $00, $00, $67, $00, $00, $00, $00, $00, $01, $67, $00, $00

	defb $00, $00, $84, $c7, $00, $00, $6d, $49, $00, $00, $84, $44, $44, $c7, $00, $00
	defb $00, $00, $6f, $5b, $00, $00, $a5, $e7, $00, $00, $6f, $55, $55, $5b, $00, $00
	defb $00, $00, $67, $00, $00, $00, $00, $67, $00, $00, $67, $00, $00, $00, $00, $00
	defb $00, $00, $67, $10, $00, $00, $00, $67, $00, $00, $67, $00, $00, $00, $00, $00
	defb $00, $00, $6d, $44, $44, $44, $44, $c7, $00, $00, $6d, $44, $44, $44, $44, $44
	defb $00, $00, $a5, $55, $55, $55, $55, $5b, $00, $00, $a5, $55, $55, $55, $55, $55
	defb $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	defb $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

;	defb $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;	defb $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;	defb $00, $84, $44, $49, $00, $00, $00, $00, $00, $00, $84, $44, $44, $49, $00, $00
;	defb $00, $6f, $55, $e7, $00, $00, $00, $00, $00, $00, $6f, $55, $55, $e7, $00, $00
;	defb $44, $c7, $00, $67, $00, $00, $84, $44, $44, $44, $c7, $00, $00, $67, $00, $00
;	defb $55, $5b, $00, $67, $00, $00, $6f, $55, $55, $55, $5b, $00, $00, $67, $00, $00
;	defb $00, $00, $00, $67, $00, $00, $67, $00, $00, $00, $00, $00, $00, $67, $00, $00
;	defb $00, $00, $00, $67, $00, $00, $67, $00, $00, $00, $00, $00, $00, $67, $00, $00
;
;	defb $00, $00, $84, $c7, $00, $00, $6d, $49, $00, $00, $84, $44, $44, $c7, $00, $00
;	defb $00, $00, $6f, $5b, $00, $00, $a5, $e7, $00, $00, $6f, $55, $55, $5b, $00, $00
;	defb $00, $00, $67, $00, $00, $00, $00, $67, $00, $00, $67, $00, $00, $00, $00, $00
;	defb $00, $00, $67, $00, $00, $00, $00, $67, $00, $00, $67, $00, $00, $00, $00, $00
;	defb $00, $00, $6d, $44, $44, $44, $44, $c7, $00, $00, $6d, $44, $44, $44, $44, $44
;	defb $00, $00, $a5, $55, $55, $55, $55, $5b, $00, $00, $a5, $55, $55, $55, $55, $55
;	defb $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;	defb $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00


;
;	defb $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;	defb $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;	defb $00, $84, $44, $49, $00, $00, $00, $00, $00, $00, $84, $44, $44, $49, $00, $00
;	defb $00, $6f, $55, $e7, $00, $00, $00, $00, $00, $00, $6f
;
;	defb $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;	defb $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
;
;old_tile_map:
;	defb $02, $03, $12, $13, $23, $01, $01, $01
;	defb $11, $11, $11, $11, $11, $11, $11, $11
;
;	defb $01, $02, $03, $12, $13, $23, $01, $01
;	defb $11, $11, $11, $11, $11, $11, $11, $11
;
;	defb $01, $01, $02, $03, $12, $13, $23, $01
;	defb $11, $11, $11, $11, $11, $11, $11, $11
;
;	defb $01, $01, $01, $02, $03, $12, $13, $23
;	defb $11, $11, $11, $11, $11, $11, $11, $11
;
;	defb $01, $01, $01, $02, $03, $12, $13, $23
;	defb $11, $11, $11, $11, $11, $11, $11, $11
;
;	defb $01, $01, $02, $03, $12, $13, $23, $01
;	defb $11, $11, $11, $11, $11, $11, $11, $11
;
;	defb $01, $02, $03, $12, $13, $23, $01, $01
;	defb $11, $11, $11, $11, $11, $11, $11, $11
;
;	defb $02, $03, $12, $13, $23, $01, $01, $01
;	defb $11, $11, $11, $11, $11, $11, $11, $11
;

lookup:
	defw blank_tile, dot_tile, circle_tile, cross_tile
	defw top_wall, bottom_wall, left_wall, right_wall
	defw top_left_corner, top_right_corner, bottom_left_corner, bottom_right_corner
	defw top_left_nub, top_right_nub, bottom_left_nub, bottom_right_nub

old_lookup:
	defw some_tile, blank_tile, cross_tile, circle_tile

blank_tile:
	defb $00, $00, $00, $00, $00, $00, $00, $00

some_tile:
	defb $ff, $81, $81, $99, $99, $81, $81, $ff

cross_tile:
	defb $c3, $66, $3c, $18, $18, $3c, $66, $c3

circle_tile:
	defb $3c, $66, $c3, $81, $81, $c3, $66, $3c

dot_tile:
	defb $00, $3c, $7e, $7e, $7e, $7e, $3c, $00

;	defb $81, $c3, $66, $3c, $3c, $66, $c3, $81


top_wall:
	defb 44, 219, 0, 0, 0, 0, 0, 0
bottom_wall:
	defb 0, 0, 0, 0, 0, 0, 219, 44
left_wall:
	defb 128, 64, 64, 64, 128, 128, 64, 64
right_wall:
	defb 2, 2, 1, 1, 2, 2, 2, 1

top_left_corner:
	defb 102, 153, 144, 128, 64, 128, 128, 64
top_right_corner:
	defb 152, 100, 6, 1, 2, 2, 2, 1
bottom_left_corner:
	defb 64, 128, 128, 64, 128, 144, 153, 102
bottom_right_corner:
	defb 1, 2, 2, 2, 1, 6, 100, 152

top_left_nub:
	defb 64, 128, 0, 0, 0, 0, 0, 0
top_right_nub:
	defb 2, 1, 0, 0, 0, 0, 0, 0
bottom_left_nub:
	defb 0, 0, 0, 0, 0, 0, 128, 64
bottom_right_nub:
	defb 0, 0, 0, 0, 0, 0, 1, 2



; ################
; #   ######    ##
;   # ##     ## ##
; ### ## ###### ##
; ##  ##  ##    ##
; ## #### ## #####
; ##      ##      
; ################

;[[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
; [0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0],
; [1, 1, 0, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0],
; [0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0],
; [0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0],
; [0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0],
; [0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1],
; [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]

end:
