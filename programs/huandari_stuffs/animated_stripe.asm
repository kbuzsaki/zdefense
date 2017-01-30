; Semi-Accident Program that draws a stripe on lower half of screen and animates it to slide to the right at every screen refresh
; INITIAL OBJECTIVE: To make the stripe slide to the right, then wrap back around and start at the beginning of the line again.
; What really happens: Stripe slides to the right, when it reaches the end it wraps around but ONE cell lower. This 
;                       happens every time until we get to the bottom of the screen division, then it wraps around to the top of
;                       the divisision. Shows the intuitiveness of just increasing the screen address and letting it overflow itself.


org 32768




; NOTE: 184 is max value for B, last cell
start:
    LD      C, 4    ; xpos
    LD      B, 160  ; ypos, we want 4 rows below the THIRD division of the screen. 
                    ; every division is 64 lines apart, 8 color cells. So third division
                    ; starts at 64*2 = 128. We want the 4th CELL down, so 4*8 = 32, 128+32=160
    LD      E, $01  ; will contain our attribute byte info, we'll change it every time we draw a new cell

    CALL    interrupt_setup     ; registers our handler with the zx
    
    CALL    create_stripe       ; create the initial stripe in its starting position

primary_data_loop:              ; fall through to this routine, HALT until interrupt occurs and start all over again.
    HALT
    JR      primary_data_loop


; ==========================================================
; Initial position for first box in B (ypos), C (xpos)
; two extra boxes will be drawn to the right
; HL will be back to its original contents, pointing to 
; the pixel address of the FIRST cell
create_stripe:
    CALL    pixel_addr  ; translate to official addr first
    
    LD      A, 5

    PUSH    HL
c_s_loop:
    CALL    fill_cell

    ; CALL    change_cell_attr
    
    ; Increment to next cell on the right
    INC     L
    DEC     A
    JP      NZ, c_s_loop
    POP     HL
    RET

;==========================================================

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
    LD      A, 2
    OUT     (254), A
    CALL    stripe_move_right
    LD      A, 1
    OUT     (254), A
    ;POP     HL
    POP     DE
    POP     BC
    POP     AF
    EI                          ; Enable interrupts
    RETI                        ; Return from interrupt handler


; Assume stripe address of FIRST block is in HL
; Assume 4 other blocks are immediately to the right of it
; At end of function, we'll reset HL to be as it was when we first went in.
stripe_move_right:
    
    ; first clear the cell of the first block
    CALL    clear_cell

    ; next add a new block to the end of our strpe, to the right side
    PUSH    HL                  ; save the pixel address so after we bash it we can return the original.
    LD      A, L
    ADD     5                   ; advance our line by 5 blocks, want to draw at the end of the stripe
    LD      L, A
    CALL    fill_cell
    ; CALL    change_cell_attr

    ; reset L back to point to the NEW first block of the stripe
    POP     HL
    INC     L                   ; The NEW block is +1 x position from the original location of block
    RET


; Assume our attribute byte is in E
change_cell_attr:
    PUSH    HL
    PUSH    AF
    CALL    attr_addr
    LD      (HL), E

    ; increment E properly
    ; NOTE: A modulo function may make sense, however I am too lazy.
    ;       So if statements it is.
    LD      A, E
    CP      7                   ; If E == 7 then we don't want to overflow, so just reset E to 0
    JP      NZ, change_cell_attr_end
    LD      E, 0
change_cell_attr_end:
    INC     E
    POP     AF
    POP     HL
    RET


; pixel screen address in HL
fill_cell:
    PUSH    AF
    PUSH    HL
    LD      A, 8

f_c_loop:
    LD      (HL), $FF
    INC     H

    DEC     A
    JP      NZ, f_c_loop

    POP     HL
    POP     AF
    RET            


; Analogous to fill_cell, maybe just make one function to handle both?
clear_cell:
    PUSH    AF
    PUSH    HL
    LD      A, 8

c_c_loop:
    LD      (HL), $00
    INC     H
    DEC     A
    JP      NZ, c_c_loop

    ;LD      A, H
    ;SUB     8
    ;LD      H, A
    POP     HL
    POP     AF
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

; REQ: HL contain valid pixel address
; RET: Returns that block's attribute byte address in DE, HL preserved
attr_addr:
    PUSH    AF
    LD      A, H
    RRCA
    RRCA
    RRCA
    AND     $03
    OR      $58
    LD      H, A
    POP     AF
    RET