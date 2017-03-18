death_screen_setup:
    ; hijack the interrupt handler
    di

    ld      hl, death_screen_interrupt_handler
    call    setup_interrupt_handler

    call    death_screen_prepare_screen

    ei
    jp      infinite_wait


death_screen_interrupt_handler:
    di

    ; Write level select text to the screen
    ld      a, 2
    call    5633
    ld      de, dead_text
    ld      bc, dead_text_eo-dead_text
    call    8252

    ei
    ret


death_screen_prepare_screen:
    ; For now just clear the screen
    call    util_clear_pixels
    call    util_clear_attrs
    ret

dead_text:    defb    22, 12, 8,'YOU DED'
dead_text_eo: equ $