
; testable vram address -> 0x40E4
enemy_sprite_packing_test:

    ld      a, $01
    ld      (frame_counter), a    ; default sprite position (neutral)

    ld      a, $00          ; direction - move up (REMEBER- only 0,1,2,3)
    ld      h, $F0          ; base address $F0 + enemy type $0 = $F0
    ld      l, $00          ; if to be unhealthy, would be 80 since health is in MSB
    ld      de, $40FF
    
    call    enemy_sprite_draw_next_sprite

    ; Result:   left cell sprite addr: 0xF000
    ;           right cell sprite adr: 0xF020

    ret


; Function will pack necesary data into address for the *next* sprite bitmap

; Direction - Reg A
; Health    - Reg L (MSB no shifting required)
; Ticker    - grab from mem ( frame_counter )
; VRAM      - DE
; Enemy type- Reg H
; Do check if enemy is at rightmost point on screen, dont draw the second call

; NOTE TO BRING UP: Up and down sprite maps reversed?

; TODO:
; take vram as additional param (DONE - push vram address onto stack as first param before function call)
; do not calc sprite offset in draw method, just draw cell, call it twice to draw overlapping cells (DONE)
; calculate starting address of line that vertical draw method will use, i.e. it doesnt always start at beginning of color cell (NOT DONE)
; call horizontal draw method twice for the left cell and the right cell (NOT DONE)
; vertical: addr of sprite - hl
;           de - vram address
enemy_sprite_draw_next_sprite:
    ld      b, a            ; preserve direction for later when we're checking

    ; Pack direction into given l (l already contains health in MSB)
    rrc     a
    rrc     a
    rrc     a
    or      l

    ; Pack ticker into l
    ld      l, a
    ld      a, (frame_counter)
    sla     a
    sla     a
    sla     a
    or      l

    ; Save into L
    ld      l, a

    ; H should already be set 

    ; ---- Now, address packed, determine which draw method to call
    ;      based on direction

    ; Direction format:
    ; right 1 (left cell)   - 00
    ; right 2 (right cell)  - 01
    ; up                    - 10
    ; down                  - 11
    ; Do a bit test on MSB to see where to branch (1- vertical, 0 -horizontal)
    ; bit test sets z flag to OPPOSITE of that bit's value
    
    bit     1, b
    jp      nz, enemy_sprite_test_vertical

    ; MSB is 0, so its a move right
    ; DE unmodified and is vram address, keep as parameter
    ; HL is newly constructed bitmap data, passed in as well
    ; TODO: 
    ;       handle case of overflow (i.e. dont do second call if overflow imminent)
    call    enemy_sprite_draw_sprite_entire_cell

    ; Did first call, now make second call to cell to the right
    ; a should still contain the l we were previously using.
    ld      a, l
    or      $20             ; turn the packed direction info in l to a 01 (right 2)
    ld      l, a
    inc     e               ; go to next cell to the right on x-axis

    ; Check if we overflowed by masking out bottom 5 bits to determine if its 0
    ld      a, e
    and     $1F             ; bottom 5 bits
    cp      $0
    jr      z, enemy_sprite_skip_second_horiz_call  ; If it did overflow, don't make that second call just end

    call    enemy_sprite_draw_sprite_entire_cell

enemy_sprite_skip_second_horiz_call:

    jr      enemy_sprite_draw_next_sprite_end
enemy_sprite_test_vertical:
    ; Modify pixel address to start at proper offset dictated by ticker 
    ;   (either up or down)
    ; ticker val | shift up val | shift down val
    ; ------------------------------------------
    ;   0 - 0 - 0
    ;   1 - 6 - 2
    ;   2 - 4 - 4
    ;   3 - 2 - 6
    ; shift ticker by two for shift down val then sub from 8 for shift up val
    ld      a, (frame_counter)
    sla     a                   ; multiply by two
    ld      c, a                ; We're gonna trash a, so c will contain that frame_counter*2
    srl     b                   ; test lsb of direction, 0 - up, 1 - down
    
    jr      nc, enemy_sprite_draw_next_sprite_up

    ; else, we're moving down. no other processing, just adjust HL and call
    ld      a, d
    add     a, c
    ld      d, a
    ; DE and HL in place as parameters for VRAM and sprite bitmap addr
    ; NOTE: REGISTERS MAY BE TRASHED AFTER VERTICAL CALLS    
    call    enemy_sprite_sprite_move_vertical

    jr      enemy_sprite_draw_next_sprite_end
enemy_sprite_draw_next_sprite_up:
    ld      a, 7
    sub     c                   ; 8 - c gives us shift up val
    
    ; no other processing, just adjust vram address and call
    add     a, d
    ld      d, a
    ; DE and HL in place as VRAM & bitmap addr
    call    enemy_sprite_sprite_move_vertical

enemy_sprite_draw_next_sprite_end:
    ret

; de = addr of dest in vram
; hl = addr of src tile
enemy_sprite_sprite_move_vertical:
	push de

	; just draw a blank tile on top of us first
	; todo: make this more efficient?
	push hl
	push de
	ld hl, blank_tile
	ld a, d
	and $f8
	ld d, a
	call old_draw_tile
	pop de
	pop hl

	; load y2, y1, y0 into a
	ld a, d
	and 7

	; calculate the number of iterations until y2, y1, y0 == 0
	ld b, a
	ld a, 7
	sub b
	jp z, enemy_sprite_end_draw_tile_loop_a
	add 1
	ld b, a
	ld c, 0

enemy_sprite_draw_tile_loop_a:
	ldi
	inc d
	dec de
	djnz enemy_sprite_draw_tile_loop_a
enemy_sprite_end_draw_tile_loop_a:

	ld a, (hl)
	ld (de), a
	inc hl

	pop de

	ld a, d
	and 7
	jp z, enemy_sprite_end_draw_tile_loop_b
	ld b, a
	xor d
	ld d, a
	ld a, e
	add 32
	ld e, a
	jp nc, enemy_sprite_skip_fix
	ld a, d
	add 8
	ld d, a
enemy_sprite_skip_fix:

	; just draw a blank tile on top of us first
	; todo: make this more efficient?
	push hl
	push de
	push bc
	ld hl, blank_tile
	ld a, d
	and $f8
	ld d, a
	call old_draw_tile
	pop bc
	pop de
	pop hl

enemy_sprite_draw_tile_loop_b:
	ldi
	inc d
	dec de
	djnz enemy_sprite_draw_tile_loop_b
enemy_sprite_end_draw_tile_loop_b:

	ret
	


; sprite bitmap data address is in HL
; take vram address in DE
enemy_sprite_draw_sprite_entire_cell:
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
