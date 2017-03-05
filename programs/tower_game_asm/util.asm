
util_wait_dur:
	ld c, 255
util_wait_dur_outer_loop:
	ld b, 255
util_wait_dur_inner_loop:
	djnz util_wait_dur_inner_loop
	dec c
	jp nz, util_wait_dur_outer_loop
	ret


; d = fill byte
util_clear_pixels:
	ld d, 0
	call util_fill_all_pixels
	ret

util_fill_all_pixels:
	ld hl, $4000
	ld c, 24
util_fill_pixels:
util_fill_pixels_outer_loop:
	ld (hl), d
	inc hl
	ld b, 255
util_fill_pixels_inner_loop:
	ld (hl), d
	inc hl
	djnz util_fill_pixels_inner_loop
	dec c
	jp nz, util_fill_pixels_outer_loop
	ret


util_clear_attrs:
	ld d, $38
	call util_fill_all_attrs
	ret

; d = fill byte
util_fill_all_attrs:
	ld hl, $5800
	ld c, 3
util_fill_attrs:
util_fill_attrs_outer_loop:
	ld (hl), d
	inc hl
	ld b, 255
util_fill_attrs_inner_loop:
	ld (hl), d
	inc hl
	djnz util_fill_attrs_inner_loop
	dec c
	jp nz, util_fill_attrs_outer_loop
	ret
