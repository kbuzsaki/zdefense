

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
	jp nc, build_check_money_no_borrow

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
	ld a, (tower_byte_ids+0)
	call build_build_tower
	ret

; inputs:
;  de - the xy coordinates to build at
build_bomb_tower:
	ld a, (tower_byte_ids+1)
	call build_build_tower
	ret

; inputs:
;  de - the xy coordinates to build at
build_slow_tower:
	ld a, (tower_byte_ids+2)
	call build_build_tower
	ret

; inputs:
;  de - the xy coordinates to build at
build_basic_tower:
	ld a, (tower_byte_ids+3)
	call build_build_tower
	ret


; inputs:
;   a - the tower type byte (aka its ID)
;  de - the xy coordinates to build at
build_build_tower:
	; save two copies of the tower type byte to the stack
    push af
    push af

	; ensure that this is a valid spot, give up if it isn't
	call build_find_build_tile_index
	cp $ff
	jp z, build_build_tower_end_cleanup

	; make sure there isn't a tile here already
	; also store the build tile index in l
	ld hl, build_tile_towers
	ld l, a
	ld a, (hl)
	cp $fe
	jp nz, build_build_tower_end_cleanup

    pop af ; recover tower type id, its our index into tower_costs

    push hl

    ; get the tower cost and store into bc
    ld c, a ; copy tower byte id into c
    ld hl, tower_buy_price_tens
    add a, l
    ld l, a
    ld b, (hl)

    ld a, c ; load tower byte id from c
    ld hl, tower_buy_price_ones
    add a, l
    ld l, a
    ld c, (hl)

    pop hl

	; subtract the cost of the tower from our money, give up if we don't have enough
	call build_try_decrement_money
	cp $00
	ret z

	;; now that we've subtracted the money, actually store the tower
	; grab the tile index again and tower type byte again
	ld b, l
    pop af ; recover tower type id
	; register the new tower in the array
	call build_register_new_tower

	; draw the new tower on the screen
	call build_draw_tower

    ret

build_build_tower_end_cleanup:
    pop af
    pop af
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


; de - the xy coordinates of the possible tower to sell
build_sell_tower:

    ; ignore if we're not on a valid build_tile
    call build_find_build_tile_index
    cp $ff
    ret z

    ; ignore if there is no tower on this build_tile
    ; stash build tile index in l
    ld hl, build_tile_towers
    ld l, a
    ld a, (hl)
    cp $fe ; $fe is uninitialized value
    ret z

    push hl
    ; increment money based on the tower
    ld c, a
    ld hl, tower_sell_price_tens
    add a, l
    ld l, a
    ld b, (hl)

    ld a, c
    ld hl, tower_sell_price_ones
    add a, l
    ld l, a
    ld c, (hl)

    call status_add_money

    pop hl

    ; clear the tower from the build_tile_towers array
    ld b, l
    ld a, $fe ; $fe means no tower
    call build_register_new_tower

    
    ; clear the tower from the screen
    call cursor_get_cell_addr
    ex de, hl
    ld hl, build_tile_b
    call util_draw_tile
	; store the tower attribute byte
    ld a, $34
    ld (cursor_old_attr), a
    ret
