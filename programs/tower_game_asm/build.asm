

; input:
;  de - the xy coordinates to scan through build_tile_xys for
; output:
;   a - the build_tile number, or $ff if not found
build_find_build_tile_index:
	; the pointer
	ld hl, (build_tile_xys)
	; the counter
	ld b, 0

build_find_build_tile_index_loop:
	; first check if we hit the end
	ld a, (hl)
	cp $ff
	jp z, build_find_build_tile_index_not_found
	
	; increment hl for y coordinate even if we don't jump
	inc hl

	; then check the x coordinate
	cp d
	jp nz, build_find_build_tile_index_loop_increment

	; then check the y coordinate
	ld a, (hl)
	cp e
	jp nz, build_find_build_tile_index_loop_increment

	; if we get this far, we found the index!
	ld a, b
	ret

build_find_build_tile_index_loop_increment:
	inc hl
	inc b
	jp build_find_build_tile_index_loop

	; if we hit the end, then 
build_find_build_tile_index_not_found:
	ld a, $ff
	ret


; input:
;  b - tens cost to check for
;  c - ones cost to check for
; output:
;  a - 1 if successful, 0 if unsuccessful
; side effect:
;  decrement the player's money by bc
build_try_decrement_money:
	; return if we don't have enough money
	call build_check_money
	cp $00
	ret z

	; if we do have enough money, perform the deduction
	; b was already incremented if we need carry, so don't worry about that
	ld a, (money_tens)
	sub b
	ld (money_tens), a

	; if we did a carry, increment our effective ones by 10
	ld a, (money_ones)
	cp c
	jp p, build_try_decrement_money_no_carry
	add 10

	; actually do the subtraction
build_try_decrement_money_no_carry:
	sub c
	ld (money_ones), a

	; load 1 into a to signal success
	ld a, 1
	ret

; input:
;  b - tens cost to check for
;  c - ones cost to check for
; output:
;  a - 1 if player can afford it, 0 if they cannot
; trashes:
;  b - increments by 1 if needed a carry
build_check_money:
	; check if we need to borrow from tens
	ld a, (money_ones)
	sub c
	jp m, build_check_money_no_borrow
	jp z, build_check_money_no_borrow

	; if we do have to borrow from tens, increment the effective tens cost
	inc b

	; compare the tens
build_check_money_no_borrow:
	; check if we have enough tens
	ld a, (money_tens)
	sub b
	ld a, 0
	; if we do not, return 0
	ret m

	; else, return 1
	ld a, 1
	ret

; inputs:
;  de - the xy coordinates to build at
build_laser_tower:
	ld a, $01
	ld bc, $0100
	call build_build_tower
	ret

; inputs:
;  de - the xy coordinates to build at
build_bomb_tower:
	ld a, $02
	ld bc, $0300
	call build_build_tower
	ret

; inputs:
;  de - the xy coordinates to build at
build_slow_tower:
	ld a, $03
	ld bc, $0500
	call build_build_tower
	ret

; inputs:
;  de - the xy coordinates to build at
build_basic_tower:
	ld a, $04
	ld bc, $0100
	call build_build_tower
	ret


; inputs:
;   a - the tower type byte
;  bc - the cost of the tower
;  de - the xy coordinates to build at
build_build_tower:
	; put the tower type byte in a' until we need it
	ex af, af'

	push bc

	; ensure that this is a valid spot, give up if it isn't
	call build_find_build_tile_index
	cp $ff
	ret z

	pop bc

	; make sure there isn't a tile here already
	; also stash the build tile index in l
	ld hl, build_tile_towers
	ld l, a
	ld a, (hl)
	cp $fe
	ret nz

	; subtract the cost of the tower from our money, give up if we don't have enough
	call build_try_decrement_money
	cp $00
	ret z

	;; now that we've subtracted the money, actually store the tower
	; grab the tile index again and tower type byte again
	ld b, l
	ex af, af'
	; register the new tower in the array
	call build_register_new_tower

	; draw the new tower on the screen
	call build_draw_tower

	ret


; input
;   a - the tower type byte
;  de - the xy coordinate
build_draw_tower:
	; stash the tower type in b
	ld b, a

	; compute the cell address to draw to 
    call cursor_get_cell_addr
	ex de, hl

	; grab the tower type byte
	ld a, b

	; compute the tower type data address
	ld bc, tower_type_data
	sla a
	sla a
	ld c, a

	; load the tower tile
	ld a, (bc)
	ld l, a
	inc bc
	ld a, (bc)
	ld h, a

	; draw the tower tile
    call util_draw_tile

	; load the tower attribute byte
	inc bc
	ld a, (bc)

	; store the tower attribute byte
    ld (cursor_old_attr), a

    ret


; Add new tower of certain type at default rank
; to be recorded in the global towers array
; input:
;  a - the tower type byte
;  b - the tile index
build_register_new_tower:
	; find the point in the array to build at
	ld hl, build_tile_towers
	ld l, b

	; build the tower
	ld (hl), a

    ret

