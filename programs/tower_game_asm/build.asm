

; input:
;  de - the xy coordinates to scan through build_tile_xys for
; output:
;   a - the build_tile number, or $ff if not found
build_find_build_tile_index:
	; the pointer
	ld hl, (build_tile_xys)
	; the counter
	ld b, 0

build_find_build_tile_index_loop:
	; first check if we hit the end
	ld a, (hl)
	cp $ff
	jp z, build_find_build_tile_index_not_found
	
	; increment hl for y coordinate even if we don't jump
	inc hl

	; then check the x coordinate
	cp d
	jp nz, build_find_build_tile_index_loop_increment

	; then check the y coordinate
	ld a, (hl)
	cp e
	jp nz, build_find_build_tile_index_loop_increment

	; if we get this far, we found the index!
	ld a, b
	ret

build_find_build_tile_index_loop_increment:
	inc hl
	inc b
	jp build_find_build_tile_index_loop

	; if we hit the end, then 
build_find_build_tile_index_not_found:
	ld a, $ff
	ret



build_basic_tower:
    push de
    push hl
    push bc

    ; Check if the cursor is within a valid build spot
    ld      hl, (build_tile_xys)
    
    
build_basic_tower_xy_check:

    ld      a, (hl)             ; Load x coord
    ; Check if we've reached the end of array
    cp      $FF
    jr      z, build_basic_tower_end

    ; Check if x coords match
    inc     l                   ; Increment now in case we jump out, addr still valid
    cp      d
    jr      nz, build_basic_tower_xy_check_conditional

    ld      a, (hl)             ; Load y coord
    ; Check if y coords match
    cp      e
    jr      nz, build_basic_tower_xy_check_conditional

    ; If we've reached this far we've won. Go ahead and draw. You deserve it.
    ;
    ; Just kidding dude. Did you really think I'd just let you go man?
    ; How much dolla u got
    ld      a, (money_tens)
    cp      0
    jr      z, build_basic_tower_end

    sub     1
    ld      (money_tens), a

    ; Register the tower with our structure

    ; First, calculate ranking address for further data
    ld      b, 3        ; tower type 4
    ld      c, 0        ; level 0 (default level)
    call    build_calculate_tower_rank
    ld      c, a        ; temp store for later when we re-use it again
    call    build_register_new_tower
    jr      build_basic_tower_draw

; every day we stray further from gods light with labels as long as this
build_basic_tower_xy_check_conditional:
    inc     l
    jr      build_basic_tower_xy_check


build_basic_tower_draw:
    ; Get info from the tower data sheet like attr byte and sprite sheet addr
    ld b, $9b   ; high byte of addr is 98, i.e. 98xx
                ; c already contains low byte (i.e. rank)
	ld c, 0
    ; ld c, $60
    
    ;Set the pixel bytes
    call cursor_get_cell_addr

    ld d, h
    ld e, l
    
    ; note: endianness in storage is weird.
    ; TODO: Maybe using IX for this nonsense may make things cleaner and less CT
    ld a, (bc)
    ld l, a
    inc c
    ld a, (bc)
    ld h, a
    
    ; ld hl, tower_basic
    call util_draw_tile

    ;Set the attribute byte

    ; Add to tower data address to get to attr byte loc
    ld a, 5
    add a, c
    ld c, a
    ld a, (bc)
    ; ld a, $23
    ld (cursor_old_attr), a

build_basic_tower_end:
    pop bc
    pop hl
    pop de
    ret

; b - tower type (0..3)
; c - tower level (0..3)
; Final constructed rank byte stored in a 
build_calculate_tower_rank:
    push    de
    push    bc

    ; de now stores address to put our new tower info
    ; x and y should be in hl
    ; need to build 1byte for rank
    ; STRUCTURE:
    ;           0 | tower type (2bits) | tower level (2bits) | 000
    ;   - Tower types 1,2,3,4
    ;   - Levels 1,2,3 (could add a fourth)
    
    xor     a
    ; Shift b into position
    rrc     b
    rrc     b
    rrc     b
    or      b

    ; Shift c
    sla     c
    sla     c
    or      c

    pop     bc
    pop     de
    ret

; Add new tower of certain type at default rank
; to be recorded in the global towers array
; a - constructed rank byte
; hl - xy coords of new tower
;      can pass VRAM addr into hl instead to store that.
build_register_new_tower:
    push    de
    push    bc

	; find the build tile index of the tower
	call build_find_build_tile_index
	; find the point in the array to build at
	ld hl, build_tile_towers
	ld l, a
	; build the tower
	ld (hl), 1


    pop     bc
    pop     de
    ret

build_laser_tower:
    push de
    ;Set the attribute byte first
    ld a, $27
    ld (cursor_old_attr), a

    ;Set the pixel bytes
    call cursor_get_cell_addr
    ld d, h
    ld e, l
    ld hl, tower_zap
    call util_draw_tile
    pop de
    ret

build_bomb_tower:
    push de
    ;Set the attribute byte first
    ld a, $22
    ld (cursor_old_attr), a

    ;Set the pixel bytes
    call cursor_get_cell_addr
    ld d, h
    ld e, l
    ld hl, tower_bomb_upgrade
    call util_draw_tile
    pop de
    ret

build_slow_tower:
    push de
    ;Set the attribute byte first
    ld a, $21
    ld (cursor_old_attr), a

    ;Set the pixel bytes
    call cursor_get_cell_addr
    ld d, h
    ld e, l
    ld hl, tower_obelisk
    call util_draw_tile
    pop de
    ret

