status_init:
    call status_clear_status
    ld a,2              ; upper screen
    call 5633           ; open channel
    
    ld de, status_round       ; address of string
    ld bc, status_r_end-status_round  ; length of string to print
    call 8252           ; print our string
    
    ld de, status_enemy_count 
    ld bc, status_ec_end-status_enemy_count
    call 8252

    ld de, status_money_life
    ld bc, status_ml_end-status_money_life
    call 8252

    ld de, status_tower_title
    ld bc, status_tt_end-status_tower_title
    call 8252

    ld de, status_laser
    ld bc, status_l_end-status_laser
    call 8252

    ld a, 1
    call 5633
    ld de, status_bomb
    ld bc, status_b_end-status_bomb
    call 8252

    ld de, status_slow
    ld bc, status_s_end-status_slow
    call 8252

    call status_set_status_attrs

    call status_update_money_life

    ld a, 1
    ld (wave_count), a
    call status_update_wave_count
    
    ld a, 5
    ld (enemy_count), a
    call status_update_enemy_count 

	ret


status_update_money_life:
    ld a, (money_tens)
    add a, $30
    ld e, a
    ld a, (money_ones)
    add a, $30
    ld d, a

    ld (status_money_life+4), de

    ld a, (health_tens)
    add a, $30
    ld e, a
    ld a, (health_ones)
    add a, $30
    ld d, a

    ld (status_money_life+12), de

    ;paint new values to screen
    ld a, 2
    call 5633
    ld de, status_money_life
    ld bc, status_ml_end-status_money_life
    call 8252

    ;draw green dollar sign
    ld e, 16
    ld d, 20

    call cursor_get_cell_attr
    ld (hl), $44

    ;draw red heart
    ld e, 16
    ld d, 28

    call cursor_get_cell_attr
    ld (hl), $42

    call cursor_get_cell_addr
    ld d, h
    ld e, l
    ld hl, heart
    call util_draw_tile

    ;draw red life text if no life
    ld a, (health_ones)
    ld b, a

    ld a, (health_tens)
    or b
    jp nz, status_update_money_life_end

    ld e, 16
    ld d, 29

    call cursor_get_cell_attr
    ld (hl), $02

    ld e, 16
    ld d, 30

    call cursor_get_cell_attr
    ld (hl), $02

status_update_money_life_end:
    ret

status_update_wave_count:
    ld a, (wave_count)
    add a, $30

    ld (status_round+9), a

    ld a, 2
    call 5633

    ld de, status_round
    ld bc, status_r_end-status_round
    call 8252

    ret

status_update_enemy_count:
    ld a, (enemy_count)
    add a, $30

    ld (status_enemy_count+12), a

    ld a, 2
    call 5633

    ld de, status_enemy_count 
    ld bc, status_ec_end-status_enemy_count
    call 8252

    ret

;; update the "enemies coming up" in the status
status_entry_point_update_enemy_spawn_preview:
	; load the upcoming enemy
	ld hl, (enemy_spawn_script_ptr)

	push hl
	call status_load_enemy_spawn_preview_lookup_index
	call status_load_enemy_spawn_preview_tile
	ld de, $5040
	call util_draw_tile
	pop hl

	inc hl
	push hl
	call status_load_enemy_spawn_preview_lookup_index
	call status_load_enemy_spawn_preview_tile
	ld de, $5060
	call util_draw_tile
	pop hl

	inc hl
	push hl
	call status_load_enemy_spawn_preview_lookup_index
	call status_load_enemy_spawn_preview_tile
	ld de, $5080
	call util_draw_tile
	pop hl

	inc hl
	push hl
	call status_load_enemy_spawn_preview_lookup_index
	call status_load_enemy_spawn_preview_tile
	ld de, $50a0
	call util_draw_tile
	pop hl

	inc hl
	push hl
	call status_load_enemy_spawn_preview_lookup_index
	call status_load_enemy_spawn_preview_tile
	ld de, $50c0
	call util_draw_tile
	pop hl

	inc hl
	push hl
	call status_load_enemy_spawn_preview_lookup_index
	call status_load_enemy_spawn_preview_tile
	ld de, $50e0
	call util_draw_tile
	pop hl

	ret


status_load_enemy_spawn_preview_lookup_index:
	ld a, (hl)

    ; if it's fe, then override to 0 (blank)
	bit 7, a
	jp z, status_load_enemy_spawn_preview_lookup_index_no_clear
	ld a, 0
status_load_enemy_spawn_preview_lookup_index_no_clear:

	ret

; input:
;   a - the index into the lookup table
status_load_enemy_spawn_preview_tile:
	; build the address into the lookup table
	ld hl, status_enemy_preview_lookup
	sla a
    ld e, a
    ld d, 0
    add hl, de

	; load the source tile address into de, then swap it into hl
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl

	ret



status_clear_status:
    ld d, 0
	call status_fill_all_status
	ret

status_fill_all_status:
	ld hl, $5000
	ld c, 8
status_fill_status:
status_fill_status_outer_loop:
	ld (hl), d
	inc hl
	ld b, 255
status_fill_status_inner_loop:
	ld (hl), d
	inc hl
	djnz status_fill_status_inner_loop
	dec c
	jp nz, status_fill_status_outer_loop
	ret

status_set_status_attrs:
	ld d, $07
	call status_do_set_status_attrs
	ret

; d = fill byte
status_do_set_status_attrs:
	ld hl, $5a00
	ld c, 4
status_set_status_attrs_outer_loop:
	ld (hl), d
	inc hl
	ld b, 63
status_set_status_attrs_inner_loop:
	ld (hl), d
	inc hl
	djnz status_set_status_attrs_inner_loop
	dec c
	jp nz, status_set_status_attrs_outer_loop
	ret


	
status_enemy_preview_lookup:
	defw blank_tile
	defw weak_enemy + 96
	defw strong_enemy + 96

status_round:
	defb 22, 16, 0,'Wave: 0'
status_r_end: equ $

status_enemy_count:
	defb 22, 17, 0,'Enemies: 0'
status_ec_end: equ $

status_money_life:
	defb 22, 16, 20,'$000    *00'
status_ml_end: equ $

status_tower_title:
	defb 22, 20, 20,'Towers:'
status_tt_end: equ $

status_laser:
	defb 22, 21, 20,'1:Laser $100'
status_l_end: equ $

; Printed using channel 1, so their y offset is different
status_bomb:
	defb 22, 0, 20,'2:Bomb  $300'
status_b_end: equ $

status_slow:
	defb 22, 1, 20,'3:Slow  $200'
status_s_end: equ $
