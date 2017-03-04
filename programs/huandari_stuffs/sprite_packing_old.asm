org 32768

result:
    defw    0

; testable vram address -> 0x40E4
packing_test:
    ld      b, $00 ; Enemy type 2
    ld      c, $00 ; healthy
    ld      d, $00 ; moving right
    ld      e, $03 ; 4th tick

    ld      hl, $40E4
    push    hl
    call    draw_next_sprite
    inc     sp
    inc     sp
    ld      (result), hl
    ; Should be: F2 1011 1000
    ; Got: F2B8
    ; A1 = 1010 0001
    ; health = 1
    ; dir    = 01
    ; ticker = 00
    ret


; Function will pack necesary data into address for the *next* sprite bitmap
; Necessary data:
; - Enemy type - Reg B
; - Health     - Reg C
; - Direction  - Reg D
; - Ticker     - Reg E
; Fulfilled address will be returned in HL
; take vram as additional param
; do not calc sprite offset in draw method, just draw cell, call it twice to draw overlapping cells
; vertical: addr of sprite - hl
;           de - vram address
draw_next_sprite:
    push    ix
    ld      ix, 0
    add     ix, sp
    ; ---- Pack sprite info into addr for next sprite
    ; Pack ticker into l
    ld      a, e
    sla     a
    sla     a
    sla     a
    ; a = 3
    ; after shifts, a = 24 0001 1000

    ; Pack health into MSB of L
    rrc     c
    or      c
    ; c = 1, after, a = 1001 1000
    
    ; Pack direction info into L
    ; Shift right till it wraps around to proper spot
    push    de      ; want to preserve for later when checking direction 
    rrc     d
    rrc     d
    rrc     d
    or      d
    pop     de
    ; d = 01, after d = 0010 0000
    ; 1011 1000

    ; Save into L
    ld      l, a

    ; Pack enemy info into top H bit
    ld      a, $F0
    or      b
    
    ; Save into H
    ld      h, a
    ; ---- Now, address packed, determine which draw method to call
    ;      based on direction

    ; Proposed new direction format: 
    ; 00 - moving right (left half)
    ; 01 - moving up
    ; 10 - moving right (right half)
    ; 11 - moving down
    ; So that we can just do a rrca and check carry flag in branch instr
    
    ld      a, d
    rrca
    jp      c, test_vertical

    ; LSB is 0, so its a move right
    ; Can do other processing here, i.e. argument passing etc
    ld      e, (ix+4)
    ld      d, (ix+5)
    ; ld      e, $E4
    ; ld      d, $40
    call    draw_sprite_entire_cell

    jr      draw_next_sprite_end
test_vertical:
    ; Can do other processing here, if up/down are encoded in params or 
    ; have diff methods altogether
    call    sprite_move_vertical

draw_next_sprite_end:
    pop     ix
    ret

sprite_move_vertical:
    ret

; sprite bitmap data address is in HL
; take vram address in DE
; Can specify which sprite offset to use in reg A
draw_sprite_entire_cell:
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


    ld      sp, hl          ; load sprite bitmap data as stackpointer
    ex      de, hl          ; switch so that de -> sprite bitmap data addr, hl -> vram address


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

saved_sp:
    defw    0

defs $F000 - $

test_sprite_data:
defb $3c    ;   ####  
defb $5a    ;  # ## #
defb $ff    ; ########
defb $e7    ; ###  ###
defb $db    ; ## ## ##
defb $ff    ; ########
defb $7e    ;  ######
defb $e7    ; ###  ###
defb $3c    ;   ####  
defb $5a    ;  # ## #
defb $ff    ; ########
defb $e7    ; ###  ###
defb $db    ; ## ## ##
defb $fe    ; #######
defb $7f    ;  #######
defb $e0    ; ###    
defb $3c    ;   ####  
defb $5a    ;  # ## #
defb $ff    ; ########
defb $e7    ; ###  ###
defb $db    ; ## ## ##
defb $ff    ; ########
defb $7e    ;  ######
defb $e7    ; ###  ###
defb $3c    ;   ####  
defb $5a    ;  # ## #
defb $ff    ; ########
defb $e7    ; ###  ###
defb $db    ; ## ## ##
defb $7f    ;  #######
defb $fe    ; #######
defb $07    ;      ###