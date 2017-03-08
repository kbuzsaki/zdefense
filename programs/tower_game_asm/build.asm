
build_basic_tower:
    push de

    ;Set the attribute byte first
    ld a, $23
    ld (cursor_old_attr), a
    
    ;Set the pixel bytes
    call cursor_get_cell_addr
    ld d, h
    ld e, l
    ld hl, tower_basic
    call util_draw_tile

    pop de
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

