; Entry point to the death screen.
; Hijacks the interrupt handler and does any ohter setup.
death_screen_setup:
    ; hijack the interrupt handler
    di

    ld      hl, death_screen_interrupt_handler
    call    setup_interrupt_handler

    ei
    jp      infinite_wait


; Interrupt point for death screen.
; Increments counters as usual. 
death_screen_interrupt_handler:
    di

    call    increment_frame_counters

    ; Move existing sprites
	ld a, (sub_frame_counter)
	and 3
    cp 1
	call z, death_screen_animation_handler


; 	ld a, (real_frame_counter)
; 	; and $28
;     and 8
;     jr  nz, death_screen_interrupt_handler_set_borde_black
;     ld  a, 2
;     out ($fe), a
;     jr  death_screen_interrupt_handler_end

; death_screen_interrupt_handler_set_borde_black:
;     ld a, 0
;     out ($fe), a
death_screen_interrupt_handler_end:
    ei
    ret


; The main animation handler. Functions oddly.
; This simply calls the "stage" pointer function. The stage pointer points
; to the function that the current animation is utilizing. When that part of the animation
; finisheds, a 'prep' stage function is called and changes this stage function pointer to 
; the next stage's function.
death_screen_animation_handler:
    ; Check if first stage is done
    ld      hl, top_third_stage_function
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl

    ; NOTE: Since this is a jump, that function has a ret, so don't do anything
    ;       after this jump!
    jp      (hl)

    ret

; After the first part of the animation finishes, this function is called to prep data
; for the second stage's takeover. The 'stage' pointer function is changed in here as well
; so that next time interrupt runs, it will call the appropriate next stage function
prep_second_stage:
    ; Clear the pixels
    call    util_clear_pixels

    ; Write the death text
    ld      a, 2
    call    5633
    ld      de, dead_text
    ld      bc, dead_text_eo-dead_text
    call    8252

    ; Self-modifying code, change the attr byte to black.
    ; We are re-using the stage 1 function. Just changing data.
    ld      de, death_screen_closing_animation
    inc     de
    ld      a, 2
    ld      (de), a

    ; fill in new addresses.
    ; this will cause the closing animation function to go backwards, from middle -> outwards
    ; instead of outwards -> middle
    ld      ix, top_third_next_offset
    ld      (ix+0), $80
    ld      (ix+1), $59
    ld      (ix+2), $7F
    ld      (ix+3), $59
    ld      (ix+4), 13

    ; The next stage handler is the do-nothing stage. Once closing animation
    ; is done it'll call this pointer. 
    ld      hl, top_third_next_stage_prep_func
    ld      de, death_screen_ending_prep
    ld      (hl), e
    inc     hl
    ld      (hl), d
    
    ret

; This is a dummy handler. Nothing is done.
death_screen_do_nothing:
    ld  a, 0
    out ($fe), a
    ret

; Called after the second stage is finished.
; Prepares the animation for the last step: doing nothing.
; If another animation stage were to be added, prep would go here.
death_screen_ending_prep:
    ; Rewrite the stage handler
    ld      hl, top_third_stage_function
    ld      de, death_screen_do_nothing
    ld      (hl), e
    inc     hl
    ld      (hl), d

    ret

; The main stage function for both stage 1 and stage 2, simply called differently.
death_screen_closing_animation:
    ld      c, $82

    ; Check the counter
    ld      hl, top_third_counter
    ld      a, (hl)
    dec     a

    ; Paint last line as different attr byte
    cp      1
    jr      z, death_screen_closing_animation_last_lines_attr

    ; If we're done, chain into prepping for the next function to take over
    cp      0
    jr      nz, death_screen_closing_animation_draw_lines

    ; Prep for the second stage
    ld      hl, top_third_next_stage_prep_func
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    ; NOTE: This function call is a jump instead of a call, and that function has
    ;       a ret statement, so it'll never return here. DONT DO ANYTHING AFTER THIS
    jp      (hl)
    ret
death_screen_closing_animation_draw_lines:
    ; Store the updated counter
    ld      (hl), a

    ; Draw the next line of attr bytes both on the top of screen and the bottom
    call    draw_next_line_downward
    call    draw_next_line_upward
    ret
death_screen_closing_animation_last_lines_attr:
    ; Special case for when we are at the center of the screen
    ld      c, $42
    jr      death_screen_closing_animation_draw_lines



; Draws the next line of attr bytes going downward (from top)
draw_next_line_downward:
    ld      ix, top_third_next_offset
    ld      l, (ix+0)
    ld      h, (ix+1)

    xor     a
    call    fill_screen_attr_line

    ld      (ix+0), l
    ld      (ix+1), h
    ret

; Draws the next line of attr bytes going upward (from bottom)
draw_next_line_upward:
    ld      ix, top_third_next_offset
    ld      l, (ix+2)
    ld      h, (ix+3)

    ld      a, 1
    call    fill_screen_attr_line

    ld      (ix+2), l
    ld      (ix+3), h
    ret


; Draws a line (32 cells) of consecutive attr bytes
; hl - vram address where the line starts
;  c - attr byte to fill with
;  a - 0 increment addr, 1 decrement
fill_screen_attr_line:
    push    bc
    ld      b, 32

fill_screen_attr_line_loop:
    ld      (hl), c

    cp      1
    jr      z, fill_screen_attr_line_loop_rev
    inc     hl
    jr      fill_screen_attr_line_loop_cont
fill_screen_attr_line_loop_rev:
    dec     hl
fill_screen_attr_line_loop_cont:
    djnz    fill_screen_attr_line_loop

    pop     bc
    ret


; ------------ Data necessary for death screen animations
top_third_next_offset:
    defw    $5800
    defw    $5AFF
top_third_counter:
    defb    13
top_third_stage_function:
    defw    death_screen_closing_animation
top_third_next_stage_prep_func:
    defw    prep_second_stage

dead_text:    defb    22, 11, 12,'YOU DIED.'
              defb    13
              defb    22, 12, 6,'ARE YOU TRULY HAPPY?'
dead_text_eo: equ $
; ------------------------------------------------------
