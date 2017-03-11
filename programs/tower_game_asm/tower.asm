tower_handler_entry_point_handle_attacks:
	call tower_handler_handle_attacks
	ret

; iterates over the towers that have been built
; and performs the tower attacks
tower_handler_handle_attacks:
	ld a, 0
	ld (current_tower_index), a

tower_handler_handle_attacks_loop:
	; load the tower type to perform checks
	ld a, (current_tower_index)
	call tower_handler_load_tower_type

	; check for $fe (empty)
	cp $fe
	jp z, tower_handler_handle_attacks_loop_increment

	; check for $ff (end of array)
	cp $ff
	ret z

	; check for $01 (laser tower)
	cp $01
	call z, tower_handler_handle_laser_attack

	; increment loop counter and jump to beginning of loop
tower_handler_handle_attacks_loop_increment:
	ld a, (current_tower_index)
	inc a
	ld (current_tower_index), a

	jp tower_handler_handle_attacks_loop
	ret


; input:
;  a - the build tile index
; output:
;  a - the type of the tower
tower_handler_load_tower_type:
	ld hl, build_tile_towers
	ld l, a
	ld a, (hl)
	ret

; input:
;  a - the build tile index
; output:
;  hl - the ptr into the build_tile_attackables array
tower_handler_get_attackable_ptr:
	ld hl, build_tile_attackables_d
	sla a
	sla a
	ld l, a
	ret


border_color:
	defb $00

; handles the attack for a laser tower
tower_handler_handle_laser_attack:
	; get the attackables pointer
	ld a, (current_tower_index)
	call tower_handler_get_attackable_ptr

	; load the first attackables
	ld a, (hl)
	; check if there's an enemy that we can attack
	push hl
	call tower_handler_find_enemy_at
	; if there is, then "attack" it
	cp $ff
	call nz, tower_handler_toggle_border_color
	ret


; input:
;  a - the position index to search for
; output:
;  a - the enemy index for that position
tower_handler_find_enemy_at:
	; stuff the position we're searching for into c
	ld c, a
	ld hl, weak_enemy_position_array
	ld b, 0
tower_handler_find_enemy_at_loop:
	; load and compare the position
	ld a, (hl)
	cp c
	jp z, tower_handler_find_enemy_at_found

	; check if at end of array
	cp $ff
	jp z, tower_handler_find_enemy_at_not_found

	; increment and loop
	inc b
	inc hl
	jp tower_handler_find_enemy_at_loop

tower_handler_find_enemy_at_found:
	ld a, b
	ret

tower_handler_find_enemy_at_not_found:
	ld a, $ff
	ret


tower_handler_toggle_border_color:
	ld a, (border_color)
	inc a
	ld (border_color), a
	out ($fe), a
	ret
