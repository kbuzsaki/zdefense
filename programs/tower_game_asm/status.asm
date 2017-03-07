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
    ld bc, status_bo_end-status_bomb
    call 8252

    ld de, status_slow
    ld bc, status_s_end-status_slow
    call 8252

    call status_set_status_attrs

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
	ld c, 3
status_set_status_attrs_outer_loop:
	ld (hl), d
	inc hl
	ld b, 255
status_set_status_attrs_inner_loop:
	ld (hl), d
	inc hl
	djnz status_set_status_attrs_inner_loop
	dec c
	jp nz, status_set_status_attrs_outer_loop
	ret



status_round:
	defb 22, 16, 0,'Wave: 1'
status_r_end: equ $

status_enemy_count:
	defb 22, 17, 0,'Enemies: 5'
status_ec_end: equ $

status_money_life:
	defb 22, 16, 20,'$800    *10'
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
status_bo_end: equ $

status_slow:
	defb 22, 1, 20,'3:Slow  $200'
status_s_end: equ $
