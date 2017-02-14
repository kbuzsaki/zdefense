
; 6, 4
; 0001 0000  0000 0111
; 0100 0111  0000 0010
; regular coord
;
; pixel address:
; [0, 1, 0, y7,  y6, y2, y1, y0] [y5, y4, y3, x7,  x6, x5, x4, x3]
;
; attr address
; [0, 1, 0,  1,  1,  0, y7, y6] [y5, y4, y3, x7, x6, x5, x4, x3]

org 32768

	; setup interrupt handler, disable interrupts
	ld hl, interrupt_handler
	call setup_interrupt_handler

	; set pixels to 0, background to white, foreground to black
	call clear_pixels
	call clear_attrs

	ld d, 16
	ld e, 1

	; enable interrupts again now that we're set up
	ei

	; wait for next interrupt
infinite_wait:
	jp infinite_wait


; cursor stuff
interrupt_handler:
	di

	push de
	call get_pixel_addr
	ex de, hl
    ld hl, blank_tile
	call draw_tile
	pop de

	inc e
	ld a, e
	sub 180
	jr c, skip_set
	ld e, 0
skip_set:


	push de
	call get_pixel_addr
	ex de, hl
    ld hl, some_tile
	call draw_tile
	pop de

interrupt_handler_end:
	ei
	reti


; de = addr of dest in vram
; hl = addr of src tile
draw_tile:
	push de

	; load y2, y1, y0 into a
	ld a, d
	and 7

	; calculate the number of iterations until y2, y1, y0 == 0
	ld b, a
	ld a, 7
	sub b
	jp z, end_draw_tile_loop_a
	add 1
	ld b, a
	ld c, 0

draw_tile_loop_a:
	ldi
	inc d
	dec de
	djnz draw_tile_loop_a
end_draw_tile_loop_a:

	ld a, (hl)
	ld (de), a
	inc hl

	pop de

	ld a, d
	and 7
	jp z, end_draw_tile_loop_b
	ld b, a
	xor d
	ld d, a
	ld a, e
	add 32
	ld e, a
	jp nc, skip_fix
	ld a, d
	add 8
	ld d, a
skip_fix:

draw_tile_loop_b:
	ldi
	inc d
	dec de
	djnz draw_tile_loop_b
end_draw_tile_loop_b:

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


; Address space wrap-around interrupt handler discussed in class
; Code adapted from:
; http://www.animatez.co.uk/computers/zx-spectrum/interrupts/
; Uses the address in hl as the interrupt handler
setup_interrupt_handler:
    di                         ; disable interrupts
    ld ix, $FFF0               ; Where to stick this code
    ld (ix + $4), $C3          ; Z80 opcode for JP
    ld (ix + $5), l            ; Where to JP to (in HL)
    ld (ix + $6), h
    ld (ix + $F), $18          ; Z80 Opcode for JR
    ld a, $39                  ; High byte address of vector table
    ld i, a                    ; Set I register to this
    im 2                       ; Set Interrupt Mode 2
	ret


frame_counter:
	defb 0


ignore_filler:
	defs 128


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
