; loads the map pointed to by hl
load_map_load_map:
	ld d, $40
	ld e, $00
	call load_map_draw_map

	; draw lower half of map
	ld d, $48
	ld e, $00
	call load_map_draw_map
	ret

; pointers
;   position in compressed map bits
;   position on screen
;   lookup table
;   tile to print
; loop invariants
;   hl:
load_map_draw_map:
	; de is the current position in vram
	; hl is the current byte in the map bits

load_map_draw_map_loop_body:
	push hl
	; load first 4 map bits into a
	rld
	and $0f

	push de
	call load_map_lookup_and_old_draw_tile
	pop de
	inc e

	pop hl
	push hl
	; load second 4 map bits into a
	rld
	and $0f

	push de
	call load_map_lookup_and_old_draw_tile
	pop de
	inc e

	; reload
	pop hl
	inc hl
	ld a, e
	cp $00
	jp nz, load_map_draw_map_loop_body
	ret

; a = tile code
; de = tile location in vram
load_map_lookup_and_old_draw_tile:
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
	call load_map_old_draw_tile

	ret

; de = addr of dest in vram
; hl = addr of src tile
load_map_old_draw_tile:
	push de

	; load y2, y1, y0 into a
	ld a, d
	and 7

	; calculate the number of iterations until y2, y1, y0 == 0
	ld b, a
	ld a, 7
	sub b
	jp z, load_map_end_old_draw_tile_loop_a
	add 1
	ld b, a
	ld c, 0

load_map_old_draw_tile_loop_a:
	ldi
	inc d
	dec de
	djnz load_map_old_draw_tile_loop_a
load_map_end_old_draw_tile_loop_a:

	ld a, (hl)
	ld (de), a
	inc hl

	pop de

	ld a, d
	and 7
	jp z, load_map_end_old_draw_tile_loop_b
	ld b, a
	xor d
	ld d, a
	ld a, e
	add 32
	ld e, a
	jp nc, load_map_old_draw_tile_skip_fix
	ld a, d
	add 8
	ld d, a
load_map_old_draw_tile_skip_fix:

load_map_old_draw_tile_loop_b:
	ldi
	inc d
	dec de
	djnz load_map_old_draw_tile_loop_b
load_map_end_old_draw_tile_loop_b:
	ret
