enemy_handler_entry_point_handle_enemies:
	ld hl, weak_enemy
	ld (current_enemy_sprite_page), hl
	ld hl, weak_enemy_array
	ld (current_enemy_array), hl

	call enemy_handler_handle_enemy

	ld hl, strong_enemy
	ld (current_enemy_sprite_page), hl
	ld hl, strong_enemy_array
	ld (current_enemy_array), hl

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

	

;;; main enemy update function - enemy_handler_update_enemies
; calls enemy_handler_update_enemy for every enemy in the (current_enemy_array)
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
; calls enemy_handler_animate_enemy for every enemy in the (current_enemy_array)
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
	ld hl, (current_enemy_array)
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
	ld hl, (current_enemy_array)
	ld l, a
	ld (hl), $fe
	ret


; input:
;   a - the enemy's position index
; output:
;   a - the enemy's direction index
enemy_handler_load_enemy_direction:
	ld hl, enemy_path_direction
	ld l, a
	ld a, (hl)
	ret


; input:
;   a - the enemy's position index
; output:
;  de - the enemy's vram location
enemy_handler_load_position_vram:
	ld hl, enemy_path
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
	; grab the enemy direction from c
	ld a, c
	; load the enemy sprite
	ld hl, (current_enemy_sprite_page)
	; assume healthy for now
    ld      l, $80
    call    enemy_sprite_draw_next_sprite

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
	; set border to red, and abort
	ld a, 2
	out ($fe), a
	ret
