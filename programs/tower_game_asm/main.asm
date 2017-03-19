org 32768

; this initializes memory in the upper ram chip for handling enemies
; which is needed before the level select screen can work because the
; level select screen has animated enemies
ld bc, $0600
ld hl, $3900
ld de, enemy_position_to_index_array
ldir

call	level_select_setup

title_bypass_load:
	; disable interrupts for the duration of the setup phase
	di

	; setup the interrupt handler
	ld hl, interrupt_handler
	call setup_interrupt_handler

	; call various module init functions
	call main_init
	call load_map_init
    call powerups_init
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
	;ld a, (sub_frame_counter)
	;and 1
	;call nz, music_entry_point

	; update the life and money status on the 2nd visual frame
	ld a, (sub_frame_counter)
	and 3
	cp 2
    call z, status_update_money_life

    ; spawn powerups randomly on the 2nd visual frame
    ld a, (sub_frame_counter)
    and 3
    cp 2
    call z, powerups_spawn_randomly

	; do enemy updates every 8th frame
	ld a, (sub_frame_counter)
	cp 0
	call z, enemy_handler_entry_point_handle_enemies

	; precompute helper array on the first subframe 1 of every cell frame
	ld a, (real_frame_counter)
	and $1f
	cp $01
	call z, enemy_handler_entry_point_compute_position_to_index_array

	; handle tower attacks on the first subframe 3 of every cell frame
	ld a, (real_frame_counter)
	and $1f
	cp $03
	call z, tower_handler_entry_point_handle_attacks

	; clear highlights from tower attacks on the second subframe 3 of every cell frame
	ld a, (real_frame_counter)
	and $1f
	cp $0b
	call z, tower_clear_attack_highlights

	;; only do enemy spawning every other cell frame when the frame_counter is 0
	; and the LSB of cell_counter is 0
	ld a, (real_frame_counter)
	and $3f
	cp $18
	call z, enemy_handler_entry_point_handle_spawn_enemies

	;; also update the enemy status at the same count
	ld a, (real_frame_counter)
	and $3f
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

	ret


; sets up level data to use level a
init_level_a:
	ld hl, enemy_path_xy_a
	ld de, enemy_path_a
	call unpack_vram_addresses

	ld hl, enemy_path_xy_a
	ld de, enemy_path_attr_a
	call unpack_attr_addresses

	; path data
	ld hl, enemy_path_xy_a
	ld (enemy_path_xy), hl
	ld hl, enemy_path_a
	ld (enemy_path), hl
	ld hl, enemy_path_attr_a
	ld (enemy_path_attr), hl
	ld hl, enemy_path_direction_a
	ld (enemy_path_direction), hl
	; build tile data
	ld hl, build_tile_xys_a
	ld (build_tile_xys), hl
	ld hl, build_tile_attackables_a
	ld (build_tile_attackables), hl
	; map tiles
	ld hl, tile_map_a
	ld (tile_map), hl
	; lakes
	ld a, 28
	ld (powerup_one_x), a
	ld a, 2
	ld (powerup_one_y), a
	ld a, 7
	ld (powerup_two_x), a
	ld a, 3
	ld (powerup_two_y), a
	ld a, 14
	ld (powerup_three_x), a
	ld a, 13
	ld (powerup_three_y), a
	ret             

; sets up level data to use level b
init_level_b:
	ld hl, enemy_path_xy_b
	ld de, enemy_path_b
	call unpack_vram_addresses

	ld hl, enemy_path_xy_b
	ld de, enemy_path_attr_b
	call unpack_attr_addresses

	; path data
	ld hl, enemy_path_xy_b
	ld (enemy_path_xy), hl
	ld hl, enemy_path_b
	ld (enemy_path), hl
	ld hl, enemy_path_attr_b
	ld (enemy_path_attr), hl
	ld hl, enemy_path_direction_b
	ld (enemy_path_direction), hl
	; build tile data
	ld hl, build_tile_xys_b
	ld (build_tile_xys), hl
	ld hl, build_tile_attackables_b
	ld (build_tile_attackables), hl
	; map tiles
	ld hl, tile_map_b
	ld (tile_map), hl
	; lakes
	ld a, 6
	ld (powerup_one_x), a
	ld a, 13
	ld (powerup_one_y), a
	; no powerup two
	ld a, $ff
	ld (powerup_two), a
	;ld a, 0
	;ld (powerup_two_x), a
	;ld a, 0
	;ld (powerup_two_y), a
	ld a, 24
	ld (powerup_three_x), a
	ld a, 2
	ld (powerup_three_y), a
	ret             

; sets up level data to use level c
init_level_c:
	ld hl, enemy_path_xy_c
	ld de, enemy_path_c
	call unpack_vram_addresses

	ld hl, enemy_path_xy_c
	ld de, enemy_path_attr_c
	call unpack_attr_addresses

	; path data
	ld hl, enemy_path_xy_c
	ld (enemy_path_xy), hl
	ld hl, enemy_path_c
	ld (enemy_path), hl
	ld hl, enemy_path_attr_c
	ld (enemy_path_attr), hl
	ld hl, enemy_path_direction_c
	ld (enemy_path_direction), hl
	; build tile data
	ld hl, build_tile_xys_c
	ld (build_tile_xys), hl
	ld hl, build_tile_attackables_c
	ld (build_tile_attackables), hl
	; map tiles
	ld hl, tile_map_c
	ld (tile_map), hl
	; lakes
	ld a, 16
	ld (powerup_one_x), a
	ld a, 13
	ld (powerup_one_y), a
	ld a, 3
	ld (powerup_two_x), a
	ld a, 3
	ld (powerup_two_y), a
	ld a, 28
	ld (powerup_three_x), a
	ld a, 2
	ld (powerup_three_y), a
	ret             

; sets up level data to use level d
init_level_d:
	ld hl, enemy_path_xy_d
	ld de, enemy_path_d
	call unpack_vram_addresses

	ld hl, enemy_path_xy_d
	ld de, enemy_path_attr_d
	call unpack_attr_addresses

	; path data
	ld hl, enemy_path_xy_d
	ld (enemy_path_xy), hl
	ld hl, enemy_path_d
	ld (enemy_path), hl
	ld hl, enemy_path_attr_d
	ld (enemy_path_attr), hl
	ld hl, enemy_path_direction_d
	ld (enemy_path_direction), hl
	; build tile data
	ld hl, build_tile_xys_d
	ld (build_tile_xys), hl
	ld hl, build_tile_attackables_d
	ld (build_tile_attackables), hl
	; map tiles
	ld hl, tile_map_d
	ld (tile_map), hl
	; lakes
	ld a, 20
	ld (powerup_one_x), a
	ld a, 13
	ld (powerup_one_y), a
	ld a, 3
	ld (powerup_two_x), a
	ld a, 6
	ld (powerup_two_y), a
	ld a, 28
	ld (powerup_three_x), a
	ld a, 2
	ld (powerup_three_y), a
	ret             


; inputs:
;  hl: the enemy_path_xy pointer to use (xy coordinates)
;  de: the enemy_path_attr pointer to use (attr addresses)
unpack_attr_addresses:
	push ix
	push iy

	ld bc, $02
	push hl
	pop ix
	push de
	pop iy
	
	; skip past the padding 0 coords in the xy coords
	add ix, bc

	; first address is 0
	ld (iy+0), 0
	ld (iy+1), 0
	add iy, bc

	; loop over all coords
unpack_attr_addresses_loop:
	; load the x and y coordinates
	ld d, (ix+0)
	ld e, (ix+1)
	add ix, bc

	ld a, d
	cp $ff
	jp z, unpack_attr_addresses_loop_end

	; compute the attr address
	call cursor_get_cell_attr

	ld (iy+1), h
	ld (iy+0), l
	add iy, bc

	jp unpack_attr_addresses_loop

unpack_attr_addresses_loop_end:
	ld (iy+0), $ff
	ld (iy+1), $ff

	pop iy
	pop ix
	ret

; inputs:
;  hl: the enemy_path_xy pointer to use (xy coordinates)
;  de: the enemy_path pointer to use (vram addresses)
unpack_vram_addresses:
	push ix
	push iy

	ld bc, $02
	push hl
	pop ix
	push de
	pop iy
	
	; skip past the padding 0 coords in the xy coords
	add ix, bc

	; first address is 0
	ld (iy+0), 0
	ld (iy+1), 0
	add iy, bc

	; loop over all coords
unpack_vram_addresses_loop:
	; load the x and y coordinates
	ld d, (ix+0)
	ld e, (ix+1)
	add ix, bc

	ld a, d
	cp $ff
	jp z, unpack_vram_addresses_loop_end

	; compute the vram address
	call cursor_get_cell_addr

	ld (iy+1), h
	ld (iy+0), l
	add iy, bc

	jp unpack_vram_addresses_loop

unpack_vram_addresses_loop_end:
	ld (iy+0), $ff
	ld (iy+1), $ff

	pop iy
	pop ix
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

reset_frame_counters:
	xor		a
	ld		(real_frame_counter), a
	ld		(sub_frame_counter), a
	ld		(frame_counter), a
	ld		(cell_frame_counter), a
	ret

reset_enemy_data:
	; Clear a bunch of enemy data
	; TODO: Since most of these are contiguous
	;		just free up one big block instead of indivs.
	ld		hl, $3900
	ld		de, weak_enemy_position_array
	ld		bc, $0100
	ldir

	ld		hl, $3900
	ld		de, weak_enemy_health_array
	ld		bc, $0100
	ldir
	
	ld		hl, $3900
	ld		de, strong_enemy_position_array
	ld		bc, $0100
	ldir

	ld		hl, $3900
	ld		de, strong_enemy_health_array
	ld		bc, $0100
	ldir

	ld		hl, $3900
	ld		de, enemy_position_to_index_array
	ld		bc, $0100
	ldir
	ret

include "level_select.asm"
include "death.asm"
include "build.asm"
include "cursor.asm"
include "enemy_handler.asm"
include "enemy_sprite.asm"
include "input.asm"
include "load_map.asm"
include "misc.asm"
include "status.asm"
include "tower.asm"
include "util.asm"
include "music.asm"
include "powerups.asm"


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
    defb 1

money_tens:
    defb 5
money_ones:
    defb 0

wave_count:
    defb 1
enemy_count:
    defb 5

zap_charges:
    defb 0
bomb_charges:
    defb 0
slow_charges:
    defb 0

powerup_one:
    defb 0
powerup_one_x:
    defb 0
powerup_one_y:
    defb 0

powerup_two:
    defb 0
powerup_two_x:
    defb 0
powerup_two_y:
    defb 0

powerup_three:
    defb 0
powerup_three_x:
    defb 0
powerup_three_y:
    defb 0

; laser, flame, boost, 'basic' (unused)
tower_byte_ids:
    defb $01, $02, $03, $04

; filler, laser, flame, boost, 'basic' (unused)
tower_buy_price_tens:
    defb $00, $01, $03, $02, $01
tower_buy_price_ones:
    defb $00, $00, $00, $00, $00

; filler, laser, flame, boost, 'basic' (unused)
tower_sell_price_tens:
    defb $00, $00, $01, $01, $00
tower_sell_price_ones:
    defb $00, $05, $05, $00, $05
    

; pixel address:
; [0, 1, 0, y7,  y6, y2, y1, y0] [y5, y4, y3, x7,  x6, x5, x4, x3]
;
; attr address
; [0, 1, 0,  1,  1,  0, y7, y6] [y5, y4, y3, x7, x6, x5, x4, x3]


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
build_tile_xys:
	defw $00
build_tile_attackables:
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

; game state maintained by tower functions
current_tower_index:
	defb $00
current_attacked_enemy_index:
	defb $00
current_attacked_enemy_position:
	defb $00
current_attacked_enemy_value:
	defb $00



defs $9d00 - $

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
	defb $fe
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
	defb $9e00 - $, $ff


defs $9e00 - $

; array of towers built at build tiles
build_tile_towers:
	defs $9e80 - $, $fe
	defb $ff


; dynamic array to store towers in. new towers are added here when they are created
; very first byte is array size in bytes (points to next avail slot, not last elem)
; dont think a terminator needed for this array
; Array elements stored as so:
;		3 bytes total for a single tower
;		x coord, y coord, rank
; Can replace x,y with VRAM if necsesary, or just add more items
; Rank determines where to find that tower's info sheet (refer to tower_type_1_default immediately below for example)
;tower_array:
;	defb $00
;	defb $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
;	defb $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
;	defb $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
;	defb $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
;	defb $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff


; Example of where a rank would vector to. Ranks are 1 byte so high byte would be 98 and rank determines low byte
; would have one of these structures for each tower and each corresponding upgrade
;defs $9c00 - $
;tower_type_1_default:
;	defw tower_basic			; normal sprite sheet addr
;	defw $FFFF					; attack animation sprite sheet addr
;	defb $FF					; damage info
;	defb $FF					; attack speed
;	defb $23					; attr byte for normal sprite bckgnd
;	defb $FF					; unused

defs $9f00 - $

; format:
;   2 - tile address
;   1 - attribute byte
;   1 - x
tower_type_data:
	; filler
	defw $ffff
	defb $ff
	defb $ff
	; laser tower
	defw tower_zap
	defb $27
	defb $ff
	; flame tower
	defw tower_bomb_upgrade
	defb $22
	defb $ff
	; tesla tower
	defw tower_obelisk
	defb $21
	defb $ff
	; basic tower
	defw tower_basic
	defb $23
	defb $ff

; would have tower_type_1_up_1, tower_type_1_up_2, etc... for upgrades

; map data
defs $a000 - $
; 58 bytes
; must be aligned
enemy_path_direction_a:
	defb $00
	defb $00, $00, $00, $00, $03, $03, $03, $03
	defb $00, $00, $00, $00, $00, $00, $00, $00
	defb $02, $02, $02, $02, $02, $02, $00, $00
	defb $00, $00, $00, $00, $00, $00, $03, $03
	defb $03, $03, $03, $03, $03, $03, $03, $00
	defb $00, $00, $00, $00, $00, $00, $00, $02
	defb $02, $02, $02, $02, $00, $00, $00, $00
	defb $ff

; 116 bytes
; unaligned, used to compute enemy_path_a and enemy_path_attr_a
enemy_path_xy_a:
	defb $00, $00
	defb $00, $05, $01, $05, $02, $05, $03, $05
	defb $04, $05, $04, $06, $04, $07, $04, $08
	defb $04, $09, $05, $09, $06, $09, $07, $09
	defb $08, $09, $09, $09, $0a, $09, $0b, $09
	defb $0c, $09, $0c, $08, $0c, $07, $0c, $06
	defb $0c, $05, $0c, $04, $0c, $03, $0d, $03
	defb $0e, $03, $0f, $03, $10, $03, $11, $03
	defb $12, $03, $13, $03, $14, $03, $14, $04
	defb $14, $05, $14, $06, $14, $07, $14, $08
	defb $14, $09, $14, $0a, $14, $0b, $14, $0c
	defb $15, $0c, $16, $0c, $17, $0c, $18, $0c
	defb $19, $0c, $1a, $0c, $1b, $0c, $1c, $0c
	defb $1c, $0b, $1c, $0a, $1c, $09, $1c, $08
	defb $1c, $07, $1d, $07, $1e, $07, $1f, $07
	defb $ff, $ff

defs $a100 - $
; 112 bytes
; must be aligned
build_tile_attackables_a:
	defb $1b, $ff, $ff, $ff
	defb $1d, $ff, $ff, $ff
	defb $21, $ff, $ff, $ff
	defb $16, $ff, $ff, $ff
	defb $1a, $16, $ff, $ff
	defb $1c, $ff, $ff, $ff
	defb $22, $1e, $ff, $ff
	defb $22, $ff, $ff, $ff
	defb $37, $ff, $ff, $ff
	defb $23, $ff, $ff, $ff
	defb $08, $04, $ff, $ff
	defb $0c, $08, $ff, $ff
	defb $0e, $ff, $ff, $ff
	defb $14, $10, $ff, $ff
	defb $14, $ff, $ff, $ff
	defb $24, $ff, $ff, $ff
	defb $25, $ff, $ff, $ff
	defb $35, $ff, $ff, $ff
	defb $26, $ff, $ff, $ff
	defb $38, $34, $ff, $ff
	defb $2b, $27, $ff, $ff
	defb $2d, $ff, $ff, $ff
	defb $33, $2f, $ff, $ff
	defb $0d, $ff, $ff, $ff
	defb $0f, $ff, $ff, $ff
	defb $32, $ff, $ff, $ff
	defb $2c, $ff, $ff, $ff
	defb $2e, $ff, $ff, $ff

; 58 bytes
; unaligned
build_tile_xys_a:
	defb $0f, $01
	defb $11, $01
	defb $16, $04
	defb $0a, $05
	defb $0e, $05
	defb $10, $05
	defb $12, $05
	defb $16, $05
	defb $1d, $05
	defb $16, $06
	defb $02, $07
	defb $06, $07
	defb $08, $07
	defb $0a, $07
	defb $0e, $07
	defb $12, $07
	defb $16, $08
	defb $1a, $08
	defb $12, $09
	defb $1e, $09
	defb $16, $0a
	defb $18, $0a
	defb $1a, $0a
	defb $07, $0b
	defb $09, $0b
	defb $1e, $0b
	defb $17, $0e
	defb $19, $0e
	defb $ff, $ff

defs $a200 - $
; 256 bytes
; must be aligned
tile_map_a:
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $21, $21, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $28, $44, $44, $44, $44, $49, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $26, $00, $00, $00, $00, $07, $22, $22, $22, $22, $22
	defb $44, $44, $49, $22, $22, $26, $0f, $55, $55, $5e, $07, $12, $22, $22, $22, $22
	defb $00, $00, $07, $22, $22, $16, $07, $12, $12, $16, $07, $12, $22, $22, $21, $22
	defb $55, $5e, $07, $22, $22, $26, $07, $22, $22, $26, $07, $12, $22, $28, $44, $44
	defb $22, $16, $07, $12, $12, $16, $07, $12, $22, $16, $07, $22, $22, $26, $00, $00
	defb $22, $26, $0d, $44, $44, $4c, $07, $22, $22, $26, $07, $12, $22, $16, $0f, $55
	defb $22, $26, $00, $00, $00, $00, $07, $22, $22, $16, $07, $22, $22, $26, $07, $12
	defb $22, $2a, $55, $55, $55, $55, $5b, $22, $22, $26, $07, $12, $12, $16, $07, $22
	defb $22, $22, $22, $21, $21, $22, $22, $22, $22, $26, $0d, $44, $44, $4c, $07, $12
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $26, $00, $00, $00, $00, $07, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $2a, $55, $55, $55, $55, $5b, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $21, $21, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22


defs $a300 - $
; 34 bytes
; must be aligned
enemy_path_direction_b:
	defb $00
	defb $00, $00, $00, $00, $00, $00, $00, $00
	defb $00, $00, $00, $00, $00, $00, $00, $00
	defb $00, $00, $00, $00, $00, $00, $00, $00
	defb $00, $00, $00, $00, $00, $00, $00, $00
	defb $ff

; 68 bytes
; unaligned, used to compute enemy_path_b and enemy_path_attr_b
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

defs $a400 - $
; 64 bytes
; must be aligned
build_tile_attackables_b:
	defb $04, $ff, $ff, $ff
	defb $0a, $ff, $ff, $ff
	defb $0e, $ff, $ff, $ff
	defb $10, $ff, $ff, $ff
	defb $12, $ff, $ff, $ff
	defb $14, $ff, $ff, $ff
	defb $16, $ff, $ff, $ff
	defb $1c, $ff, $ff, $ff
	defb $07, $ff, $ff, $ff
	defb $0d, $ff, $ff, $ff
	defb $0f, $ff, $ff, $ff
	defb $11, $ff, $ff, $ff
	defb $13, $ff, $ff, $ff
	defb $15, $ff, $ff, $ff
	defb $19, $ff, $ff, $ff
	defb $1f, $ff, $ff, $ff

; 34 bytes
; unaligned
build_tile_xys_b:
	defb $02, $05
	defb $08, $05
	defb $0c, $05
	defb $0e, $05
	defb $10, $05
	defb $12, $05
	defb $14, $05
	defb $1a, $05
	defb $05, $09
	defb $0b, $09
	defb $0d, $09
	defb $0f, $09
	defb $11, $09
	defb $13, $09
	defb $17, $09
	defb $1d, $09
	defb $ff, $ff

defs $a500 - $
; 256 bytes
; must be aligned
tile_map_b:
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $12, $22, $22, $12, $22, $12, $12, $12, $12, $12, $22, $22, $12, $22, $22
	defb $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44
	defb $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	defb $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55
	defb $22, $22, $21, $22, $22, $21, $21, $21, $21, $21, $22, $21, $22, $22, $21, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22


defs $a600 - $
; 44 bytes
; must be aligned
enemy_path_direction_c:
	defb $00
	defb $00, $00, $00, $00, $00, $00, $00, $00
	defb $00, $00, $00, $00, $02, $02, $02, $02
	defb $02, $00, $00, $00, $00, $00, $00, $00
	defb $00, $03, $03, $03, $03, $03, $00, $00
	defb $00, $00, $00, $00, $00, $00, $00, $00
	defb $00, $00
	defb $ff

; 88 bytes
; unaligned, used to compute enemy_path_c and enemy_path_attr_c
enemy_path_xy_c:
	defb $00, $00
	defb $00, $0a, $01, $0a, $02, $0a, $03, $0a
	defb $04, $0a, $05, $0a, $06, $0a, $07, $0a
	defb $08, $0a, $09, $0a, $0a, $0a, $0b, $0a
	defb $0c, $0a, $0c, $09, $0c, $08, $0c, $07
	defb $0c, $06, $0c, $05, $0d, $05, $0e, $05
	defb $0f, $05, $10, $05, $11, $05, $12, $05
	defb $13, $05, $14, $05, $14, $06, $14, $07
	defb $14, $08, $14, $09, $14, $0a, $15, $0a
	defb $16, $0a, $17, $0a, $18, $0a, $19, $0a
	defb $1a, $0a, $1b, $0a, $1c, $0a, $1d, $0a
	defb $1e, $0a, $1f, $0a
	defb $ff, $ff

defs $a700 - $
; 92 bytes
; must be aligned
build_tile_attackables_c:
	defb $14, $ff, $ff, $ff
	defb $16, $ff, $ff, $ff
	defb $18, $ff, $ff, $ff
	defb $1a, $ff, $ff, $ff
	defb $12, $ff, $ff, $ff
	defb $1c, $ff, $ff, $ff
	defb $15, $11, $ff, $ff
	defb $17, $ff, $ff, $ff
	defb $1d, $19, $ff, $ff
	defb $08, $ff, $ff, $ff
	defb $0a, $ff, $ff, $ff
	defb $10, $0c, $ff, $ff
	defb $22, $1e, $ff, $ff
	defb $24, $ff, $ff, $ff
	defb $26, $ff, $ff, $ff
	defb $0f, $ff, $ff, $ff
	defb $1f, $ff, $ff, $ff
	defb $07, $ff, $ff, $ff
	defb $09, $ff, $ff, $ff
	defb $0b, $ff, $ff, $ff
	defb $23, $ff, $ff, $ff
	defb $25, $ff, $ff, $ff
	defb $27, $ff, $ff, $ff

; 48 bytes
; unaligned
build_tile_xys_c:
	defb $0d, $03
	defb $0f, $03
	defb $11, $03
	defb $13, $03
	defb $0a, $06
	defb $16, $06
	defb $0e, $07
	defb $10, $07
	defb $12, $07
	defb $06, $08
	defb $08, $08
	defb $0a, $08
	defb $16, $08
	defb $18, $08
	defb $1a, $08
	defb $0e, $09
	defb $12, $09
	defb $05, $0c
	defb $07, $0c
	defb $09, $0c
	defb $17, $0c
	defb $19, $0c
	defb $1b, $0c
	defb $ff, $ff

defs $a800 - $
; 256 bytes
; must be aligned
tile_map_c:
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $21, $21, $21, $21, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $28, $44, $44, $44, $44, $49, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $26, $00, $00, $00, $00, $07, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $16, $0f, $55, $55, $5e, $07, $12, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $26, $07, $12, $12, $16, $07, $22, $22, $22, $22, $22
	defb $22, $22, $22, $12, $12, $16, $07, $22, $22, $26, $07, $12, $12, $12, $22, $22
	defb $44, $44, $44, $44, $44, $4c, $07, $12, $22, $16, $0d, $44, $44, $44, $44, $44
	defb $00, $00, $00, $00, $00, $00, $07, $22, $22, $26, $00, $00, $00, $00, $00, $00
	defb $55, $55, $55, $55, $55, $55, $5b, $22, $22, $2a, $55, $55, $55, $55, $55, $55
	defb $22, $22, $21, $21, $21, $22, $22, $22, $22, $22, $22, $21, $21, $21, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22


defs $a900 - $
; 44 bytes
; must be aligned
enemy_path_direction_d:
	defb $03
	defb $03, $03, $03, $03, $03, $03, $03, $03
	defb $03, $03, $00, $00, $00, $00, $00, $00
	defb $00, $00, $02, $02, $02, $02, $02, $00
	defb $00, $00, $00, $00, $00, $00, $00, $03
	defb $03, $03, $03, $03, $03, $03, $03, $03
	defb $03, $03
	defb $ff

; 88 bytes
; unaligned, used to compute enemy_path_d and enemy_path_attr_d
enemy_path_xy_d:
	defb $00, $00
	defb $08, $00, $08, $01, $08, $02, $08, $03
	defb $08, $04, $08, $05, $08, $06, $08, $07
	defb $08, $08, $08, $09, $08, $0a, $09, $0a
	defb $0a, $0a, $0b, $0a, $0c, $0a, $0d, $0a
	defb $0e, $0a, $0f, $0a, $10, $0a, $10, $09
	defb $10, $08, $10, $07, $10, $06, $10, $05
	defb $11, $05, $12, $05, $13, $05, $14, $05
	defb $15, $05, $16, $05, $17, $05, $18, $05
	defb $18, $06, $18, $07, $18, $08, $18, $09
	defb $18, $0a, $18, $0b, $18, $0c, $18, $0d
	defb $18, $0e, $18, $0f
	defb $ff, $ff

defs $aa00 - $
; 96 bytes
; must be aligned
build_tile_attackables_d:
	defb $1a, $ff, $ff, $ff
	defb $1c, $ff, $ff, $ff
	defb $1e, $ff, $ff, $ff
	defb $20, $ff, $ff, $ff
	defb $07, $ff, $ff, $ff
	defb $08, $ff, $ff, $ff
	defb $18, $ff, $ff, $ff
	defb $22, $ff, $ff, $ff
	defb $09, $ff, $ff, $ff
	defb $1b, $17, $ff, $ff
	defb $1d, $ff, $ff, $ff
	defb $23, $1f, $ff, $ff
	defb $0e, $0a, $ff, $ff
	defb $10, $ff, $ff, $ff
	defb $16, $12, $ff, $ff
	defb $24, $ff, $ff, $ff
	defb $0b, $ff, $ff, $ff
	defb $15, $ff, $ff, $ff
	defb $25, $ff, $ff, $ff
	defb $26, $ff, $ff, $ff
	defb $0d, $ff, $ff, $ff
	defb $0f, $ff, $ff, $ff
	defb $11, $ff, $ff, $ff
	defb $13, $ff, $ff, $ff

; 50 bytes
; unaligned
build_tile_xys_d:
	defb $11, $03
	defb $13, $03
	defb $15, $03
	defb $17, $03
	defb $06, $05
	defb $0a, $06
	defb $0e, $06
	defb $1a, $06
	defb $06, $07
	defb $12, $07
	defb $14, $07
	defb $16, $07
	defb $0a, $08
	defb $0c, $08
	defb $0e, $08
	defb $1a, $08
	defb $06, $09
	defb $12, $09
	defb $16, $09
	defb $1a, $0a
	defb $09, $0c
	defb $0b, $0c
	defb $0d, $0c
	defb $0f, $0c
	defb $ff, $ff

defs $ab00 - $
; 256 bytes
; must be aligned
tile_map_d:
	defb $22, $22, $22, $26, $07, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $26, $07, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $26, $07, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $26, $07, $22, $22, $22, $21, $21, $21, $21, $22, $22, $22, $22
	defb $22, $22, $22, $26, $07, $22, $22, $28, $44, $44, $44, $44, $49, $22, $22, $22
	defb $22, $22, $22, $16, $07, $22, $22, $26, $00, $00, $00, $00, $07, $22, $22, $22
	defb $22, $22, $22, $26, $07, $12, $22, $16, $0f, $55, $55, $5e, $07, $12, $22, $22
	defb $22, $22, $22, $16, $07, $22, $22, $26, $07, $12, $12, $16, $07, $22, $22, $22
	defb $22, $22, $22, $26, $07, $12, $12, $16, $07, $22, $22, $26, $07, $12, $22, $22
	defb $22, $22, $22, $16, $0d, $44, $44, $4c, $07, $12, $22, $16, $07, $22, $22, $22
	defb $22, $22, $22, $26, $00, $00, $00, $00, $07, $22, $22, $26, $07, $12, $22, $22
	defb $22, $22, $22, $2a, $55, $55, $55, $55, $5b, $22, $22, $26, $07, $22, $22, $22
	defb $22, $22, $22, $22, $21, $21, $21, $21, $22, $22, $22, $26, $07, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $26, $07, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $26, $07, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $26, $07, $22, $22, $22


; tile lookup data
defs $b000 - $

lookup:
	defw blank_tile, build_tile_b, filled_tile, cross_tile
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

buildable_tile:
	defb $ff    ; ########
	defb $bd    ; # #### #
	defb $ff    ; ########
	defb $ff    ; ########
	defb $ff    ; ########
	defb $ff    ; ########
	defb $bd    ; # #### #
	defb $ff    ; ########

build_tile:
	defb $81    ; #      #
	defb $00    ;         
	defb $24    ;   #  #  
	defb $00    ;         
	defb $00    ;         
	defb $24    ;   #  #  
	defb $00    ;         
	defb $81    ; #      #

build_tile_b:
	defb $ff    ; ########
	defb $c3    ; ##    ##
	defb $a5    ; # #  # #
	defb $81    ; #      #
	defb $81    ; #      #
	defb $a5    ; # #  # #
	defb $c3    ; ##    ##
	defb $ff    ; ########

lake_3x3:
    defb $ff    ; ########
    defb $ff    ; ########
    defb $fe    ; ####### 
    defb $fe    ; ####### 
    defb $ec    ; ### ##  
    defb $e3    ; ###   ##
    defb $e0    ; ###     
    defb $c0    ; ##      

    defb $ff    ; ########
    defb $ef    ; ### ####
    defb $71    ;  ###   #
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         

    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $3f    ;   ######
    defb $3f    ;   ######
    defb $2f    ;   # ####
    defb $1f    ;    #####

    defb $c0    ; ##      
    defb $c0    ; ##      
    defb $c0    ; ##      
    defb $e0    ; ###     
    defb $80    ; #       
    defb $00    ;         
    defb $80    ; #       
    defb $80    ; #       

    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         

    defb $0f    ;     ####
    defb $0f    ;     ####
    defb $0f    ;     ####
    defb $1f    ;    #####
    defb $07    ;      ###
    defb $07    ;      ###
    defb $0f    ;     ####
    defb $0f    ;     ####

    defb $00    ;         
    defb $c0    ; ##      
    defb $f0    ; ####    
    defb $f8    ; #####   
    defb $f4    ; #### #  
    defb $fe    ; ####### 
    defb $ff    ; ########
    defb $ff    ; ########

    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $21    ;   #    #
    defb $7e    ;  ###### 
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########

    defb $0f    ;     ####
    defb $5f    ;  # #####
    defb $3f    ;   ######
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########

lake_5x3:
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $f4    ; #### #  
    defb $f8    ; #####   

    defb $ff    ; ########
    defb $fc    ; ######  
    defb $20    ;   #     
    defb $40    ;  #      
    defb $80    ; #       
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         

    defb $03    ;       ##
    defb $01    ;        #
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         

    defb $ff    ; ########
    defb $ff    ; ########
    defb $fb    ; ##### ##
    defb $53    ;  # #  ##
    defb $01    ;        #
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         

    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ef    ; ### ####
    defb $df    ; ## #####
    defb $0b    ;     # ##
    defb $0b    ;     # ##
    defb $07    ;      ###

    defb $f0    ; ####    
    defb $f0    ; ####    
    defb $e0    ; ###     
    defb $c0    ; ##      
    defb $e0    ; ###     
    defb $e0    ; ###     
    defb $e0    ; ###     
    defb $d0    ; ## #    

    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         

    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         

    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         

    defb $03    ;       ##
    defb $03    ;       ##
    defb $03    ;       ##
    defb $07    ;      ###
    defb $07    ;      ###
    defb $2f    ;   # ####
    defb $1f    ;    #####
    defb $1f    ;    #####

    defb $f0    ; ####    
    defb $e8    ; ### #   
    defb $d8    ; ## ##   
    defb $fd    ; ###### #
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########

    defb $00    ;         
    defb $00    ;         
    defb $01    ;        #
    defb $00    ;         
    defb $84    ; #    #  
    defb $5f    ;  # #####
    defb $ff    ; ########
    defb $ff    ; ########

    defb $00    ;         
    defb $00    ;         
    defb $9e    ; #  #### 
    defb $6f    ;  ## ####
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########

    defb $00    ;         
    defb $07    ;      ###
    defb $0f    ;     ####
    defb $37    ;   ## ###
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########

    defb $3f    ;   ######
    defb $7f    ;  #######
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########

lake_3x5:
    defb $ff    ; ########
    defb $ff    ; ########
    defb $fe    ; ####### 
    defb $ff    ; ########
    defb $fd    ; ###### #
    defb $fe    ; ####### 
    defb $f4    ; #### #  
    defb $d0    ; ## #    

    defb $ff    ; ########
    defb $ff    ; ########
    defb $8d    ; #   ## #
    defb $03    ;       ##
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         

    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $3f    ;   ######
    defb $ff    ; ########
    defb $3f    ;   ######
    defb $33    ;   ##  ##
    defb $1b    ;    ## ##

    defb $a0    ; # #     
    defb $a0    ; # #     
    defb $c0    ; ##      
    defb $e0    ; ###     
    defb $e0    ; ###     
    defb $e0    ; ###     
    defb $c0    ; ##      
    defb $c0    ; ##      

    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         

    defb $0f    ;     ####
    defb $0f    ;     ####
    defb $0b    ;     # ##
    defb $07    ;      ###
    defb $0f    ;     ####
    defb $1f    ;    #####
    defb $3f    ;   ######
    defb $3f    ;   ######

    defb $c0    ; ##      
    defb $e0    ; ###     
    defb $c0    ; ##      
    defb $e0    ; ###     
    defb $f0    ; ####    
    defb $f0    ; ####    
    defb $f8    ; #####   
    defb $f8    ; #####   

    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         

    defb $3f    ;   ######
    defb $2f    ;   # ####
    defb $3f    ;   ######
    defb $17    ;    # ###
    defb $0f    ;     ####
    defb $0f    ;     ####
    defb $07    ;      ###
    defb $05    ;      # #

    defb $f8    ; #####   
    defb $f8    ; #####   
    defb $f4    ; #### #  
    defb $f4    ; #### #  
    defb $fc    ; ######  
    defb $fc    ; ######  
    defb $fa    ; ##### # 
    defb $fe    ; ####### 

    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         
    defb $00    ;         

    defb $05    ;      # #
    defb $03    ;       ##
    defb $03    ;       ##
    defb $0b    ;     # ##
    defb $17    ;    # ###
    defb $0f    ;     ####
    defb $0f    ;     ####
    defb $0f    ;     ####

    defb $ff    ; ########
    defb $fe    ; ####### 
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########

    defb $00    ;         
    defb $80    ; #       
    defb $40    ;  #      
    defb $f8    ; #####   
    defb $fe    ; ####### 
    defb $fd    ; ###### #
    defb $ff    ; ########
    defb $ff    ; ########

    defb $07    ;      ###
    defb $07    ;      ###
    defb $0f    ;     ####
    defb $0f    ;     ####
    defb $3f    ;   ######
    defb $ff    ; ########
    defb $ff    ; ########
    defb $ff    ; ########

tower_basic:
    defb 90     ;  # ## #
    defb 255    ; ########
    defb 126    ;  ######
    defb 60     ;   ####
    defb 60     ;   ####
    defb 60     ;   ####
    defb 60     ;   ####
    defb 60     ;   ####

tower_basic_upgrade:
    defb 165    ; # #  # #
    defb 255    ; ########
    defb 219    ; ## ## ##
    defb 255    ; ########
    defb 126    ;  ######
    defb 60     ;   ####
    defb 60     ;   ####
    defb 60     ;   ####

tower_bomb:
    defb 255    ; ########
    defb 129    ; #      #
    defb 153    ; #  ##  #
    defb 165    ; # #  # #
    defb 165    ; # #  # #
    defb 153    ; #  ##  #
    defb 129    ; #      #
    defb 255    ; ########

tower_bomb_upgrade:
    defb 60     ;   ####
    defb 36     ;   #  #
    defb 219    ; ## ## ##
    defb 165    ; # #  # #
    defb 165    ; # #  # #
    defb 219    ; ## ## ##
    defb 36     ;   #  #
    defb 60     ;   ####

tower_zap:
    defb 60     ;   ####
    defb 66     ;  #    #
    defb 66     ;  #    #
    defb 60     ;   ####
    defb 24     ;    ##
    defb 24     ;    ##
    defb 24     ;    ##
    defb 24     ;    ##

tower_zap_upgrade:
    defb 126    ;  ######
    defb 129    ; #      #
    defb 129    ; #      #
    defb 129    ; #      #
    defb 126    ;   ######
    defb 60     ;   ####
    defb 24     ;    ##
    defb 24     ;    ##

tower_obelisk:
    defb 24     ;    ##   
    defb 60     ;   ####  
    defb 60     ;   ####  
    defb 60     ;   ####  
    defb 60     ;   ####  
    defb 126    ;  ###### 
    defb 255    ; ########
    defb 255    ; ########

tower_obelisk_upgrade:
    defb 60     ;   #### 
    defb 36     ;   #  #  
    defb 102    ;  ##  ## 
    defb 66     ;  #    # 
    defb 66     ;  #    # 
    defb 66     ;  #    # 
    defb 195    ; ##    ##
    defb 255    ; ########

up_arrow:    
    defb 24  	;    ##   
    defb 60  	;   ####  
    defb 126  	;  ###### 
    defb 255  	; ########
    defb 60  	;   ####  
    defb 60  	;   ####  
    defb 60  	;   ####  
    defb 60  	;   ####  

lightning:
    defb 3  	;       ##
    defb 14  	;     ### 
    defb 56  	;   ###   
    defb 254  	; ####### 
    defb 127  	;  #######
    defb 28  	;    ###  
    defb 112  	;  ###    
    defb 192  	; ##      

snowflake:
    defb 20  	;    # #  
    defb 8  	;     #   
    defb 93  	;  # ### #
    defb 54  	;   ## ## 
    defb 93  	;  # ### #
    defb 8  	;     #   
    defb 20  	;    # #  
    defb 0  	;         

bomb:
    defb 14  	;     ### 
    defb 17  	;    #   #
    defb 60  	;   ####  
    defb 126  	;  ###### 
    defb 126  	;  ###### 
    defb 126  	;  ###### 
    defb 126  	;  ###### 
    defb 60  	;   ####  

dollar:
    defb 8  	;     #   
    defb 62  	;   ##### 
    defb 40  	;   # #   
    defb 62  	;   ##### 
    defb 10  	;     # # 
    defb 62  	;   ##### 
    defb 8  	;     #   
    defb 0  	;         

heart:
    defb 0  	;         
    defb 102  	;  ##  ## 
    defb 255  	; ########
    defb 255  	; ########
    defb 255  	; ########
    defb 126  	;  ###### 
    defb 60  	;   ####  
    defb 24  	;    ##   

; pad so enemy sprites are aligned
defs $b400 - $

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
defs $b500 - $

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


defs $b600 - $
loading_screen_map:
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44, $44
	defb $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00	
	defb $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	defb $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55, $55
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	defb $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22

loading_screen_map_attrs:
	defw $0000
	defw $5a60, $5a61, $5a62, $5a63, $5a64, $5a65, $5a66, $5a67
	defw $5a68, $5a69, $5a6a, $5a6b, $5a6c, $5a6d, $5a6e, $5a6f
	defw $5a70, $5a71, $5a72, $5a73, $5a74, $5a75, $5a76, $5a77
	defw $5a78, $5a79, $5a7a, $5a7b, $5a7c, $5a7d, $5a7e, $5a7f

	defw $5a80, $5a81, $5a82, $5a83, $5a84, $5a85, $5a86, $5a87
	defw $5a88, $5a89, $5a8a, $5a8b, $5a8c, $5a8d, $5a8e, $5a8f
	defw $5a90, $5a91, $5a92, $5a93, $5a94, $5a95, $5a96, $5a97
	defw $5a98, $5a99, $5a9a, $5a9b, $5a9c, $5a9d, $5a9e, $5a9f
	defw $ffff

; TODO:
;		Make another enemy line on the botttom :)
;		self-modify code to avoid border turning red
defs $b800 - $
titlefont_data:
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0


	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0


	defb 0
	defb 0
	defb 0
	defb 63
	defb 63
	defb 63
	defb 63
	defb 63


	defb 0
	defb 0
	defb 0
	defb 252
	defb 252
	defb 252
	defb 3
	defb 3


	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 128
	defb 128


	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0


	defb 31
	defb 31
	defb 31
	defb 31
	defb 31
	defb 31
	defb 31
	defb 31


	defb 255
	defb 255
	defb 255
	defb 128
	defb 128
	defb 128
	defb 128
	defb 128


	defb 192
	defb 192
	defb 192
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0


	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0


	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0


	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0


	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0


	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0


	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0


	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0


	defb 0
	defb 31
	defb 31
	defb 31
	defb 0
	defb 0
	defb 0
	defb 3


	defb 0
	defb 254
	defb 254
	defb 254
	defb 126
	defb 126
	defb 126
	defb 240


	defb 63
	defb 63
	defb 63
	defb 63
	defb 63
	defb 63
	defb 63
	defb 63


	defb 3
	defb 3
	defb 3
	defb 3
	defb 3
	defb 3
	defb 3
	defb 3


	defb 128
	defb 143
	defb 143
	defb 143
	defb 143
	defb 143
	defb 143
	defb 143


	defb 0
	defb 255
	defb 255
	defb 255
	defb 192
	defb 192
	defb 192
	defb 248


	defb 31
	defb 31
	defb 31
	defb 31
	defb 31
	defb 31
	defb 31
	defb 31


	defb 128
	defb 241
	defb 241
	defb 241
	defb 129
	defb 129
	defb 129
	defb 129


	defb 0
	defb 255
	defb 255
	defb 255
	defb 248
	defb 248
	defb 248
	defb 255


	defb 0
	defb 227
	defb 227
	defb 227
	defb 3
	defb 3
	defb 3
	defb 3


	defb 0
	defb 240
	defb 240
	defb 240
	defb 254
	defb 254
	defb 254
	defb 241


	defb 0
	defb 56
	defb 56
	defb 56
	defb 56
	defb 56
	defb 56
	defb 248


	defb 0
	defb 255
	defb 255
	defb 255
	defb 252
	defb 252
	defb 252
	defb 255


	defb 0
	defb 241
	defb 241
	defb 241
	defb 1
	defb 1
	defb 1
	defb 241


	defb 0
	defb 255
	defb 255
	defb 255
	defb 254
	defb 254
	defb 254
	defb 255


	defb 0
	defb 248
	defb 248
	defb 248
	defb 0
	defb 0
	defb 0
	defb 192

halfway:

	defb 3
	defb 3
	defb 31
	defb 31
	defb 31
	defb 31
	defb 31
	defb 31


	defb 240
	defb 240
	defb 128
	defb 128
	defb 128
	defb 254
	defb 254
	defb 254


	defb 63
	defb 63
	defb 63
	defb 63
	defb 63
	defb 63
	defb 63
	defb 63


	defb 3
	defb 3
	defb 3
	defb 3
	defb 3
	defb 252
	defb 252
	defb 252


	defb 143
	defb 143
	defb 143
	defb 143
	defb 143
	defb 15
	defb 15
	defb 15


	defb 248
	defb 248
	defb 192
	defb 192
	defb 192
	defb 255
	defb 255
	defb 255


	defb 31
	defb 31
	defb 31
	defb 31
	defb 31
	defb 31
	defb 31
	defb 31


	defb 129
	defb 129
	defb 129
	defb 129
	defb 129
	defb 129
	defb 129
	defb 129


	defb 255
	defb 255
	defb 248
	defb 248
	defb 248
	defb 255
	defb 255
	defb 255


	defb 3
	defb 3
	defb 3
	defb 3
	defb 3
	defb 227
	defb 227
	defb 227


	defb 241
	defb 241
	defb 240
	defb 240
	defb 240
	defb 240
	defb 240
	defb 240


	defb 248
	defb 248
	defb 56
	defb 56
	defb 56
	defb 56
	defb 56
	defb 56


	defb 255
	defb 255
	defb 3
	defb 3
	defb 3
	defb 255
	defb 255
	defb 255


	defb 241
	defb 241
	defb 241
	defb 241
	defb 241
	defb 241
	defb 241
	defb 241


	defb 255
	defb 255
	defb 254
	defb 254
	defb 254
	defb 255
	defb 255
	defb 255


	defb 192
	defb 192
	defb 0
	defb 0
	defb 0
	defb 240
	defb 240
	defb 240


















; t_tile_topleft:
; 	defb 0 ; y = 0
; 	defb 0 ; y = 1
; 	defb 63 ; y = 2
; 	defb 63 ; y = 3
; 	defb 63 ; y = 4
; 	defb 3 ; y = 5
; 	defb 3 ; y = 6
; 	defb 3 ; y = 7
; t_tile_topright:
; 	defb 0 ; y = 0
; 	defb 0 ; y = 1
; 	defb 252 ; y = 2
; 	defb 252 ; y = 3
; 	defb 252 ; y = 4
; 	defb 192 ; y = 5
; 	defb 192 ; y = 6
; 	defb 192 ; y = 7
; t_tile_bottomleft:
; 	defb 192 ; y = 0
; 	defb 192 ; y = 1
; 	defb 192 ; y = 2
; 	defb 192 ; y = 3
; 	defb 192 ; y = 4
; 	defb 192 ; y = 5
; 	defb 192 ; y = 6
; 	defb 0 ; y = 7
; t_tile_bottomright:
; 	defb 3 ; y = 0
; 	defb 3 ; y = 1
; 	defb 3 ; y = 2
; 	defb 3 ; y = 3
; 	defb 3 ; y = 4
; 	defb 3 ; y = 5
; 	defb 3 ; y = 6
; 	defb 0 ; y = 7

; h_tile_topleft:
; 	defb 0 ; y = 0
; 	defb 0 ; y = 1
; 	defb 28 ; y = 2
; 	defb 28 ; y = 3
; 	defb 28 ; y = 4
; 	defb 28 ; y = 5
; 	defb 31 ; y = 6
; 	defb 31 ; y = 7
; h_tile_topright:
; 	defb 0 ; y = 0
; 	defb 0 ; y = 1
; 	defb 56 ; y = 2
; 	defb 56 ; y = 3
; 	defb 56 ; y = 4
; 	defb 56 ; y = 5
; 	defb 248 ; y = 6
; 	defb 248 ; y = 7
; h_tile_bottomleft:
; 	defb 248 ; y = 0
; 	defb 248 ; y = 1
; 	defb 56 ; y = 2
; 	defb 56 ; y = 3
; 	defb 56 ; y = 4
; 	defb 56 ; y = 5
; 	defb 56 ; y = 6
; 	defb 0 ; y = 7
; h_tile_bottomright:
; 	defb 31 ; y = 0
; 	defb 31 ; y = 1
; 	defb 28 ; y = 2
; 	defb 28 ; y = 3
; 	defb 28 ; y = 4
; 	defb 28 ; y = 5
; 	defb 28 ; y = 6
; 	defb 0 ; y = 7


; filler labels to load into passed the tape boundary

org $c000
enemy_path_a:

org $c080
enemy_path_attr_a:

org $c100
enemy_path_b:

org $c180
enemy_path_attr_b:

org $c200
enemy_path_c:

org $c280
enemy_path_attr_c:

org $c300
enemy_path_d:

org $c380
enemy_path_attr_d:

org $d000
; position -> index
enemy_position_to_index_array:

org $d100
; dynamic arrays of enemy state
; each array takes up a full memory page
; id / index -> position
weak_enemy_position_array:

org $d200
; id / index -> health
weak_enemy_health_array:

org $d300
strong_enemy_position_array:

org $d400
strong_enemy_health_array:
