
org 32768

start:
    LD      E, 0
    CALL    interrupt_setup

    LD      C, 4                ; 0000 0100
    LD      B, 80               ; 0100 0000
                                ; pixel address: 010|01000 | 000 00100

                                ; pix addr: 0100 1000|010
                                ; pix addr: 0100 0111   - switch to lower part of screen, end of cell

    CALL    pixel_addr          ; converts our raw x,y into the pixel address for use by draw_sprite
    ; LD      A, 8
    LD      A, 56               ; This holds our initial pick for which sprite bitmap to draw, 56 is regular sprite
    CALL    draw_sprite
    LD      D, 56               ; Register D is used in the sprite_move_* functions to represent what reg A represents above^
    ; CALL    sprite_move_right
    ; CALL    sprite_move_right
    ; CALL    sprite_move_right
    ; CALL    sprite_move_right
    ; CALL    sprite_move_right
    ; CALL    sprite_move_right
    ; CALL    sprite_move_right
    ; CALL    sprite_move_right
    ; CALL    sprite_move_right

    ; CALL    sprite_move_left
    ; CALL    sprite_move_right
    ; CALL    sprite_move_right
    ; CALL    sprite_move_right
    ; CALL    sprite_move_right
    ; CALL    sprite_move_right
    ; CALL    sprite_move_left
    ; CALL    sprite_move_left
    ; CALL    sprite_move_left
    ; CALL    sprite_move_left



primary_data_loop:              ; fall through to this routine, HALT until interrupt occurs and start all over again.
    HALT
    JR      primary_data_loop

; ============================sprites galore============================================

sprite_move_down:
    
    CALL    clear_cell          ; Much slower, XOR drawing may solve this

    LD      A, L
    ADD     $20
    LD      L, A

    LD      A, 56
    CALL    draw_sprite

    RET

sprite_move_up:
    ;PUSH    HL

    ; Change beginning address of HL to move up a few rows and then just draw sprite
    ; Challenges:
    ;       Case where sprite spans across two horizontally or 2 vertically
    ;       If we go up a few rows, we may end up in totally different section of screen

    CALL    clear_cell
    LD      A, L
    SUB     $20             ; Subtracts from y5y4y3 in the lower 8 bits, causes to go up 1 total color cell
    LD      L, A

    LD      A, 56            ; Will change based upon sprite's current offset from center
    CALL    draw_sprite

    ;POP     HL
    RET


; BUG:
;       If we move right into the next cell, and then move left all the way back to original cell
;       then there's a sprite artifact that remains in the cell to the right
sprite_move_left:
    PUSH    HL

    LD      A, D
    SUB     8
    LD      D, A
    CALL    draw_sprite

    ; TODO: Add condition to only do this if A < 56
    LD      A, D
    CP      56
    JP      NC, sprite_move_left_end
    
    ; The case where A < 56, we want to modify the cell to the left as well
    DEC     L
    LD      A, D
    ADD     64
    CALL    draw_sprite

sprite_move_left_end:
    POP     HL
    RET


; NOTE: Suffers from the same artifact bug as sprite_move_left above
sprite_move_right:
    PUSH    HL

    ; Next sprite map to be loaded is in A. This is for the original cell
    ; Calculate corresponding map for the right cell and put it in A'

    ; Current sprite position is held in D, increment it to the next position to the right
    ; and then check if we overflowed. If not, just draw the sprite in the new position
    LD      A, D
    ADD     8                                   ; Increment bitmap to the next position, i.e. +8
    CP      120                                 ; Did we overflow, are we past the list of acceptable sprites?
    JP      Z, sprite_move_right_overflow

    LD      D, A                                ; If we're safe, put new val back in D and draw the sprite
    CALL    draw_sprite

    ; Drew the new original cell, now time to draw the cell to the right
    ; This only occurs if we NEED to draw cell to the right, i.e. if sprite pos > 56 (normal position)
    LD      A, 56
    CP      D                                   ; 56 < D?
    JP      NC, sprite_move_right_end           ; If not, exit normally

    INC     L                                   ; Move one cell to the right
    LD      A, D                                ; Determine which sprite model to draw based off of current sprite pos
    SUB     64                                  ; These are always 64 apart (8 rows below current position)
    CALL    draw_sprite

sprite_move_right_end:
    POP     HL                                  ; NORMAL EXIT
    RET
sprite_move_right_overflow:                     ; OVERFLOW CASE EXIT
    POP     HL                                  ; Here, we permanently change the origin address to cell to the right
    INC     L                                   ; Our previous address means nothing to us, we don't care about it anymore.
    LD      D, 56                               ; Reset sprite position to default sprite position (centered, neutral)
    LD      A, D                                ; draw_sprite requires sprite pos in reg A
    CALL    draw_sprite
    RET                                         ; bye bye man

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
    LD      HL, happy_dude_bitmap  ; 10 cycles
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


clear_cell:
    PUSH    AF
    PUSH    HL
    LD      A, 8

c_c_loop:
    LD      (HL), $00
    INC     H
    DEC     A
    JP      NZ, c_c_loop

    POP     HL
    POP     AF
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
    ;PUSH    DE
    ;PUSH    HL                 ; HL contains coordinates of the beginning of stripe, want effects to last so we dont save it.
    
    INC     E
    LD      A, E
    CP      10
    JP      NZ, i_h_cont

    CALL    sprite_move_right
    LD      E, 0

i_h_cont:
    ;POP     HL
    ;POP     DE
    POP     BC
    POP     AF
    EI                          ; Enable interrupts
    RETI                        ; Return from interrupt handler
    

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



happy_dude_bitmap:
    defb    0, 0,  0, 0,   0,  0,0, 0  
    defb    0, 0,  0, 0, 128,  0,0, 0
    defb    0, 0,128, 0,  64,128,0, 0
    defb    0, 0, 64, 0,  32,192,0, 0
    defb    0, 0, 32, 0,  16,224,0, 0
    defb    0, 0,144, 0,   8,240,0, 0
    defb    0, 0, 72, 0, 132,120,0, 0
    defb    0, 0, 36, 0, 66, 60, 0, 0   ; default sprite, proper position
    defb    0, 0, 18, 0, 33, 30, 0, 0
    defb    0, 0, 9,  0, 16, 15, 0, 0
    defb    0, 0, 4,  0,  8,  7, 0, 0
    defb    0, 0, 2,  0,  4,  3, 0, 0
    defb    0, 0, 1,  0,  2,  1, 0, 0
    defb    0, 0, 0,  0,  1,  0, 0, 0
    defb    0, 0, 0,  0,  0,  0, 0, 0   ; do I really need this empty one?
 

saved_sp:
    defw    0