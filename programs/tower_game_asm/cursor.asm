cursor_init:
	ld a, 7
	ld (cursor_x), a
	ld a, 2
	ld (cursor_y), a

	ld d, 7
	ld e, 2
	call cursor_get_cell_attr
	ld a, (hl)
	ld (cursor_old_attr), a
	ld (hl), 199

	ret

cursor_entry_point_handle_input:
	; load up the old cell attr vram address
	ld a, (cursor_x)
	ld d, a
	ld a, (cursor_y)
	ld e, a
	call cursor_get_cell_attr
	; put back the old attribute byte
	ld a, (cursor_old_attr)
	ld (hl), a

	; get and save the new cursor position
	call cursor_check_wasd_inputs
	call cursor_check_bounds
	ld a, d
	ld (cursor_x), a
	ld a, e
	ld (cursor_y), a

	; save the attr byte already there
	call cursor_get_cell_attr
	ld a, (hl)
	ld (cursor_old_attr), a

	; set to highlight
	ld (hl), 199

    call cursor_check_tower_inputs
    call cursor_check_powerups_collect
    call cursor_check_powerups_usage

    call status_update_upgrade_sell_price
	
	ret


cursor_check_wasd_inputs:
	call input_is_w_down
	ld c, a
	ld a, e
	sub c
	ld e, a

	call input_is_s_down
	add a, e
	ld e, a

	call input_is_a_down
	ld c, a
	ld a, d
	sub c
	ld d, a

	call input_is_d_down
	add a, d
	ld d, a
    ret

cursor_check_tower_inputs:

    call input_is_1_down
    call z, build_laser_tower

    call input_is_2_down
    call z, build_bomb_tower

    call input_is_3_down
    call z, build_slow_tower

    call input_is_4_down
    call z, build_basic_tower

    call input_is_g_down
    call z, build_sell_tower

    call input_is_r_down
    call z, build_upgrade_tower

	ret

cursor_check_powerups_usage:

    call input_is_6_down
    call z, powerups_use_bomb

    call input_is_7_down
    call z, powerups_use_zap

    call input_is_8_down
    call z, powerups_use_slow

    ret

cursor_check_powerups_collect:

    ld a, (powerup_one)

    ; check if powerup_one is enabled
    ld b, $ff    
    cp b
    jp z, cursor_after_powerup_one_check

    ; check if powerup_one exists
    ld b, 0
    cp b
    jp z, cursor_after_powerup_one_check

    ; check if x coord matches powerup_one
    ld a, (powerup_one_x)
    cp d
    jp nz, cursor_after_powerup_one_check

    ; check if y coord matches powerup_one
    ld a, (powerup_one_y)
    cp e
    jp nz, cursor_after_powerup_one_check

    ; if passed all checks, get powerup_one
    ld bc, powerup_one
    call powerups_get_powerup

  cursor_after_powerup_one_check:

    ld a, (powerup_two)

    ld b, $ff    
    cp b
    jp z, cursor_after_powerup_two_check

    ld b, 0
    cp b
    jp z, cursor_after_powerup_two_check


    ld a, (powerup_two_x)
    cp d
    jp nz, cursor_after_powerup_two_check

    ld a, (powerup_two_y)
    cp e
    jp nz, cursor_after_powerup_two_check

    ld bc, powerup_two
    call powerups_get_powerup

  cursor_after_powerup_two_check:

    ld a, (powerup_three)

    ld b, $ff    
    cp b
    jp z, cursor_after_powerup_three_check

    ld b, 0
    cp b
    jp z, cursor_after_powerup_three_check


    ld a, (powerup_three_x)
    cp d
    jp nz, cursor_after_powerup_three_check

    ld a, (powerup_three_y)
    cp e
    jp nz, cursor_after_powerup_three_check

    ld bc, powerup_three
    call powerups_get_powerup

  cursor_after_powerup_three_check:

    ret

cursor_check_bounds:
	; check x left wrap around
	ld a, d
	cp $ff
	jp nz, cursor_check_bounds_no_left_reset_x
	ld d, 0
cursor_check_bounds_no_left_reset_x:

	; check x right wrap around
	cp 32
	jp nz, cursor_check_bounds_no_right_reset_x
	ld d, 31
cursor_check_bounds_no_right_reset_x:

	; check y top wrap around
	ld a, e
	cp $ff
	jp nz, cursor_check_bounds_no_top_reset_y
	ld e, 0
cursor_check_bounds_no_top_reset_y:

	; check y bottom wrap around
	cp 16
	jp nz, cursor_check_bounds_no_bottom_reset_y
	ld e, 15
cursor_check_bounds_no_bottom_reset_y:

	ret


; inputs:
;  d - the x cell
;  e - the y cell
; outputs:
;  hl - the address of the attribute byte
cursor_get_cell_attr:
	ld a, d
	and $1f
	ld l, a
	ld a, e
	and $07
	rrc a
	rrc a
	rrc a
	add a, l
	ld l, a
	ld a, e
	and $18
	srl a
	srl a
	srl a
	add a, $58
	ld h, a
	ret

; read coordinates from d = x, e = y
; set address to hl
cursor_get_cell_addr:
	ld a, e
	sla a
	sla a
	sla a
	ld e, a
	ld a, d
	sla a
	sla a
	sla a
	ld d, a
	call cursor_get_pixel_addr
	ret

; read coordinates from d = x, e = y
; set address to hl
cursor_get_pixel_addr:
	ld a, d
	and $f8
	srl a
	srl a
	srl a
	ld l, a
	ld a, e
	and $38
	sla a
	sla a
	or l
	ld l, a
	ld a, e
	and $7
	ld h, a
	ld a, e
	and $c0
	srl a
	srl a
	srl a
	add a, $40
	or h
	ld h, a
	ret

 
