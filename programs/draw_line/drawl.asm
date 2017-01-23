
org 32768


start:
    LD  B, 127  ; ypos - note that since this reg is 8bit, 128 is max val
                ; so we'll need to figure something out
    LD  C, 0 ; xpos
    LD  D, 32
    CALL pixel_addr


xloop:
    LD  (HL), $FF
    INC HL
    DEC D
    JP  NZ, xloop
    RET


    ;LD (23677), HL
    ;CALL $2383
    ;INC B

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

    LD  A, B        ; Now make lower 8 bits, need y5y4y3
    RLCA
    RLCA
    AND $E0
    LD  L, A
    LD  A, C
    AND $1F
    OR  L
    RET



   
