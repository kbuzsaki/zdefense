level_select_setup:
	di
	ld 		hl, title_load_interrupt_handler
	call 	setup_interrupt_handler

    ; Generate data
    call    generate_path_data
    call    generate_direction_data

    ; Init necessary bare-bones data
    call    enemy_handler_init

    ; Set up screen
    call    level_select_setup_screen

	ei
	jp		infinite_wait 

level_select_setup_screen:
    ; Clear screen
    call    util_clear_pixels

    ; Load background map
    ld      hl, loading_screen_map
    ld      d, $50
    ld      e, $00
    call    load_map_draw_map


    ; Write level select text to the screen
    ld      a, 2
    call    5633
    ld      de, wumbo_w
    ld      bc, eo_wumbo_d-wumbo_w
    call    8252

    ; Fill all attrs to green
    ld      d, $20
    call    util_fill_all_attrs


    ; Self modifying code--------------------------------------
    ; overwrite line 88 in util.asm to be ld b, 85
    ld      hl, util_fill_attrs_inner_loop
    dec     hl
    ld      (hl), $55 ; 85

    ld      hl, $5A00
    ld      c, 3
    ld      d, $34
    call    util_fill_attrs

    ; self modifying code again. modify back to how it was before.
    ld      hl, util_fill_attrs_inner_loop
    dec     hl
    ld      (hl), $FF ; 255
    ; end nasty self modifying code --------------------------


    ; Clear the walking path for the sprites
    ld      de,loading_screen_map_attrs
    ld      (enemy_path_attr), de
    call    load_map_init_path_attr_bytes


    ; Draw the first two rows of the title 
    ld      hl, titlefont_data
    ld      b, 16
    ld      c, 2
    ld      d, 8
    ld      e, 3
    ld      a, $06
    call    util_draw_image

    ; Draw the third row
    ld      hl, halfway
    ld      b, 16
    ld      c, 1
    ld      d, 8
    ld      e, 5
    ld      a, $06
    call    util_draw_image

    ; ----------------- draw random lakes
    ld hl, lake_5x3
    ld b, 5
    ld c, 3
    ld d, 2
    ld e, 2
    ld a, $0c
    call util_draw_image

    ld hl, lake_5x3_secondline
    ld b, 5
    ld c, 2
    ld d, 2
    ld e, 4
    ld a, $0c
    call util_draw_image

    ; draw the second lake on the right
    ld hl, lake_3x3
    ld b, 3
    ld c, 3
    ld d, 28
    ld e, 4
    ld a, $0c
    call util_draw_image

    ld hl, lake_3x3_secondline
    ld b, 3
    ld c, 2
    ld d, 28
    ld e, 6
    ld a, $0c
    call util_draw_image

    ld hl, lake_3x3_secondline
    ld b, 3
    ld c, 2
    ld d, 28
    ld e, 7
    ld a, $0c
    call util_draw_image
    ; ----------------- end draw lakes


    ; Set up the initial minimap
    call selection_change_minimap


    ld  a, $A0
    ld (level_select_choice_attr), a
    ld  a, $59
    ld (level_select_choice_attr+1), a
    
    call toggle_highlight_level_choice


    ret


title_load_interrupt_handler:
    di

    ; We'll utilize frame counters for our purposes for moving sprites
    call    increment_frame_counters

    ; Move existing sprites
	ld a, (sub_frame_counter)
	cp 0
	call z, enemy_handler_entry_point_handle_enemies

    ; Spawn enemies if necessary
	ld a, (real_frame_counter)
	and $3f
	cp $18
	call z, enemy_handler_entry_point_handle_spawn_enemies

    ; Cusor
	ld a, (sub_frame_counter)
	and 3
	call z, level_select_handle_input


    ld      a, 4
    ; out     ($fe), a
    ; Check keyboard input 
    ; For now, level 1 - w, level 2 - a, level 3 - s, level 4 - d

title_load_handler_end:
    ei
    ret

load_map_1:
    call    init_level_a
    call    reset_frame_counters
    call    reset_enemy_data
    ei
    call    title_bypass_load
    ret

load_map_2:
    call    init_level_b
    call    reset_frame_counters
    call    reset_enemy_data 
    ei
    call    title_bypass_load
    ret

load_map_3:
    call    init_level_c
    call    reset_frame_counters
    call    reset_enemy_data    
    ei
    call    title_bypass_load
    ret

load_map_4:
    call    init_level_d
    call    reset_frame_counters
    call    reset_enemy_data
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

generate_direction_data:
    ; Address at 7100 should already be 00-filled
    ; so just place an $ff at the appropriate spot
    ld      hl, $712B
    ld      (hl), $FF
    ld      hl, enemy_path_direction
    ld      (hl), $00
    inc     l
    ld      (hl), $71
    
    ret

generate_path_data:
    ; Address at $7000 will suffice for storage
    ; technically start at 7000+2 to skip first initial 0 word
    ld      (saved_sp), sp
    ld      sp, $7044
    ld      b, $20
    
    ; Push the last $FFFF word
    ld      hl, $FFFF
    push    hl

    ld      hl, $507f               ; base address
generate_path_data_filling_loop:
    push    hl
    dec     hl

    djnz    generate_path_data_filling_loop

    ld      sp, (saved_sp)

    ; Overwrite the global variable w/ this addr
    ld      hl, enemy_path
    ld      (hl), $00
    inc     l
    ld      (hl), $70

    ret

toggle_highlight_level_choice:

    ld      hl, (level_select_choice_attr)

    ld      b, 14
toggle_highlight_level_choice_loop:
    ld      a, (hl)
    xor     $80
    ld      (hl), a
    inc     l 
    djnz    toggle_highlight_level_choice_loop

    ret

move_selection_up:

    ; Check to make sure we're not at the very top
    ld      a, (level_select_choice)
    cp      0
    jr      z, move_selection_up_end

    ; Decrement choice
    dec     a
    ld      (level_select_choice), a

    ; Toggle bit on current attr
    call    toggle_highlight_level_choice

    ; Change the attr byte to the line above
    ld      hl, (level_select_choice_attr)
    ld      a, l
    sub     32
    ld      l, a
    ld      (level_select_choice_attr), hl

    ; Toggle that bit of the new selection
    call    toggle_highlight_level_choice

    ; Change minimap
    call    selection_change_minimap
    

move_selection_up_end:
    ret

move_selection_down:
    ; Check to make sure we're not at the very top
    ld      a, (level_select_choice)
    cp      3
    jr      z, move_selection_down_end

    ; Decrement choice
    inc     a
    ld      (level_select_choice), a

    ; Toggle bit on current attr
    call    toggle_highlight_level_choice

    ; Change the attr byte to the line above
    ld      hl, (level_select_choice_attr)
    ld      a, l
    add     32
    ld      l, a
    ld      (level_select_choice_attr), hl

    ; Toggle that bit of the new selection
    call    toggle_highlight_level_choice

    ; Load new minimap
    call    selection_change_minimap

move_selection_down_end:
    ret

selection_load_map:
    ; Load the currently selected map
    ld      a, (level_select_choice)

    cp      0
    call    z, load_map_1

    cp      1
    call    z, load_map_2

    cp      2
    call    z, load_map_3

    cp      3
    call    z, load_map_4

    ret

selection_change_minimap:
    ; Load currently selected map
    ld      a, (level_select_choice)

    cp      0
    jr      z, selection_change_minimap_load_a

    cp      1
    jr      z, selection_change_minimap_load_b

    cp      2
    jr      z, selection_change_minimap_load_c

    cp      3
    jr      z, selection_change_minimap_load_d

    jr      selection_change_minimap_end
selection_change_minimap_draw:
    ld b, 4
    ld c, 2
    ld d, 22
    ld e, 11
    ld a, $74
    call util_draw_image
selection_change_minimap_end:
    ret
selection_change_minimap_load_a:
    ld      hl, minimap_data
    jr      selection_change_minimap_draw
selection_change_minimap_load_b:
    ld      hl, minimap_data+64
    jr      selection_change_minimap_draw
selection_change_minimap_load_c:
    ld      hl, minimap_data+128
    jr      selection_change_minimap_draw
selection_change_minimap_load_d:
    ld      hl, minimap_data+192
    jr      selection_change_minimap_draw


level_select_handle_input:
    call    input_is_w_down
    call      z, move_selection_up

    call    input_is_s_down
    call      z, move_selection_down

    call    input_is_d_down
    call      z, selection_load_map

    ret

; stores current attribute byte line of choice
level_select_choice_attr:
    defw $0000

level_select_choice:
    defb    3

wumbo_w:    defb 22, 9, 2,'SELECT LEVEL' 
            defb 13 
wumbo_x:    defb 22, 9, 21,'PREVIEW'
            defb 13
wumbo_a:    defb 22, 10, 7,'Level 1'
            defb 13
wumbo_s:    defb 22, 11, 7,'Level 2'
            defb 13
wumbo_d:    defb 22, 12, 7,'Level 3'
            defb 13
wumbo_e:    defb 22, 13, 7,'Level 4'
            defb 13
eo_wumbo_d: equ $