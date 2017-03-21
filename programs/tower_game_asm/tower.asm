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

    and $fe
	cp $01
    ; if tower type is even, use single target attack
	call z, tower_handler_handle_laser_attack

    ; else, use aoe target attack
    call nz, tower_handler_handle_flame_attack

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
	ld hl, (build_tile_attackables)
	sla a
	sla a
	ld l, a
	ret




; todo: check if this tower has attacked already
; handles the attack for a laser tower
tower_handler_handle_laser_attack:
	; get the attackables pointer
	ld a, (current_tower_index)

	; get the attackable ptr in hl
	; the attackable position bytes are the 4 bytes at this address
	call tower_handler_get_attackable_ptr

	; check the first attackable, do attack if we find a position
	ld a, (hl)
	call tower_handler_handle_laser_attack_check_attackable
	cp $ff
	jp nz, tower_handler_handle_laser_attack_do_attack

	; check the second attackable, do attack if we find a position
	inc hl
	ld a, (hl)
	call tower_handler_handle_laser_attack_check_attackable
	cp $ff
	jp nz, tower_handler_handle_laser_attack_do_attack

	; check the third attackable, do attack if we find a position
	inc hl
	ld a, (hl)
	call tower_handler_handle_laser_attack_check_attackable
	cp $ff
	jp nz, tower_handler_handle_laser_attack_do_attack

	; check the fourth attackable, do attack if we find a position
	inc hl
	ld a, (hl)
	call tower_handler_handle_laser_attack_check_attackable
	cp $ff
	jp nz, tower_handler_handle_laser_attack_do_attack

	; if we get here then none of the attackables had an enemy
	; so just do nothing
	ret

	; jump here when we attack an enemy so that we only attack one enemy
tower_handler_handle_laser_attack_do_attack:
	; play the laser sound effect
	; maybe optimize this cuz of the excessive push and pop?
	push af
	ld a, (sound_effect_flags)
	or $01
	ld (sound_effect_flags), a
	pop af

	; attack the enemy at the position in a
	call tower_handler_handle_laser_attack_enemy

	ret


; input:
;   a - the first position of this attackable
; output:
;   a - the first position of this attackable that has an enemy, or $ff
tower_handler_handle_laser_attack_check_attackable:
	; if it's ff, then there's nothing to check so skip it
	cp $ff
	ret z

	; else, check the 3 tiles in this attackable range
	; (this position and the preceding 2)
	; we iterate "backwards" so that we always check the furthest tile along the path first

	ld b, a
	; check first position, return if we find something
	call tower_handler_find_enemy_at
	cp $ff
	ret nz

	ld a, b
	dec a
	ld b, a
	; check second position, return if we find something
	call tower_handler_find_enemy_at
	cp $ff
	ret nz

	ld a, b
	dec a
	; check third position, always return
	call tower_handler_find_enemy_at
	ret


; input:
;  a - the packed type / index of the enemy to attack
tower_handler_handle_laser_attack_enemy:
	call tower_handler_init_enemy_arrays
	call tower_handler_tower_damage_enemy
	ret

; todo: check if this tower has attacked already
; handles the attack for a laser tower
tower_handler_handle_flame_attack:
	; get the attackables pointer
	ld a, (current_tower_index)

	; get the attackable ptr in hl
	; the attackable position bytes are the 4 bytes at this address
	call tower_handler_get_attackable_ptr

	; check the first attackable, do attack if we find a position
	ld a, (hl)
	call tower_handler_handle_flame_attack_check_attackable
	cp $ff
	jp nz, tower_handler_handle_flame_attack_do_attack

	; check the second attackable, do attack if we find a position
	inc hl
	ld a, (hl)
	call tower_handler_handle_flame_attack_check_attackable
	cp $ff
	jp nz, tower_handler_handle_flame_attack_do_attack

	; check the third attackable, do attack if we find a position
	inc hl
	ld a, (hl)
	call tower_handler_handle_flame_attack_check_attackable
	cp $ff
	jp nz, tower_handler_handle_flame_attack_do_attack

	; check the fourth attackable, do attack if we find a position
	inc hl
	ld a, (hl)
	call tower_handler_handle_flame_attack_check_attackable
	cp $ff
	jp nz, tower_handler_handle_flame_attack_do_attack

	; if we get here then none of the attackables had an enemy
	; so just do nothing
	ret

	; jump here when we attack an enemy so that we only attack one enemy
tower_handler_handle_flame_attack_do_attack:
	; play the flame sound effect
	; maybe optimize this cuz of the excessive push and pop?
	push af
	ld a, (sound_effect_flags)
	; this is actually the zap sound but oh well
	or $04
	ld (sound_effect_flags), a
	pop af

	ld a, (hl)

	; attack the enemy at the position in a
	call tower_handler_handle_flame_attack_enemies

	ret

; input:
;   a - the first position of this attackable
; output:
;   a - $ff if not attackable, else attackable
tower_handler_handle_flame_attack_check_attackable:
	; if it's ff, then there's nothing to check so skip it
	cp $ff
	ret z

	; else, check the 3 tiles in this attackable range
	; (this position and the preceding 2)
	; we iterate "backwards" so that we always check the furthest tile along the path first

	; stash the attackable in c
	ld c, a

	ld b, a
	; check first position, return the attackable if we find something
	call tower_handler_find_enemy_at
	cp $ff
	jp nz, tower_handler_handle_flame_attack_check_attackable_return_attackable

	ld a, b
	dec a
	ld b, a
	; check second position, return the attackable if we find something
	call tower_handler_find_enemy_at
	cp $ff
	jp nz, tower_handler_handle_flame_attack_check_attackable_return_attackable

	ld a, b
	dec a
	; check third position, return the attackable if we find something
	call tower_handler_find_enemy_at
	cp $ff
	jp nz, tower_handler_handle_flame_attack_check_attackable_return_attackable

	; if we get this far, return $ff because nothing is here
	ld a, $ff
	ret

	; grab the attackable from c 
tower_handler_handle_flame_attack_check_attackable_return_attackable:
	ld a, c
	ret


; input:
;  a - the attackable position to attack
tower_handler_handle_flame_attack_enemies:
	; flame towers attack all 3 positions, so attack them in sequence

	; check and maybe attack the first position
	ld (current_attacked_enemy_position), a
	;call tower_handler_highlight_position
	;ld a, (current_attacked_enemy_position)
	call tower_handler_find_enemy_at
	cp $ff
	jp z, tower_handler_handle_flame_attack_enemies_two

	call tower_handler_init_enemy_arrays
	call tower_handler_tower_damage_enemy

tower_handler_handle_flame_attack_enemies_two:
	ld a, (current_attacked_enemy_position)
	dec a
	ld (current_attacked_enemy_position), a
	;call tower_handler_highlight_position
	;ld a, (current_attacked_enemy_position)
	call tower_handler_find_enemy_at
	cp $ff
	jp z, tower_handler_handle_flame_attack_enemies_three

	call tower_handler_init_enemy_arrays
	call tower_handler_tower_damage_enemy

tower_handler_handle_flame_attack_enemies_three:
	ld a, (current_attacked_enemy_position)
	dec a
	ld (current_attacked_enemy_position), a
	;call tower_handler_highlight_position
	;ld a, (current_attacked_enemy_position)
	call tower_handler_find_enemy_at
	cp $ff
	jp z, tower_handler_handle_flame_attack_enemies_done

	call tower_handler_init_enemy_arrays
	call tower_handler_tower_damage_enemy

	; todo: make flame tower always flash its attacks
tower_handler_handle_flame_attack_enemies_done:
	ret


tower_handler_init_enemy_arrays:
	; save the packed index into b
	ld b, a

	; store the real index
	and $7f
	ld (current_attacked_enemy_index), a

	; reload the packed index from b, check the type
	ld a, b
	and $80
	jp nz, tower_handler_init_enemy_arrays_strong_enemy

	; weak enemy
	ld hl, weak_enemy_position_array
	ld (current_enemy_position_array), hl
	ld hl, weak_enemy_health_array
	ld (current_enemy_health_array), hl
	; money value
	ld a, 1
	ld (current_attacked_enemy_value), a

	ret

	; strong enemy
tower_handler_init_enemy_arrays_strong_enemy:

	ld hl, strong_enemy_position_array
	ld (current_enemy_position_array), hl
	ld hl, strong_enemy_health_array
	ld (current_enemy_health_array), hl
	; money value
	ld a, 2
	ld (current_attacked_enemy_value), a

	ret


; damages an enemy and shows that it was this tower
tower_handler_tower_damage_enemy:
	;; flash the tile being attacked
	call tower_handler_highlight_enemy

	; flash the tower's tile
	call tower_handler_highlight_tower

	; find and decrement the enemy's health
	ld a, (current_attacked_enemy_index)

	call tower_handler_damage_enemy
	
	ret

; input:
;   a - enemy index
;  (current_enemy_health_array)
;  (current_enemy_position_array)
; damages an enemy and does health cleanup / money rewards
tower_handler_damage_enemy:
    ld c, a ; save enemy index

    ; figure out how much damage the tower should do, store value in b
    call tower_handler_get_tower_damage
    ld b, a 

    ld a, c ; restore enemy index

    ; get current enemy's health
	ld hl, (current_enemy_health_array)
	ld l, a

    ; subtract tower damage from enemy's health
    ld a, (hl)
	sub b
    ld (hl), a

    ld a, c ; restore enemy index

	; if we hit 0 or go negative, remove the enemy
	call z, tower_handler_kill_enemy
    call m, tower_handler_kill_enemy

	ret

; input:
;   a - enemy index
; (current_tower_index)
; (current_enemy_health_array)
; output:
;  a - the damage the current tower should do against the current enemy
tower_handler_get_tower_damage:
    ld d, a ; save the enemy index

     ; get the value in tower_damage_array for this tower id
    ld a, (current_tower_index)
    call tower_handler_load_tower_type
    ld hl, tower_damage_array
    add l
    ld l, a
    ld a, (hl)
    
    ; if the sign bit is not set, then a has the damage the tower should do 
    bit 7, a
    ret z
    
    ; else, the tower does percent of current health against the enemy
    
    and $7f
    ld b, a

    ; get the current enemy's current health
    ld hl, (current_enemy_health_array)
    ld l, d
    ld a, (hl)

tower_handler_get_tower_damage_shift_right:
    srl a

    djnz tower_handler_get_tower_damage_shift_right

    ret
    

tower_handler_highlight_enemy:
	; compute the offset into the attr byte address array
	ld a, (current_attacked_enemy_index)
	call enemy_handler_load_position_index
	jp tower_handler_highlight_position

; input:
;  a - the position to highlight
tower_handler_highlight_position:
	ld d, 0
	sla a
	ld e, a
	; get attr byte address array and offset into it
	ld hl, (enemy_path_attr)
	add hl, de
	; load the attr byte address into de
	ld e, (hl)
	inc hl
	ld d, (hl)
	; set and store the highlight bit
	ld a, (de)
	or $40
	ld (de), a

	ret

tower_handler_highlight_tower:
	; compute offset into xy array
	ld d, 0
	ld a, (current_tower_index)
	sla a
	ld e, a
	ld hl, (build_tile_xys)
	add hl, de

	; load x y coords
	ld d, (hl)
	inc hl
	ld e, (hl)

	; compute the attr address
	call cursor_get_cell_attr

	; set and store the highlight bit
	ld a, (hl)
	or $40
	ld (hl), a

	ret


; todo: blood splatter, clean up enemy
; input:
;   a - the enemy index
tower_handler_kill_enemy:
	call enemy_handler_clear_enemy_at_index

	; play the enemy dead sound effect
	ld a, (sound_effect_flags)
	or $20
	ld (sound_effect_flags), a

	; blood splatter
	; b is the position from enemy_handler_clear_enemy_at_index
	call tower_handler_draw_blood_splatter
	; then insert it as a path element
	ld c, $04
	call powerups_insert_path_element

	; decrement the enemy count
	call enemy_handler_decrement_enemy_count

	ld a, (current_attacked_enemy_value)
	call tower_handler_add_money
	ret

; input:
;  b - the position index to draw the blood splatter at
tower_handler_draw_blood_splatter:
	; draw the blood splatter sprite
	ld a, b
	call enemy_handler_load_position_vram
	ld hl, snowflake
	call util_draw_tile

	; set the green blood attribute
	ld a, b
	ld hl, (enemy_path_attr)
	ld d, 0
	sla a
	ld e, a
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	ld (hl), $74
	ret

; input:
;  a - the value of the enemy
tower_handler_add_money:
    ld b, 0
	ld c, a

    call status_add_money

	ret


; input:
;  a - the position index to search for
; output:
;  a - the enemy index for that position
tower_handler_find_enemy_at:
	ld de, enemy_position_to_index_array
	ld e, a
	ld a, (de)
	ret


border_color:
	defb $00

tower_handler_toggle_border_color:
	ld a, (border_color)
	inc a
	and $07
	ld (border_color), a
	out ($fe), a
	ret


; todo: what if cursor is on it
tower_clear_attack_highlights:
	; clear enemy highlights
	call tower_clear_path_highlights

	; clear build tile highlights
	ld hl, (build_tile_xys)
	ld b, h
	ld c, l
tower_clear_attack_highlights_loop:
	; check if we've hit the end
	ld a, (bc)
	cp $ff
	ret z

	; get the xy coords
	ld d, a
	inc bc
	ld a, (bc)
	ld e, a

	; calculate the attr address
	call cursor_get_cell_attr
	; unset it
	ld a, (hl)
	and $3f
	ld (hl), a

	jp tower_clear_attack_highlights_loop


tower_clear_path_highlights:
	ld hl, (enemy_path_attr)

tower_clear_path_highlights_loop:
	; check if at the end
	ld a, (hl)
	cp $ff
	ret z

	; load the address
	ld e, a
	inc hl
	ld d, (hl)
	inc hl

	; clear the highlight bit
	ld a, (de)
	and $bf
	ld (de), a

	; repeat
	jp tower_clear_path_highlights_loop

