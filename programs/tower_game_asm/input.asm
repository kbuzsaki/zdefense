is_w_down:
    ld bc, $fbfe
    in b, (c)
	bit 1, b
	jp z, set_a
	ld a, 0
	ret
is_r_down:
    ld bc, $fbfe
    in b, (c)
	bit 3, b
	jp z, set_a
	ld a, 0
	ret
is_a_down:
    ld bc, $fdfe
    in b, (c)
	bit 0, b
	jp z, set_a
	ld a, 0
	ret
is_s_down:
    ld bc, $fdfe
    in b, (c)
	bit 1, b
	jp z, set_a
	ld a, 0
	ret
is_d_down:
    ld bc, $fdfe
    in b, (c)
	bit 2, b
	jp z, set_a
	ld a, 0
	ret
set_a:
	ld a, 1
	ret

