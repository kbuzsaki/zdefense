
util_wait_dur:
	ld c, 255
util_wait_dur_outer_loop:
	ld b, 255
util_wait_dur_inner_loop:
	djnz util_wait_dur_inner_loop
	dec c
	jp nz, util_wait_dur_outer_loop
	ret

; pixel address:
; [0, 1, 0, y7,  y6, y2, y1, y0] [y5, y4, y3, x7,  x6, x5, x4, x3]
;
; attr address
; [0, 1, 0,  1,  1,  0, y7, y6] [y5, y4, y3, x7, x6, x5, x4, x3]

; draws the tile pointed at by hl to the cell pointed at by de
; inputs:
;   hl - the address of the source tile (packed 8 bytes)
;   de - the start address of the cell in vram
util_draw_tile:
	push bc
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
	pop bc
	ret


; d = fill byte
util_clear_pixels:
	ld d, 0
	call util_fill_all_pixels
	ret

util_fill_all_pixels:
	ld hl, $4000
	ld c, 24
util_fill_pixels:
util_fill_pixels_outer_loop:
	ld (hl), d
	inc hl
	ld b, 255
util_fill_pixels_inner_loop:
	ld (hl), d
	inc hl
	djnz util_fill_pixels_inner_loop
	dec c
	jp nz, util_fill_pixels_outer_loop
	ret


util_clear_attrs:
	ld d, $38
	call util_fill_all_attrs
	ret

; d = fill byte
util_fill_all_attrs:
	ld hl, $5800
	ld c, 3
util_fill_attrs:
util_fill_attrs_outer_loop:
	ld (hl), d
	inc hl
	ld b, 255
util_fill_attrs_inner_loop:
	ld (hl), d
	inc hl
	djnz util_fill_attrs_inner_loop
	dec c
	jp nz, util_fill_attrs_outer_loop
	ret

; Draws a rectangular set of tiles
;
; hl = address of first image tile
; b = width of the image
; c = height of the image
; d  = x for upper left cell 
; e  = y for upper left cell
;
; lord help me if I need to read this again
image_tile_offset:
    defb 0

image_width:
    defb 0

util_draw_image:
    ; setup hl' with the address of the first image tile
    push hl
    exx
    pop hl
    exx

    ; save image width value since it is the innerloop counter
    ld a, b
    ld (image_width), a

    ; reset tile offset to 0
    ld a, 0
    ld (image_tile_offset), a

    ; height of the image is outerloop counter
    push bc
  util_draw_image_outer_loop:
    ;load width into b for innerloop
    ld a, (image_width)
    ld b, a

    push de; save x coord value
  util_draw_image_inner_loop:
    ; set attr byte
    call cursor_get_cell_attr
    ld a, $0c
    ld (hl), a

    ; setup pixel byte
    push de
    ; setup first pixel vram address
    call cursor_get_cell_addr
    ex de, hl

    ; setup tile_location
    push de ; save pixel vram address

    ; get the address of the first image tile into de
    exx
    push hl
    exx
    pop hl
    ex de, hl

    ; hl = image__offset + first image tile address
    ld a, (image_tile_offset)
    ld l, a
    ld h, 0
    add hl, de

    pop de ; recover pixel vram address

    ; actually draw tile
    call util_draw_tile
    pop de 

    ;inc tile_offset
    ld a, (image_tile_offset)
    add a, 8
    ld (image_tile_offset), a

    ;inc x coord
    inc d
    djnz util_draw_image_inner_loop
    ; reset the x coord, and increment y coord before jumping to outerloop
    pop de
    inc e

    pop bc
    dec c
    push bc

    jp nz, util_draw_image_outer_loop
    pop bc

    ret

