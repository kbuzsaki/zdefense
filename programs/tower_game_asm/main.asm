org 32768

	; disable interrupts for the duration of the setup phase
	di

	; setup the interrupt handler
	ld hl, interrupt_handler
	call setup_interrupt_handler

	; call various module init functions
	call main_init
	call load_map_init
	call enemy_handler_init
	call status_init
	call cursor_init

	; enable interrupts again now that we're set up
	ei

	; infinite loop that spins while we wait for an interrupt
infinite_wait:
	jp infinite_wait


; main game loop, called by the refresh interrupt handler at 50hz
interrupt_handler:
	di

	; increment the counters, skip rendering unless we're on a render frame
	call increment_frame_counters

	; take cursor input at 25hz
	ld a, (sub_frame_counter)
	and 3
	call z, cursor_entry_point_handle_input

	; play music note on odd frames
	ld a, (sub_frame_counter)
	and 1
	call nz, music_entry_point

	; only do other updates every 8th screen refresh
	ld a, (sub_frame_counter)
	cp 0
	jp nz, interrupt_handler_end

	; call handle enemies every frame
	call enemy_handler_entry_point_handle_enemies

	;; only do enemy spawning every other cell frame when the frame_counter is 0
	; and the LSB of cell_counter is 0
	ld a, (real_frame_counter)
	and $38
	cp $18
	call z, enemy_handler_entry_point_handle_spawn_enemies

	;; also update the enemy status at the same count
	ld a, (real_frame_counter)
	and $38
	cp $18
	call z, status_entry_point_update_enemy_spawn_preview

interrupt_handler_end:
	ei

	reti


; misc init in the main module
; sets the border color and clears the screen
main_init:
	ld a, 1
	out ($fe), a
	ld ($fdcc), a

	; set pixels to 0, background to white, foreground to black
	call util_clear_pixels
	ld d, $34
	call util_fill_all_attrs

	; set the screen to black
	ld d, $ff
	call util_fill_all_pixels

	call init_level_a

	ret


; sets up level data to use level a
init_level_a:
	ld hl, enemy_path_a
	ld (enemy_path), hl
	ld hl, enemy_path_attr_a
	ld (enemy_path_attr), hl
	ld hl, enemy_path_direction_a
	ld (enemy_path_direction), hl
	ld hl, enemy_path_xy_a
	ld (enemy_path_xy), hl
	ld hl, tile_map_a
	ld (tile_map), hl
	ret             

; sets up level data to use level b
init_level_b:
	ld hl, enemy_path_b
	ld (enemy_path), hl
	ld hl, enemy_path_attr_b
	ld (enemy_path_attr), hl
	ld hl, enemy_path_direction_b
	ld (enemy_path_direction), hl
	ld hl, enemy_path_xy_b
	ld (enemy_path_xy), hl
	ld hl, tile_map_b
	ld (tile_map), hl
	ret             

; sets up level data to use level c
init_level_c:
	ld hl, enemy_path_c
	ld (enemy_path), hl
	ld hl, enemy_path_attr_c
	ld (enemy_path_attr), hl
	ld hl, enemy_path_direction_c
	ld (enemy_path_direction), hl
	ld hl, enemy_path_xy_c
	ld (enemy_path_xy), hl
	ld hl, tile_map_c
	ld (tile_map), hl
	ret             

	

; increment_frame_counters increments the various frame counters
;
; real_frame_counter bit layout:
; MSB                 LSB
; +-------+-----+-------+
; | a a a | b b | c c c |
; +-------+-----+-------+
; c: sub_frame_counter: 
;        the game animates a visual frame when this is 0
; b: frame_counter: 
;        these bits determine which visual frame each animation plays
;        when all 4 visual frames play, each enemy will have moved 1 cell
;        this is one "cell frame"
; a: cell_frame_counter: 
;        a modulo 8 counter of the number of cell frames that have passed
;        this is used to time things that only occur every few cell moves,
;        such as enemy spawning
increment_frame_counters:
	; increment the lowest level frame counter
	ld a, (real_frame_counter)
	inc a
	ld (real_frame_counter), a

	; mask off the bottom 3 bits as the sub_frame_counter
	ld b, a
	and 7
	ld (sub_frame_counter), a
	ld a, b
	rrca
	rrca
	rrca

	; mask off the middle 2 bits as the frame_counter
	ld b, a
	and 3
	ld (frame_counter), a
	ld a, b
	rrca
	rrca

	; mask off the upper 3 bits as the cell_frame_counter
	and 7
	ld (cell_frame_counter), a

	ret


include "build.asm"
include "cursor.asm"
include "enemy_handler.asm"
include "enemy_sprite.asm"
include "input.asm"
include "load_map.asm"
include "misc.asm"
include "status.asm"
include "util.asm"
include "music.asm"


; Address space wrap-around interrupt handler discussed in class
; Code adapted from:
; http://www.animatez.co.uk/computers/zx-spectrum/interrupts/
; Uses the address in hl as the interrupt handler
setup_interrupt_handler:
    ld ix, $FFF0               ; Where to stick this code
    ld (ix + $4), $C3          ; Z80 opcode for JP
    ld (ix + $5), l            ; Where to JP to (in HL)
    ld (ix + $6), h
    ld (ix + $F), $18          ; Z80 Opcode for JR
    ld a, $39                  ; High byte address of vector table
    ld i, a                    ; Set I register to this
    im 2                       ; Set Interrupt Mode 2
	ret


saved_sp:
    defw    0

real_frame_counter:
	defb 0

sub_frame_counter:
	defb 0

frame_counter:
	defb 0

cell_frame_counter:
	defb 0

cursor_x:
	defb 0

cursor_y:
	defb 0

cursor_old_attr:
	defb 0

health_tens:
    defb 0

health_ones:
    defb 0

money_tens:
    defb 0

money_ones:
    defb 0

; pixel address:
; [0, 1, 0, y7,  y6, y2, y1, y0] [y5, y4, y3, x7,  x6, x5, x4, x3]
;
; attr address
; [0, 1, 0,  1,  1,  0, y7, y6] [y5, y4, y3, x7, x6, x5, x4, x3]

; filler padding for alignment
; enemy data
defs $9000 - $

; per-level pointers set up in main_init to point to the appropriate level data
enemy_path:
	defw $00
enemy_path_attr:
	defw $00
enemy_path_direction:
	defw $00
enemy_path_xy:
	defw $00
tile_map:
	defw $00

; constants for enemy health 
weak_enemy_default_health:
	defb $04
weak_enemy_hurt_threshold:
	defb $02
strong_enemy_default_health:
	defb $08
strong_enemy_hurt_threshold:
	defb $04

; game state maintained by enemy_handler functions
current_enemy_position_array:
	defw $00
current_enemy_health_array:
	defw $00
current_enemy_hurt_threshold:
	defb $05
current_enemy_index:
	defb $00
current_enemy_sprite_page:
	defw $00
enemy_spawn_script_ptr:
	defw $00

defs $9200 - $

; dynamic arrays of enemy state
; each array takes up a full memory page
weak_enemy_position_array:
	defs $9300 - $, $ff
weak_enemy_health_array:
	defs $9400 - $, $ff
strong_enemy_position_array:
	defs $9500 - $, $ff
strong_enemy_health_array:
	defs $9600 - $, $ff

defs $9600 - $

enemy_spawn_script:
	defb $01
	defb $01
	defb $fe
	defb $01
	defb $01
	defb $fe
	defb $02
	defb $02
	defb $fe
	defb $02
	defb $02
	defb $02
	defb $02
	defb $9700 - $, $ff

; map data
defs $a000 - $

enemy_path_a:
	defw $0000
	defw $40a0, $40a1, $40a2, $40a3, $40a4, $40c4, $40e4, $4804
	defw $4824, $4825, $4826, $4827, $4828, $4829, $482a, $482b
	defw $480b, $40eb, $40cb, $40ab, $408b, $406b, $406c, $406d
	defw $406e, $406f, $4070, $4071, $4072, $4073, $4093, $40b3
	defw $40d3, $40f3, $4813, $4833, $4853, $4873, $4893, $4894
	defw $4895, $4896, $4897, $4898, $4899, $489a, $489b, $487b
	defw $485b, $483b, $481b, $40fb, $40fc, $40fd, $40fe, $40ff
	defw $ffff

enemy_path_attr_a:
	defw $0000
	defw $58a0, $58a1, $58a2, $58a3, $58a4, $58c4, $58e4, $5904
	defw $5924, $5925, $5926, $5927, $5928, $5929, $592a, $592b
	defw $590b, $58eb, $58cb, $58ab, $588b, $586b, $586c, $586d
	defw $586e, $586f, $5870, $5871, $5872, $5873, $5893, $58b3
	defw $58d3, $58f3, $5913, $5933, $5953, $5973, $5993, $5994
	defw $5995, $5996, $5997, $5998, $5999, $599a, $599b, $597b
	defw $595b, $593b, $591b, $58fb, $58fc, $58fd, $58fe, $58ff
	defw $ffff

defs $a100 - $

enemy_path_direction_a:
	defb $00
	defb $00, $00, $00, $00, $03, $03, $03, $03
	defb $00, $00, $00, $00, $00, $00, $00, $02
	defb $02, $02, $02, $02, $02, $00, $00, $00
	defb $00, $00, $00, $00, $00, $03, $03, $03
	defb $03, $03, $03, $03, $03, $03, $00, $00
	defb $00, $00, $00, $00, $00, $00, $02, $02
	defb $02, $02, $02, $00, $00, $00, $00, $00
	defb $ff

enemy_path_xy_a:
	defb $00, $00
	defb $00, $05, $01, $05, $02, $05, $03, $05
	defb $04, $05, $04, $06, $04, $07, $04, $08
	defb $04, $09, $05, $09, $06, $09, $07, $09
	defb $08, $09, $09, $09, $0a, $09, $0b, $09
	defb $0b, $08, $0b, $07, $0b, $06, $0b, $05
	defb $0b, $04, $0b, $03, $0c, $03, $0d, $03
	defb $0e, $03, $0f, $03, $10, $03, $11, $03
	defb $12, $03, $13, $03, $13, $04, $13, $05
	defb $13, $06, $13, $07, $13, $08, $13, $09
	defb $13, $0a, $13, $0b, $13, $0c, $14, $0c
	defb $15, $0c, $16, $0c, $17, $0c, $18, $0c
	defb $19, $0c, $1a, $0c, $1b, $0c, $1b, $0b
	defb $1b, $0a, $1b, $09, $1b, $08, $1b, $07
	defb $1c, $07, $1d, $07, $1e, $07, $1f, $07
	defb $ff, $ff

defs $a200 - $

tile_map_a:
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $21, $11, $11, $11, $11, $11, $11, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $21, $84, $44, $44, $44, $44, $91, $22, $22, $22, $22, $22
	defb $11, $11, $11, $12, $21, $60, $00, $00, $00, $00, $71, $22, $22, $22, $22, $22
	defb $44, $44, $49, $12, $21, $60, $f5, $55, $55, $e0, $71, $22, $22, $22, $22, $22
	defb $00, $00, $07, $12, $21, $60, $71, $11, $11, $60, $71, $22, $21, $11, $11, $11
	defb $55, $5e, $07, $12, $21, $60, $71, $22, $21, $60, $71, $22, $21, $84, $44, $44
	defb $11, $16, $07, $11, $11, $60, $71, $22, $21, $60, $71, $22, $21, $60, $00, $00
	defb $22, $16, $0d, $44, $44, $c0, $71, $22, $21, $60, $71, $22, $21, $60, $f5, $55
	defb $22, $16, $00, $00, $00, $00, $71, $22, $21, $60, $71, $22, $21, $60, $71, $11
	defb $22, $1a, $55, $55, $55, $55, $b1, $22, $21, $60, $71, $11, $11, $60, $71, $22
	defb $22, $11, $11, $11, $11, $11, $11, $22, $21, $60, $d4, $44, $44, $c0, $71, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $21, $60, $00, $00, $00, $00, $71, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $21, $a5, $55, $55, $55, $55, $b1, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $21, $11, $11, $11, $11, $11, $11, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22

defs $a300 - $

enemy_path_b:
	defw $0000
	defw $40e0, $40e1, $40e2, $40e3, $40e4, $40e5, $40e6, $40e7
	defw $40e8, $40e9, $40ea, $40eb, $40ec, $40ed, $40ee, $40ef
	defw $40f0, $40f1, $40f2, $40f3, $40f4, $40f5, $40f6, $40f7
	defw $40f8, $40f9, $40fa, $40fb, $40fc, $40fd, $40fe, $40ff
	defw $ffff

enemy_path_attr_b:
	defw $0000
	defw $58e0, $58e1, $58e2, $58e3, $58e4, $58e5, $58e6, $58e7
	defw $58e8, $58e9, $58ea, $58eb, $58ec, $58ed, $58ee, $58ef
	defw $58f0, $58f1, $58f2, $58f3, $58f4, $58f5, $58f6, $58f7
	defw $58f8, $58f9, $58fa, $58fb, $58fc, $58fd, $58fe, $58ff
	defw $ffff

defs $a400 - $

enemy_path_direction_b:
	defb $00
	defb $00, $00, $00, $00, $00, $00, $00, $00
	defb $00, $00, $00, $00, $00, $00, $00, $00
	defb $00, $00, $00, $00, $00, $00, $00, $00
	defb $00, $00, $00, $00, $00, $00, $00, $00
	defb $ff

enemy_path_xy_b:
	defb $00, $00
	defb $00, $07, $01, $07, $02, $07, $03, $07
	defb $04, $07, $05, $07, $06, $07, $07, $07
	defb $08, $07, $09, $07, $0a, $07, $0b, $07
	defb $0c, $07, $0d, $07, $0e, $07, $0f, $07
	defb $10, $07, $11, $07, $12, $07, $13, $07
	defb $14, $07, $15, $07, $16, $07, $17, $07
	defb $18, $07, $19, $07, $1a, $07, $1b, $07
	defb $1c, $07, $1d, $07, $1e, $07, $1f, $07
	defb $ff, $ff

defs $a500 - $

tile_map_b:
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11
	defb $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44
	defb $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	defb $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55
	defb $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22

defs $a600 - $

enemy_path_c:
	defw $0000
	defw $4840, $4841, $4842, $4843, $4844, $4845, $4846, $4847
	defw $4848, $4849, $484a, $484b, $484c, $482c, $480c, $40ec
	defw $40cc, $40ac, $40ad, $40ae, $40af, $40b0, $40b1, $40b2
	defw $40b3, $40d3, $40f3, $4813, $4833, $4853, $4854, $4855
	defw $4856, $4857, $4858, $4859, $485a, $485b, $485c, $485d
	defw $485e, $485f
	defw $ffff

enemy_path_attr_c:
	defw $0000
	defw $5940, $5941, $5942, $5943, $5944, $5945, $5946, $5947
	defw $5948, $5949, $594a, $594b, $594c, $592c, $590c, $58ec
	defw $58cc, $58ac, $58ad, $58ae, $58af, $58b0, $58b1, $58b2
	defw $58b3, $58d3, $58f3, $5913, $5933, $5953, $5954, $5955
	defw $5956, $5957, $5958, $5959, $595a, $595b, $595c, $595d
	defw $595e, $595f
	defw $ffff

defs $a700 - $

enemy_path_direction_c:
	defb $00
	defb $00, $00, $00, $00, $00, $00, $00, $00
	defb $00, $00, $00, $00, $02, $02, $02, $02
	defb $02, $00, $00, $00, $00, $00, $00, $00
	defb $03, $03, $03, $03, $03, $00, $00, $00
	defb $00, $00, $00, $00, $00, $00, $00, $00
	defb $00, $00
	defb $ff

enemy_path_xy_c:
	defw $00, $00
	defb $00, $0a, $01, $0a, $02, $0a, $03, $0a
	defb $04, $0a, $05, $0a, $06, $0a, $07, $0a
	defb $08, $0a, $09, $0a, $0a, $0a, $0b, $0a
	defb $0c, $0a, $0c, $09, $0c, $08, $0c, $07
	defb $0c, $06, $0c, $05, $0d, $05, $0e, $05
	defb $0f, $05, $10, $05, $11, $05, $12, $05
	defb $13, $05, $13, $06, $13, $07, $13, $08
	defb $13, $09, $13, $0a, $14, $0a, $15, $0a
	defb $16, $0a, $17, $0a, $18, $0a, $19, $0a
	defb $1a, $0a, $1b, $0a, $1c, $0a, $1d, $0a
	defb $1e, $0a, $1f, $0a
	defb $ff, $ff

defs $a800 - $

tile_map_c:
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $11, $11, $11, $11, $11, $11, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $18, $44, $44, $44, $44, $91, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $16, $00, $00, $00, $00, $71, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $16, $0f, $55, $55, $e0, $71, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $16, $07, $11, $11, $60, $71, $22, $22, $22, $22, $22
	defb $11, $11, $11, $11, $11, $16, $07, $12, $21, $60, $71, $11, $11, $11, $11, $11
	defb $44, $44, $44, $44, $44, $4c, $07, $12, $21, $60, $d4, $44, $44, $44, $44, $44
	defb $00, $00, $00, $00, $00, $00, $07, $12, $21, $60, $00, $00, $00, $00, $00, $00
	defb $55, $55, $55, $55, $55, $55, $5b, $12, $21, $a5, $55, $55, $55, $55, $55, $55
	defb $11, $11, $11, $11, $11, $11, $11, $12, $21, $11, $11, $11, $11, $11, $11, $11
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22


; tile lookup data
defs $a900 - $

lookup:
	defw blank_tile, filled_tile, filled_tile, cross_tile
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

filled_tile:
	defb $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

;	defb $81, $c3, $66, $3c, $3c, $66, $c3, $81


top_wall:
	defb $ff, $db, $00, $00, $00, $00, $00, $00
bottom_wall:
	defb $00, $00, $00, $00, $00, $00, $db, $ff
left_wall:
	defb $80, $c0, $c0, $c0, $80, $80, $c0, $c0
right_wall:
	defb $03, $03, $01, $01, $03, $03, $03, $01

top_left_corner:
	defb $ff, $99, $90, $80, $c0, $80, $80, $c0
top_right_corner:
	defb $ff, $7f, $07, $01, $03, $03, $03, $01
bottom_left_corner:
	defb $c0, $80, $80, $c0, $80, $90, $99, $ff
bottom_right_corner:
	defb $01, $03, $03, $03, $01, $07, $7f, $ff

top_left_nub:
	defb $c0, $80, $00, $00, $00, $00, $00, $00
top_right_nub:
	defb $03, $01, $00, $00, $00, $00, $00, $00
bottom_left_nub:
	defb $00, $00, $00, $00, $00, $00, $80, $c0
bottom_right_nub:
	defb $00, $00, $00, $00, $00, $00, $01, $03

tree_tile:
defb 255  	; ########
defb 231  	; ###  ###
defb 195  	; ##    ##
defb 129  	; #      #
defb 231  	; ###  ###
defb 195  	; ##    ##
defb 129  	; #      #
defb 231  	; ###  ###


tower_basic:
    defb 90     ;     # ## #
    defb 255    ;    ########
    defb 126    ;     ######
    defb 60     ;      ####
    defb 60     ;      ####
    defb 60     ;      ####
    defb 60     ;      ####
    defb 60     ;      ####

tower_basic_upgrade:
    defb 165    ;    # #  # #
    defb 255    ;    ########
    defb 219    ;    ## ## ##
    defb 255    ;    ########
    defb 126    ;     ######
    defb 60     ;      ####
    defb 60     ;      ####
    defb 60     ;      ####

tower_bomb:
    defb 255    ;    ########
    defb 129    ;    #      #
    defb 153    ;    #  ##  #
    defb 165    ;    # #  # #
    defb 165    ;    # #  # #
    defb 153    ;    #  ##  #
    defb 129    ;    #      #
    defb 255    ;    ########

tower_bomb_upgrade:
    defb 60     ;      ####
    defb 36     ;      #  #
    defb 219    ;    ## ## ##
    defb 165    ;    # #  # #
    defb 165    ;    # #  # #
    defb 219    ;    ## ## ##
    defb 36     ;      #  #
    defb 60     ;      ####

tower_zap:
    defb 60     ;      ####
    defb 66     ;     #    #
    defb 66     ;     #    #
    defb 60     ;      ####
    defb 24     ;       ##
    defb 24     ;       ##
    defb 24     ;       ##
    defb 24     ;       ##

tower_zap_upgrade:
    defb 126    ;     ######
    defb 129    ;    #      #
    defb 129    ;    #      #
    defb 129    ;    #      #
    defb 126    ;     ######
    defb 60     ;      ####
    defb 24     ;       ##
    defb 24     ;       ##

tower_obelisk:
    defb 24     ;       ##   
    defb 60     ;      ####  
    defb 60     ;      ####  
    defb 60     ;      ####  
    defb 60     ;      ####  
    defb 126    ;     ###### 
    defb 255    ;    ########
    defb 255    ;    ########

tower_obelisk_upgrade:
    defb 60     ;      #### 
    defb 36     ;      #  #  
    defb 102    ;     ##  ## 
    defb 66     ;     #    # 
    defb 66     ;     #    # 
    defb 66     ;     #    # 
    defb 195    ;    ##    ##
    defb 255    ;    ########

lightning:
    defb 3      ;          ##
    defb 14     ;        ###
    defb 56     ;      ###
    defb 254    ;    #######
    defb 127    ;     #######
    defb 28     ;       ###
    defb 122    ;     ###
    defb 192    ;    ##

dollar:
    defb 36     ;      #  #
    defb 126    ;     ######
    defb 165    ;    # #  # #
    defb 116    ;     ### #
    defb 46     ;      # ###
    defb 165    ;    # #  # #
    defb 126    ;     ######
    defb 36     ;      #  #

heart:
    defb 102    ;     ##  ##
    defb 255    ;    ########
    defb 255    ;    ########
    defb 255    ;    ########
    defb 126    ;     ######
    defb 60     ;      ####
    defb 24     ;       ##
    defb 0      ;

heart_hollow:
    defb 102    ;     ##  ##
    defb 154    ;    #  ##  #
    defb 129    ;    #      #
    defb 129    ;    #      #
    defb 66     ;     #    #
    defb 36     ;      #  #
    defb 24     ;       ##
    defb 0      ;

bullet:
    defb 24     ;       ##
    defb 60     ;      ####
    defb 126    ;     ######
    defb 126    ;     ######
    defb 126    ;     ######
    defb 126    ;     ######
    defb 0      ;
    defb 126    ;     ######

bullet_hollow:
    defb 24     ;       ##
    defb 36     ;      #  #
    defb 66     ;     #    #
    defb 66     ;     #    #
    defb 66     ;     #    #
    defb 126    ;     ######
    defb 0      ;
    defb 126    ;     ######

; pad so enemy sprites are aligned
defs $b000 - $

weak_enemy:
defb 60  	;   ####  
defb 52  	;   ## #  
defb 24  	;    ##   
defb 24  	;    ##   
defb 24  	;    ##   
defb 24  	;    ##   
defb 8  	;     #   
defb 12  	;     ##  

defb 15  	;     ####
defb 13  	;     ## #
defb 6  	;      ## 
defb 15  	;     ####
defb 22  	;    # ## 
defb 7  	;      ###
defb 5  	;      # #
defb 6  	;      ## 

defb 3  	;       ##
defb 3  	;       ##
defb 1  	;        #
defb 1  	;        #
defb 1  	;        #
defb 1  	;        #
defb 0  	;         
defb 0  	;         

defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 1  	;        #
defb 0  	;         
defb 0  	;         
defb 0  	;         

defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         

defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 128  	; #       
defb 0  	;         
defb 128  	; #       
defb 0  	;         

defb 192  	; ##      
defb 64  	;  #      
defb 128  	; #       
defb 128  	; #       
defb 128  	; #       
defb 128  	; #       
defb 128  	; #       
defb 192  	; ##      

defb 240  	; ####    
defb 208  	; ## #    
defb 96  	;  ##     
defb 240  	; ####    
defb 104  	;  ## #   
defb 112  	;  ###    
defb 88  	;  # ##   
defb 96  	;  ##     

defb 60  	;   ####  
defb 60  	;   ####  
defb 24  	;    ##   
defb 60  	;   ####  
defb 90  	;  # ## # 
defb 24  	;    ##   
defb 36  	;   #  #  
defb 102  	;  ##  ## 

defb 60  	;   ####  
defb 60  	;   ####  
defb 24  	;    ##   
defb 60  	;   ####  
defb 90  	;  # ## # 
defb 24  	;    ##   
defb 36  	;   #  #  
defb 6  	;      ## 

defb 60  	;   ####  
defb 60  	;   ####  
defb 24  	;    ##   
defb 60  	;   ####  
defb 90  	;  # ## # 
defb 24  	;    ##   
defb 36  	;   #  #  
defb 102  	;  ##  ## 

defb 60  	;   ####  
defb 60  	;   ####  
defb 24  	;    ##   
defb 60  	;   ####  
defb 90  	;  # ## # 
defb 24  	;    ##   
defb 36  	;   #  #  
defb 96  	;  ##     

defb 60  	;   ####  
defb 36  	;   #  #  
defb 24  	;    ##   
defb 60  	;   ####  
defb 90  	;  # ## # 
defb 24  	;    ##   
defb 36  	;   #  #  
defb 102  	;  ##  ## 

defb 60  	;   ####  
defb 36  	;   #  #  
defb 24  	;    ##   
defb 60  	;   ####  
defb 90  	;  # ## # 
defb 24  	;    ##   
defb 36  	;   #  #  
defb 96  	;  ##     

defb 60  	;   ####  
defb 36  	;   #  #  
defb 24  	;    ##   
defb 60  	;   ####  
defb 90  	;  # ## # 
defb 24  	;    ##   
defb 36  	;   #  #  
defb 102  	;  ##  ## 

defb 60  	;   ####  
defb 36  	;   #  #  
defb 24  	;    ##   
defb 60  	;   ####  
defb 90  	;  # ## # 
defb 24  	;    ##   
defb 36  	;   #  #  
defb 6  	;      ## 

defb 60  	;   ####  
defb 52  	;   ## #  
defb 24  	;    ##   
defb 24  	;    ##   
defb 24  	;    ##   
defb 24  	;    ##   
defb 8  	;     #   
defb 12  	;     ##  

defb 15  	;     ####
defb 13  	;     ## #
defb 6  	;      ## 
defb 14  	;     ### 
defb 22  	;    # ## 
defb 7  	;      ###
defb 5  	;      # #
defb 6  	;      ## 

defb 3  	;       ##
defb 3  	;       ##
defb 1  	;        #
defb 1  	;        #
defb 1  	;        #
defb 1  	;        #
defb 0  	;         
defb 0  	;         

defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         

defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         

defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 128  	; #       
defb 0  	;         

defb 192  	; ##      
defb 64  	;  #      
defb 128  	; #       
defb 128  	; #       
defb 128  	; #       
defb 128  	; #       
defb 128  	; #       
defb 192  	; ##      

defb 240  	; ####    
defb 208  	; ## #    
defb 96  	;  ##     
defb 112  	;  ###    
defb 104  	;  ## #   
defb 112  	;  ###    
defb 88  	;  # ##   
defb 96  	;  ##     

defb 60  	;   ####  
defb 60  	;   ####  
defb 24  	;    ##   
defb 56  	;   ###   
defb 88  	;  # ##   
defb 24  	;    ##   
defb 36  	;   #  #  
defb 102  	;  ##  ## 

defb 60  	;   ####  
defb 60  	;   ####  
defb 24  	;    ##   
defb 56  	;   ###   
defb 88  	;  # ##   
defb 24  	;    ##   
defb 36  	;   #  #  
defb 6  	;      ## 

defb 60  	;   ####  
defb 60  	;   ####  
defb 24  	;    ##   
defb 56  	;   ###   
defb 88  	;  # ##   
defb 24  	;    ##   
defb 36  	;   #  #  
defb 102  	;  ##  ## 

defb 60  	;   ####  
defb 60  	;   ####  
defb 24  	;    ##   
defb 56  	;   ###   
defb 88  	;  # ##   
defb 24  	;    ##   
defb 36  	;   #  #  
defb 96  	;  ##     

defb 60  	;   ####  
defb 36  	;   #  #  
defb 24  	;    ##   
defb 28  	;    ###  
defb 26  	;    ## # 
defb 24  	;    ##   
defb 36  	;   #  #  
defb 102  	;  ##  ## 

defb 60  	;   ####  
defb 36  	;   #  #  
defb 24  	;    ##   
defb 28  	;    ###  
defb 26  	;    ## # 
defb 24  	;    ##   
defb 36  	;   #  #  
defb 96  	;  ##     

defb 60  	;   ####  
defb 36  	;   #  #  
defb 24  	;    ##   
defb 28  	;    ###  
defb 26  	;    ## # 
defb 24  	;    ##   
defb 36  	;   #  #  
defb 102  	;  ##  ## 

defb 60  	;   ####  
defb 36  	;   #  #  
defb 24  	;    ##   
defb 28  	;    ###  
defb 26  	;    ## # 
defb 24  	;    ##   
defb 36  	;   #  #  
defb 6  	;      ## 
defs $b100 - $

strong_enemy:
defb 60  	;   ####  
defb 122  	;  #### # 
defb 255  	; ########
defb 253  	; ###### #
defb 254  	; ####### 
defb 127  	;  #######
defb 24  	;    ##   
defb 28  	;    ###  

defb 15  	;     ####
defb 30  	;    #### 
defb 63  	;   ######
defb 63  	;   ######
defb 63  	;   ######
defb 31  	;    #####
defb 13  	;     ## #
defb 14  	;     ### 

defb 3  	;       ##
defb 7  	;      ###
defb 15  	;     ####
defb 15  	;     ####
defb 15  	;     ####
defb 7  	;      ###
defb 1  	;        #
defb 1  	;        #

defb 0  	;         
defb 1  	;        #
defb 3  	;       ##
defb 3  	;       ##
defb 3  	;       ##
defb 1  	;        #
defb 0  	;         
defb 0  	;         

defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         

defb 0  	;         
defb 128  	; #       
defb 192  	; ##      
defb 64  	;  #      
defb 128  	; #       
defb 192  	; ##      
defb 128  	; #       
defb 192  	; ##      

defb 192  	; ##      
defb 160  	; # #     
defb 240  	; ####    
defb 208  	; ## #    
defb 224  	; ###     
defb 240  	; ####    
defb 128  	; #       
defb 192  	; ##      

defb 240  	; ####    
defb 232  	; ### #   
defb 252  	; ######  
defb 244  	; #### #  
defb 248  	; #####   
defb 252  	; ######  
defb 216  	; ## ##   
defb 236  	; ### ##  

defb 60  	;   ####  
defb 126  	;  ###### 
defb 255  	; ########
defb 255  	; ########
defb 255  	; ########
defb 255  	; ########
defb 126  	;  ###### 
defb 231  	; ###  ###

defb 60  	;   ####  
defb 126  	;  ###### 
defb 255  	; ########
defb 255  	; ########
defb 255  	; ########
defb 127  	;  #######
defb 110  	;  ## ### 
defb 7  	;      ###

defb 60  	;   ####  
defb 126  	;  ###### 
defb 255  	; ########
defb 255  	; ########
defb 255  	; ########
defb 255  	; ########
defb 126  	;  ###### 
defb 231  	; ###  ###

defb 60  	;   ####  
defb 126  	;  ###### 
defb 255  	; ########
defb 255  	; ########
defb 255  	; ########
defb 254  	; ####### 
defb 118  	;  ### ## 
defb 224  	; ###     

defb 60  	;   ####  
defb 90  	;  # ## # 
defb 255  	; ########
defb 219  	; ## ## ##
defb 231  	; ###  ###
defb 255  	; ########
defb 126  	;  ###### 
defb 231  	; ###  ###

defb 60  	;   ####  
defb 90  	;  # ## # 
defb 255  	; ########
defb 219  	; ## ## ##
defb 231  	; ###  ###
defb 254  	; ####### 
defb 118  	;  ### ## 
defb 224  	; ###     

defb 60  	;   ####  
defb 90  	;  # ## # 
defb 255  	; ########
defb 219  	; ## ## ##
defb 231  	; ###  ###
defb 255  	; ########
defb 126  	;  ###### 
defb 231  	; ###  ###

defb 60  	;   ####  
defb 90  	;  # ## # 
defb 255  	; ########
defb 219  	; ## ## ##
defb 231  	; ###  ###
defb 127  	;  #######
defb 110  	;  ## ### 
defb 7  	;      ###

defb 60  	;   ####  
defb 122  	;  #### # 
defb 255  	; ########
defb 254  	; ####### 
defb 253  	; ###### #
defb 127  	;  #######
defb 24  	;    ##   
defb 28  	;    ###  

defb 15  	;     ####
defb 30  	;    #### 
defb 63  	;   ######
defb 63  	;   ######
defb 63  	;   ######
defb 31  	;    #####
defb 13  	;     ## #
defb 14  	;     ### 

defb 3  	;       ##
defb 7  	;      ###
defb 15  	;     ####
defb 15  	;     ####
defb 15  	;     ####
defb 7  	;      ###
defb 1  	;        #
defb 1  	;        #

defb 0  	;         
defb 1  	;        #
defb 3  	;       ##
defb 3  	;       ##
defb 3  	;       ##
defb 1  	;        #
defb 0  	;         
defb 0  	;         

defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         
defb 0  	;         

defb 0  	;         
defb 128  	; #       
defb 192  	; ##      
defb 128  	; #       
defb 64  	;  #      
defb 192  	; ##      
defb 128  	; #       
defb 192  	; ##      

defb 192  	; ##      
defb 160  	; # #     
defb 240  	; ####    
defb 224  	; ###     
defb 208  	; ## #    
defb 240  	; ####    
defb 128  	; #       
defb 192  	; ##      

defb 240  	; ####    
defb 232  	; ### #   
defb 252  	; ######  
defb 248  	; #####   
defb 244  	; #### #  
defb 252  	; ######  
defb 216  	; ## ##   
defb 236  	; ### ##  

defb 60  	;   ####  
defb 126  	;  ###### 
defb 255  	; ########
defb 255  	; ########
defb 255  	; ########
defb 255  	; ########
defb 126  	;  ###### 
defb 231  	; ###  ###

defb 60  	;   ####  
defb 126  	;  ###### 
defb 255  	; ########
defb 255  	; ########
defb 255  	; ########
defb 127  	;  #######
defb 110  	;  ## ### 
defb 7  	;      ###

defb 60  	;   ####  
defb 126  	;  ###### 
defb 255  	; ########
defb 255  	; ########
defb 255  	; ########
defb 255  	; ########
defb 126  	;  ###### 
defb 231  	; ###  ###

defb 60  	;   ####  
defb 126  	;  ###### 
defb 255  	; ########
defb 255  	; ########
defb 255  	; ########
defb 254  	; ####### 
defb 118  	;  ### ## 
defb 224  	; ###     

defb 60  	;   ####  
defb 90  	;  # ## # 
defb 255  	; ########
defb 231  	; ###  ###
defb 219  	; ## ## ##
defb 255  	; ########
defb 126  	;  ###### 
defb 231  	; ###  ###

defb 60  	;   ####  
defb 90  	;  # ## # 
defb 255  	; ########
defb 231  	; ###  ###
defb 219  	; ## ## ##
defb 254  	; ####### 
defb 118  	;  ### ## 
defb 224  	; ###     

defb 60  	;   ####  
defb 90  	;  # ## # 
defb 255  	; ########
defb 231  	; ###  ###
defb 219  	; ## ## ##
defb 255  	; ########
defb 126  	;  ###### 
defb 231  	; ###  ###

defb 60  	;   ####  
defb 90  	;  # ## # 
defb 255  	; ########
defb 231  	; ###  ###
defb 219  	; ## ## ##
defb 127  	;  #######
defb 110  	;  ## ### 
defb 7  	;      ###
