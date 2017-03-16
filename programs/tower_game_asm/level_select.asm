level_select_setup:
	di
	ld 		hl, title_load_interrupt_handler
	call 	setup_interrupt_handler

    call    level_select_setup_screen

	ei
	jp		infinite_wait 

level_select_setup_screen:
    call    util_clear_pixels

    ld      a, 2
    call    5633
    ld      de, wumbo_w
    ld      bc, eo_wumbo_d-wumbo_w
    call    8252


    ld      d, 4
    ld      e, 5
    call    cursor_get_cell_addr
    
    ex      de, hl

    ld      b, 6
fruity_loops:
    ld      hl, t_tile_topleft
    call    load_2x2_sprite

    inc     e
    inc     e
    ld      hl, h_tile_topleft
    call    load_2x2_sprite

    inc     e
    inc     e  
    djnz    fruity_loops

; Phase two, draw second line right below but in the 2nd section of screen
    ld      d, 10
    ld      e, 8
    call    cursor_get_cell_addr
    ex      de, hl

    ld      b, 3
reason:
    ld      hl, t_tile_topleft
    call    load_2x2_sprite

    inc     e
    inc     e
    ld      hl, h_tile_topleft
    call    load_2x2_sprite

    inc     e
    inc     e  
    djnz    reason 

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

; hl - address of topleft tile
; de - beginning vram address
load_2x2_sprite:
    push    hl
    push    de
    ; topleft, topright then bottomleft, bottomright
    call    enemy_sprite_draw_sprite_entire_cell

    inc     e
    ld      a, l
    add     a, 8
    ld      l, a
    call    enemy_sprite_draw_sprite_entire_cell

    ; now bottom right
    ld      a, l
    add     a, 8
    ld      l, a
    
    ld      a, e
    add     a, $20
    ld      e, a
    ; inc     d
    call    enemy_sprite_draw_sprite_entire_cell

    ; ; bottom left
    dec     e
    ld      a, l
    add     a, 8
    ld      l, a
    call    enemy_sprite_draw_sprite_entire_cell

    pop     de
    pop     hl
    ret


wumbo_w:    defb 22, 11, 4,'MAP SELECTION PRESS KEY' 
            defb 13 
wumbo_a:    defb 22, 12, 10,'W - Level 1'
            defb 13
wumbo_s:    defb 22, 13, 10,'A - Level 2'
            defb 13
wumbo_d:    defb 22, 14, 10,'S - Level 3'
            defb 13
wumbo_e:    defb 22, 15, 10,'D - Level 4'
            defb 13
eo_wumbo_d: equ $