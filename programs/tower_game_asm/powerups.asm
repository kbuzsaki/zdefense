powerups_init:
    call powerups_prepare_map_d

    ret


powerups_prepare_map_b:
    ld d, 2
    ld e, 2
    call powerups_draw_small_lake

    ld a, 3
    ld (powerup_one_x), a
    ld a, 3
    ld (powerup_one_y), a

    ld d, 10
    ld e, 10
    call powerups_draw_small_lake

    ld a, 11
    ld (powerup_two_x), a
    ld a, 11
    ld (powerup_two_y), a

    ret

powerups_prepare_map_d:
    ld d, 2
    ld e, 2
    call powerups_draw_small_lake

    ld a, 3
    ld (powerup_one_x), a
    ld a, 3
    ld (powerup_one_y), a

    ld d, 19
    ld e, 12
    call powerups_draw_small_lake

    ld a, 20
    ld (powerup_two_x), a
    ld a, 13
    ld (powerup_two_y), a

    ret


powerups_spawn_randomly:

    ; skip chance to spawn powerup_one if it exists already
    ld a, (powerup_one)
    cp 0
    jp nz, powerups_spawn_randomly_skip_one

    ; skip chance to spawn if cursor is on powerup_one spot
    ld a, (cursor_x)
    ld b, a
    ld a, (powerup_one_x)
    cp b
    jp nz, powerups_spawn_randomly_spawn_one 

    ld a, (cursor_y)
    ld b, a
    ld a, (powerup_one_y)
    cp b
    jp z, powerups_spawn_randomly_skip_one 

  powerups_spawn_randomly_spawn_one:

    ld a, r
    and $aa
    call z, powerups_spawn_powerup_one

  powerups_spawn_randomly_skip_one:

    ; skip chance to spawn powerup_two if it exsts already
    ld a, (powerup_two)
    cp 0
    jp nz, powerups_spawn_randomly_skip_two

    ;skip chance to spawn if cursor is on powerup_two spot
    ld a, (cursor_x)
    ld b, a
    ld a, (powerup_two_x)
    cp b
    jp nz, powerups_spawn_randomly_spawn_two 

    ld a, (cursor_y)
    ld b, a
    ld a, (powerup_two_y)
    cp b
    jp z, powerups_spawn_randomly_skip_two 

  powerups_spawn_randomly_spawn_two:


    ld a, r
    and $bb
    call z, powerups_spawn_powerup_two

  powerups_spawn_randomly_skip_two:

    ret

powerups_spawn_powerup_one:
    ld a, (powerup_one)

    ld bc, powerup_one
    ld a, (powerup_one_x)
    ld d, a
    ld a, (powerup_one_y)
    ld e, a
    call powerups_spawn_powerup

    ret

powerups_spawn_powerup_two:
    ld bc, powerup_two
    ld a, (powerup_two_x)
    ld d, a
    ld a, (powerup_two_y)
    ld e, a
    call powerups_spawn_powerup

    ret
    
; bc = address of powerup_one or powerup_two
; d = x for powerup cell
; e = y for powerup cell
powerups_spawn_powerup:
    ; the lower bits seem to be more random than upper bits
    ld a, r
    rr a
    rr a
    rr a
    rr a

    sub 40
    jp pe, powerups_spawn_slow
    
    sub 40
    jp pe, powerups_spawn_bomb

    sub 40
    jp pe, powerups_spawn_zap 
    
    sub 40
    jp pe, powerups_spawn_money

  powerups_spawn_life:
    ld hl, heart
    ld a, $01 ; set the powerup to be the value for the health powerup
    ld (bc), a
    ld c, $0a ; desired attr byte value
    jp powerups_spawn_draw

  powerups_spawn_money:
    ld hl, dollar
    ld a, $02 ; set the powerup to be the value for the money powerup
    ld (bc), a
    ld c, $0c ; desired attr byte value
    jp powerups_spawn_draw

  powerups_spawn_zap:
    ld hl, lightning
    ld a, $03
    ld (bc), a
    ld c, $0e
    jp powerups_spawn_draw

  powerups_spawn_bomb:
    ld hl, bomb
    ld a, $04
    ld (bc), a
    ld c, $08
    jp powerups_spawn_draw

  powerups_spawn_slow:
    ld hl, snowflake
    ld a, $05
    ld (bc), a
    ld c, $0d
    jp powerups_spawn_draw

  powerups_spawn_draw:
    push hl
    call cursor_get_cell_attr
    ld (hl), c
    pop hl

    push hl
    call cursor_get_cell_addr
    ex de, hl
    pop hl
    call util_draw_tile

    ret

; bc = address of powerup_one or powerup_two
; d = x for powerup cell
; e = y for powerup cell
powerups_clear_powerup:
    ld a, 0
    ld (bc), a

    call cursor_get_cell_addr
    ex de, hl
    ld hl, blank_tile
    call util_draw_tile
    ret

; bc = address of powerup_one or powerup_two
; d = x for powerup cell
; e = y for powerup cell
powerups_get_powerup:
    ld a, (bc)

    cp $01
    call z, powerups_get_health

    cp $02
    call z, powerups_get_money

    cp $03
    call z, powerups_get_zap

    cp $04
    call z, powerups_get_bomb

    cp $05
    call z, powerups_get_slow

    ret


powerups_get_health:
    call status_inc_health
    call powerups_clear_powerup
    ret

powerups_get_money:
    call status_inc_money
    call powerups_clear_powerup
    ret

powerups_get_zap:
    push de
    call status_inc_zap
    pop de
    call powerups_clear_powerup
    ret

powerups_get_bomb:
    push de
    call status_inc_bomb
    pop de
    call powerups_clear_powerup
    ret

powerups_get_slow:
    push de
    call status_inc_slow
    pop de
    call powerups_clear_powerup
    ret

; Draws a 3x3 lake
;
; d = x for upper left cell 
; e = y for upper left cell
powerups_draw_small_lake:
    
    ; attr byte
    ld b, $0c
    
    push de
    call cursor_get_cell_attr
    ld (hl), b
    call cursor_get_cell_addr
    ex de, hl
    ld hl, small_lake
    call util_draw_tile
    pop de

    inc d
    push de
    call cursor_get_cell_attr
    ld (hl), b 
    call cursor_get_cell_addr
    ex de, hl
    ld hl, small_lake+8
    call util_draw_tile
    pop de

    inc d

    push de 
    call cursor_get_cell_attr
    ld (hl), b
    call cursor_get_cell_addr
    ex de, hl
    ld hl, small_lake+16
    call util_draw_tile
    pop de

    dec d 
    dec d
    inc e

    push de 
    call cursor_get_cell_attr
    ld (hl), b
    call cursor_get_cell_addr
    ex de, hl
    ld hl, small_lake+8*3
    call util_draw_tile
    pop de

    inc d

    push de 
    call cursor_get_cell_attr
    ld (hl), b
    call cursor_get_cell_addr
    ex de, hl
    ld hl, small_lake+8*4
    call util_draw_tile
    pop de

    inc d

    push de 
    call cursor_get_cell_attr
    ld (hl), b
    call cursor_get_cell_addr
    ex de, hl
    ld hl, small_lake+8*5
    call util_draw_tile
    pop de

    dec d 
    dec d
    inc e

    push de 
    call cursor_get_cell_attr
    ld (hl), b
    call cursor_get_cell_addr
    ex de, hl
    ld hl, small_lake+8*6
    call util_draw_tile
    pop de

    inc d

    push de 
    call cursor_get_cell_attr
    ld (hl), b
    call cursor_get_cell_addr
    ex de, hl
    ld hl, small_lake+8*7
    call util_draw_tile
    pop de

    inc d

    push de 
    call cursor_get_cell_attr
    ld (hl), b
    call cursor_get_cell_addr
    ex de, hl
    ld hl, small_lake+8*8
    call util_draw_tile
    pop de

    ret

    





