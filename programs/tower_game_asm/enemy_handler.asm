enemy_handler_init:
	; initialize the enemy spawn script
	ld hl, enemy_spawn_script
	ld (enemy_spawn_script_ptr), hl

	ret



enemy_handler_entry_point_handle_enemies:
	ld hl, weak_enemy
	ld (current_enemy_sprite_page), hl
	ld hl, weak_enemy_position_array
	ld (current_enemy_position_array), hl
	ld hl, weak_enemy_health_array
	ld (current_enemy_health_array), hl
	ld a, (weak_enemy_hurt_threshold)
	ld (current_enemy_hurt_threshold), a

	call enemy_handler_handle_enemy

	ld hl, strong_enemy
	ld (current_enemy_sprite_page), hl
	ld hl, strong_enemy_position_array
	ld (current_enemy_position_array), hl
	ld hl, strong_enemy_health_array
	ld (current_enemy_health_array), hl
	ld a, (strong_enemy_hurt_threshold)
	ld (current_enemy_hurt_threshold), a

	call enemy_handler_handle_enemy

	ret

enemy_handler_handle_enemy:
	; if the frame counter is modulo 0, then run game logic (move enemies to next cell)
	ld a, (frame_counter)
	cp 0
	call z, enemy_handler_update_enemies
	; no matter what, animate the enemies
	call enemy_handler_animate_enemies

	ret

	

enemy_handler_entry_point_handle_spawn_enemies:
	ld hl, (enemy_spawn_script_ptr)

	; if ff, then we've hit the end so return and do nothing
	ld a, (hl)
	cp $ff
	ret z
	
	; store the position value into b so we can reload it later
	; after clobbering a with the default health value
	ld b, a

	; we didn't hit the end, so increment and store the pointer
	inc hl
	ld (enemy_spawn_script_ptr), hl

	; if 01, then weak enemy
	ld hl, weak_enemy_position_array
	ld de, weak_enemy_health_array
	cp $01
	ld a, (weak_enemy_default_health)
	jp z, enemy_handler_handle_spawn_enemy

	; reload from b since a was clobbered with the default health value
	ld a, b
	; if 02, then strong enemy
	ld hl, strong_enemy_position_array
	ld de, strong_enemy_health_array
	cp $02
	ld a, (strong_enemy_default_health)
	jp z, enemy_handler_handle_spawn_enemy

	; else we fell through, so just return
	ret


;;; enemy_handler_handle_spawn_enemy spawns an enemy into the given array
; input:
;   hl - the enemy position array to spawn into
;   de - the enemy health array to spawn into
;    a - the enemy health value to initialize with
enemy_handler_handle_spawn_enemy:
	; save the enemy health into b
	ld b, a

enemy_handler_handle_spawn_enemy_loop:
	ld a, (hl)

	; if it's $fe, then the slot is open so we can use it
	cp $fe
	jp z, enemy_handler_handle_spawn_enemy_do_spawn

	; if it's $ff, then we hit the end of the array so just use it
	cp $ff
	jp z, enemy_handler_handle_spawn_enemy_do_spawn

	; this spot is occupied, so increment and try again
	inc hl
	inc de
	jp enemy_handler_handle_spawn_enemy_loop

enemy_handler_handle_spawn_enemy_do_spawn:
	; we found a viable index, so store 0 at it (the start position)
	ld a, 0
	ld (hl), a
	; load the default health into the health array
	ld a, b
	ld (de), a

	ret




;;; main enemy update function - enemy_handler_update_enemies
; calls enemy_handler_update_enemy for every enemy in the (current_enemy_position_array)
; takes no inputs
enemy_handler_update_enemies:
	; loop over the array of fat enemies
	ld a, 0
	ld (current_enemy_index), a
enemy_handler_update_enemies_loop:
	; load the position for this enemy to do checks
	ld a, (current_enemy_index)
	call enemy_handler_load_position_index

	; check for $fe (skip enemy)
	cp $fe
	jp z, enemy_handler_update_enemies_loop_increment

	; check for $ff (end of array)
	cp $ff
	ret z

	call enemy_handler_update_enemy

	; increment loop counter and jump to beginning of loop
enemy_handler_update_enemies_loop_increment:
	ld a, (current_enemy_index)
	inc a
	ld (current_enemy_index), a

	jp enemy_handler_update_enemies_loop


;;; main animation function - enemy_handler_animate_enemies
; calls enemy_handler_animate_enemy for every enemy in the (current_enemy_position_array)
; takes no inputs
enemy_handler_animate_enemies:
	; loop over the array of fat enemies
	ld a, 0
	ld (current_enemy_index), a
enemy_handler_animate_enemies_loop:
	; load the enemy position to perform checks
	ld a, (current_enemy_index)
	call enemy_handler_load_position_index

	; check for $fe (skip enemy)
	cp $fe
	jp z, enemy_handler_animate_enemies_loop_increment

	; check for $ff (end of array)
	cp $ff
	ret z

	call enemy_handler_animate_enemy

	; increment loop counter and jump to beginning of loop
enemy_handler_animate_enemies_loop_increment:
	ld a, (current_enemy_index)
	inc a
	ld (current_enemy_index), a

	jp enemy_handler_animate_enemies_loop


; input:
;   a - the enemy's enemy index
; output:
;   a - the enemy's position index
enemy_handler_load_position_index:
	ld hl, (current_enemy_position_array)
	ld l, a
	ld a, (hl)
	ret


; input:
;   a - the enemy's enemy index
; output:
;   a - the enemy's health value
enemy_handler_load_health:
	ld hl, (current_enemy_health_array)
	ld l, a
	ld a, (hl)
	ret


; input:
;   a - the enemy's index
; output:
;   none
; side effect:
;   sets the enemy's index to fe, which clears it
enemy_handler_clear_enemy_index:
	ld hl, (current_enemy_position_array)
	ld l, a
	ld (hl), $fe
	ret

; input
;  a - the enemy's index
; side effect:
;  sets the enemy's index to fe, which clears it
;  clears the enemy's tiles in vram
enemy_handler_clear_enemy_at_index:
	push af
	; load the position index
    call enemy_handler_load_position_index

	; clear the first tile
	push af
	call enemy_handler_load_position_vram
	ld hl, blank_tile
	call util_draw_tile
	pop af

	; clear the second tile
	inc a
	call enemy_handler_load_position_vram
	ld hl, blank_tile
	call util_draw_tile

	; clear the enemy array entry
	pop af
	call enemy_handler_clear_enemy_index

	ret


; input:
;   a - the enemy's position index
; output:
;   a - the enemy's direction index
enemy_handler_load_enemy_direction:
	ld hl, (enemy_path_direction)
	ld l, a
	ld a, (hl)
	ret


; input:
;   a - the enemy's position index
; output:
;  de - the enemy's vram location
enemy_handler_load_position_vram:
	ld hl, (enemy_path)
	sla a
	ld l, a
	ld e, (hl)
	inc hl
	ld d, (hl)
	ret


; animate_enemy animates a single fat enemy
; input:
;   none - index stored at (current_enemy_index)
enemy_handler_animate_enemy:
	;; load enemy position index, stash it in b
	ld a, (current_enemy_index)
	call enemy_handler_load_position_index
	ld b, a

	;; load enemy direction, stash it in c
	call enemy_handler_load_enemy_direction
	ld c, a

	;;; if direction is up, then animate with the next position along
	;;; else give the current one
	cp 2
	jp nz, enemy_handler_animate_enemy_not_up
	inc b

enemy_handler_animate_enemy_not_up:
	;; load the vram address to animate from into de
	ld a, b
	call enemy_handler_load_position_vram

	;; check if the enemy is walking off the end of the path
	;; if they are, then jump to the abort handler
	ld a, d
	cp $ff
	jp z, enemy_handler_handle_enemy_at_end

	;; else, actually animate the enemy
	; load the enemy sprite
	ld hl, (current_enemy_sprite_page)
	; grab the health and compute the l register
	call enemy_handler_check_health
	; grab the enemy direction from c
	ld a, c
	; render the sprite
    call    enemy_sprite_draw_next_sprite

	ret


; sets the l register to $00 or $80 depending on the health
; inputs:
;   a - the enemy health
enemy_handler_check_health:
	push hl

	; load current health into h
	ld a, (current_enemy_index)
	call enemy_handler_load_health
	ld h, a

	; load hurt threshold into a
	ld a, (current_enemy_hurt_threshold)

	; if h (health) is less than a (threshold), c will be reset
	cp h
	pop hl
	jp nc, enemy_handler_check_health_unhealthy

	; healthy case
	ld l, $00
	ret

	; unhealthy case
enemy_handler_check_health_unhealthy:
	ld l, $80
	ret



; input:
;   none - index stored at (current_enemy_index)
; side effects:
;   updates the position of the enemy at index a
enemy_handler_update_enemy:
	ld a, (current_enemy_index)
	call enemy_handler_load_position_index

	; increment the position index and store it back
	inc a
	ld (hl), a
	dec a

	; clear the previous tile now that the enemy is no longer in it
	call enemy_handler_load_position_vram
	ld hl, blank_tile
	call load_map_old_draw_tile

	ret


; input:
;   none - (current_enemy_index)
; side effects:
;   clears the enemy's index
;   sets border color to red
enemy_handler_handle_enemy_at_end:
	; if we did reach the end of the path, then:
	; set position to fe so this enemy is skipped
	ld a, (current_enemy_index)
	call enemy_handler_clear_enemy_index
	call enemy_handler_decrement_health

	ret


enemy_handler_decrement_health:
	; load the current health value
	ld a, (health_ones)

	; decrement and maybe handle carry
	dec a
	jp m, enemy_handler_decrement_health_handle_tens_carry

	; if not handling carry, just store the new health_ones back
	ld (health_ones), a

	; check if we're dead now
	jp z, enemy_handler_decrement_health_handle_dead

	ret

	; case where health_ones has overflowed and we have to borrow from health_tens
enemy_handler_decrement_health_handle_tens_carry:
	ld a, (health_tens)
	; check if we're dead
	cp 0
	jp z, enemy_handler_decrement_health_handle_dead

	dec a
	ld (health_tens), a

	ld a, 9
	ld (health_ones), a

	ret

enemy_handler_decrement_health_handle_dead:
	ld a, 0
	ld (health_ones), a
	ld (health_tens), a


	; set border to red, and abort
	ld a, 2
	out ($fe), a
	ld ($fdcc), a

	ret


enemy_handler_entry_point_compute_position_to_index_array:
	; first clear the array
	call enemy_handler_clear_position_to_index_array

	; then fill in for weak
	ld de, weak_enemy_position_array
	ld hl, enemy_position_to_index_array
	ld c, $00
	call enemy_handler_compute_position_to_index_array

	; and fill in for strong
	ld de, strong_enemy_position_array
	ld hl, enemy_position_to_index_array
	ld c, $80
	call enemy_handler_compute_position_to_index_array

	ret

; inputs:
;   c - base byte to or into the index
;  de - enemy array
;  hl - position to index array
enemy_handler_compute_position_to_index_array:

	; b is the enemy array index
	ld b, 0
enemy_handler_compute_position_to_index_array_loop:
	; load the position
	ld a, (de)

	; empty spot
	cp $fe
	jp z, enemy_handler_compute_position_to_index_array_loop_increment

	; end of enemy array
	cp $ff
	ret z

	; not empty, not end: valid position
	; offset into the position_to_index array with our position
	ld l, a

	; or the position with the base byte
	ld a, b
	or c
	; store the result in the position_to_index_array
	ld (hl), a

enemy_handler_compute_position_to_index_array_loop_increment:
	; increment and jump back
	inc b
	inc de

	jp enemy_handler_compute_position_to_index_array_loop


enemy_handler_clear_position_to_index_array:
	; read from section of rom with $ff for 256 bytes
	ld hl, $3900
	; write to the array we want to clear
	ld de, enemy_position_to_index_array
	; write 256 times
	ld bc, $0100
	ldir
	ret
