level_select_setup:
	di
	ld 		hl, title_load_interrupt_handler
	call 	setup_interrupt_handler

    call    level_select_setup_screen

	ei
	jp		infinite_wait 

level_select_setup_screen:
    ld      a, 2
    call    5633
    ld      de, wumbo_w
    ld      bc, eo_wumbo_d-wumbo_w
    call    8252

    ret


title_load_interrupt_handler:
    di

    ; Check keyboard input 
    ; For now, level 1 - w, level 2 - a, level 3 - s, level 4 - d
    call    input_is_w_down
    call      z, load_map_1

    call    input_is_a_down
    call      z, load_map_2

    call    input_is_s_down
    call      z, load_map_3

    call    input_is_d_down
    call      z, load_map_4

title_load_handler_end:
    ei
    ret

load_map_1:
    call    init_level_a
    ei
    call    title_bypass_load
    ret

load_map_2:
    call    init_level_b
    ei
    call    title_bypass_load
    ret

load_map_3:
    call    init_level_c
    ei
    call    title_bypass_load
    ret

load_map_4:
    call    init_level_d
    ei
    call    title_bypass_load
    ret

wumbo_w:    defb 'W - Level 1' 
            defb 13 
wumbo_a:    defb 'A - Level 2'
            defb 13
wumbo_s:    defb 'S - Level 3'
            defb 13
wumbo_d:    defb 'D - Level 4'
            defb 13
wumbo_e:    defb 22, 16, 12,'n o e x i t'
            defb 13
eo_wumbo_d: equ $