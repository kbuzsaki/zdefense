; handle_enemy does enemy processing for an enemy in the
; fat_enemy_array
; inputs:
;  a: the enemy's index into the enemy array
; todo: take the ticker as a param?
handle_enemy:
	ld hl, fat_enemy_array
	ld l, a
	ld (current_enemy_index), a

	; load the enemy's current position index
	; and store its next position index back
	ld a, (hl)

	; if frame_counter == 0:
	;     then move to the next cell
	; else:
	;     just animate in the current cell
	ld b, a
	ld a, (frame_counter)
	cp 0
	ld a, b
	jp nz, animate_current_cell

	inc a
	ld (hl), a
	dec a

	; load the enemy's old position in vram
	sla a
	ld hl, enemy_path
	ld l, a
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl

	; clear the enemy at its old position
	push hl
	ld hl, blank_tile
	call old_draw_tile
	pop hl

animate_current_cell:
	;;; check direction
	; load the enemy's position from the enemy array
	ld a, (current_enemy_index)
	ld hl, fat_enemy_array
	ld l, a
	ld a, (hl)
	; load the enemy's direction from the position -> direction array
	ld hl, enemy_path_direction
	ld l, a
	ld a, (hl)
	;;; if direction is up, then give the next cell address
	;;; else give the current one
	cp 2
	jp nz, animate_current_cell_load_pos_index
	;;; load the enemy's position address
    ; use enemy array index to load enemy position index
	ld a, (current_enemy_index)
	ld hl, fat_enemy_array
	ld l, a
	ld a, (hl)
	inc a
	jp animate_current_cell_load_pos_addr

animate_current_cell_load_pos_index:
	;;; load the enemy's position address
    ; use enemy array index to load enemy position index
	ld a, (current_enemy_index)
	ld hl, fat_enemy_array
	ld l, a
	ld a, (hl)
animate_current_cell_load_pos_addr:
	; use enemy position index to load enemy position address
	sla a
	ld hl, enemy_path
	ld l, a

	; load the enemy's new position in vram
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl

	; if the enemy's new position is the end ($ff), then abort
	ld a, d
	cp $ff
	jp nz, draw_new_position
	; if we did reach the end of the path, then:
	; set position to fe so this enemy is skipped
	ld hl, fat_enemy_array
	ld a, (current_enemy_index)
	ld l, a
	ld (hl), $fe
	; set border to red, and abort
	ld a, 2
	out ($fe), a
	jp interrupt_handler_end

draw_new_position:
	; draw the enemy at its new position
	; load the frame ticker

	; load the enemy's position from the enemy array
	ld a, (current_enemy_index)
	ld hl, fat_enemy_array
	ld l, a
	ld a, (hl)
	; load the enemy's direction from the position -> direction array
	ld hl, enemy_path_direction
	ld l, a
	ld a, (hl)

	; load the enemy sprite
	ld hl, fat_enemy
	; assume healthy for now
    ld      l, $80
    
    call    enemy_sprite_draw_next_sprite

	ret
