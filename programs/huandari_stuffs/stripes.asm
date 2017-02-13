
org 32768

start:
;    CALL    interrupt_setup
    LD      C, 4
    LD      B, 64

    CALL    pixel_addr          ; converts our raw x,y into the pixel address for use by draw_sprite
    LD      A, 0
    CALL    draw_sprite
    LD      D, 0
    CALL    sprite_move_right
    CALL    sprite_move_right
    CALL    sprite_move_right
    CALL    sprite_move_right
    CALL    sprite_move_right
    CALL    sprite_move_right
    CALL    sprite_move_right


primary_data_loop:              ; fall through to this routine, HALT until interrupt occurs and start all over again.
    HALT
    JR      primary_data_loop

; ============================sprites galore============================================

sprite_move_right:
    PUSH    HL

    ; Next sprite map to be loaded is in A. This is for the original cell
    ; Calculate corresponding map for the right cell and put it in A'
    LD      A, D
    ADD     8
    LD      D, A
    CALL    draw_sprite

    ; Drew the new original cell, now time to draw the cell to the right
    INC     L
    LD      A, D
    ADD     56
    CALL    draw_sprite

    POP     HL
    RET

; Assumes that pixel address is in HL
; Can specify which sprite offset to use in reg A
draw_sprite:
    PUSH    HL
    PUSH    DE
    LD      (saved_sp), sp


    ; Set stack pointer to beginning of sprite data
    ; Pop off two bytes at once and write them onto screen
    ; ....as to why its E and then D, not sure.

    ; NOTE: We can make this shorter. Replace with commented code.
    ;       However, we need to ensure that sprite addresses are clean
    ;       i.e. adding a number between 0-64 won't overflow the L register
    ;       That's what was giving us problem before. 
    ;       Add ASM directive to put sprite data on clean boundary?
    exx                     ; 4 cycles
    LD      HL, happy_dude  ; 10 cycles
    LD      D, 0
    LD      E, A
    ADD     HL, DE
    ;ADD     L               ; 4 cycles
    ;LD      L, A            ; 4 cycles
    LD      sp, HL          ; 6 cycles
    exx                     ; 4 cycles
                            ; ~32 cycles just for picking proper sprite...
                            ; NOTE: AFI

    ; Once we have the stack pointer set to the actual sprite address
    ; start popping in an unrolled loop fashion till we draw all 8 lines
    POP     DE
    LD      (HL), E
    INC     H
    LD      (HL), D
    INC     H
    POP     DE
    LD      (HL), E
    INC     H
    LD      (HL), D
    INC     H
    POP     DE
    LD      (HL), E
    INC     H
    LD      (HL), D
    INC     H
    POP     DE
    LD      (HL), E
    INC     H
    LD      (HL), D
    INC     H
    

    LD      sp, (saved_sp)
    POP     DE
    POP     HL
    RET



; ===================================logistics==========================================

;Code from:
;http://www.animatez.co.uk/computers/zx-spectrum/interrupts/
; Follows the ideas from lecture
interrupt_setup:
    DI                         ; disable interrupts
    LD HL,interrupt_handler    ; Address of the interrupt routine
    LD IX,$FFF0                ; Where to stick this code
    LD (IX+04h),$C3            ; Z80 opcode for JP
    LD (IX+05h),L              ; Where to JP to (in HL)
    LD (IX+06h),H
    LD (IX+0Fh),$18            ; Z80 Opcode for JR
    LD A,$39                   ; High byte address of vector table
    LD I,A                     ; Set I register to this
    IM 2                       ; Set Interrupt Mode 2
    EI                         ; Enable interrupts again

interrupt_handler:
    DI                          ; Disable interrupts
    PUSH    AF                  ; Preserve registers that we may overwrite
    PUSH    BC
    PUSH    DE
    ;PUSH    HL                 ; HL contains coordinates of the beginning of stripe, want effects to last so we dont save it.
    CALL    sprite_move_right
    ;POP     HL
    POP     DE
    POP     BC
    POP     AF
    EI                          ; Enable interrupts
    RETI                        ; Return from interrupt handler
    


sprite_move_right_old:
    LD      A, 4
    OUT     (254), A
    LD      A, D
    CALL    draw_sprite
    ADD     8
    CP      72
    JP      NZ, s_m_r_cont
    LD      D, 0
    JR      s_m_r_end
s_m_r_cont:
    LD      D, A
s_m_r_end:
    LD      A, 0
    OUT     (254), A
    RET


; B = Y pos, C = X pos
; Return addr in HL
; Based on lecture slides
pixel_addr:
    ; Want to get B into H, needs to look like: 010y7y6y2y1y0
    LD  A, B
    AND $07
    OR  $40
    LD  H, A
    LD  A, B        ; Now to retrieve y7y6
    RRCA            ; Shift them by 3 to the right
    RRCA
    RRCA
    AND $18
    OR  H           ; Combine the two. H should now be complete
    LD H, A

    LD  A, B        ; Now make lower 8 bits, need y5y4y3
    RLCA
    RLCA
    AND $E0
    LD  L, A
    LD  A, C
    AND $1F
    OR  L
    LD  L, A
    RET



  
happy_dude:
    defb    0, 0, 36, 0, 66, 60, 0, 0   ; default sprite, proper position
    defb    0, 0, 18, 0, 33, 30, 0, 0
    defb    0, 0, 9,  0, 16, 15, 0, 0
    defb    0, 0, 4,  0,  8,  7, 0, 0
    defb    0, 0, 2,  0,  4,  3, 0, 0
    defb    0, 0, 1,  0,  2,  1, 0, 0
    defb    0, 0, 0,  0,  1,  0, 0, 0
    defb    0, 0, 0,  0,  0,  0, 0, 0   ; do I really need this empty one?
    ; START OF LEFT-SHIFTED MAPS
    defb    0, 0,  0, 0,   0,  0,0, 0  
    defb    0, 0,  0, 0, 128,  0,0, 0
    defb    0, 0,128, 0,  64,128,0, 0
    defb    0, 0, 64, 0,  32,192,0, 0
    defb    0, 0, 32, 0,  16,224,0, 0
    defb    0, 0,144, 0,   8,240,0, 0
    defb    0, 0, 72, 0, 132,120,0, 0
    

happy_dude_addr_table:
    defw    happy_dude, happy_dude+8, happy_dude+16, happy_dude+24


saved_sp:
    defw    0