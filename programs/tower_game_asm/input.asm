;; Behavior:
;;   If the key is pressed
;;     set a to 1
;;   Else
;;     set a to 0

input_is_w_down:
    ld bc, $fbfe
    in b, (c)
	bit 1, b
	jp z, input_set_a
	ld a, 0
	ret

input_is_r_down:
    ld bc, $fbfe
    in b, (c)
	bit 3, b
	jp z, input_set_a
	ld a, 0
	ret

input_is_a_down:
    ld bc, $fdfe
    in b, (c)
	bit 0, b
	jp z, input_set_a
	ld a, 0
	ret

input_is_s_down:
    ld bc, $fdfe
    in b, (c)
	bit 1, b
	jp z, input_set_a
	ld a, 0
	ret

input_is_d_down:
    ld bc, $fdfe
    in b, (c)
	bit 2, b
	jp z, input_set_a
	ld a, 0
	ret

input_is_g_down:
    ld bc, $fdfe
    in b, (c)
	bit 4, b
	jp z, input_set_a
	ld a, 0
	ret

input_is_1_down:
    ld bc, $f7fe
    in b, (c)
    bit 0, b
    jp z, input_set_a
    ld a, 0
    ret

input_is_2_down:
    ld bc, $f7fe
    in b, (c)
    bit 1, b
    jp z, input_set_a
    ld a, 0
    ret

input_is_3_down:
    ld bc, $f7fe
    in b, (c)
    bit 2, b
    jp z, input_set_a
    ld a, 0
    ret

input_is_4_down:
    ld bc, $f7fe
    in b, (c)
    bit 3, b
    jp z, input_set_a
    ld a, 0
    ret

input_is_5_down:
    ld bc, $f7fe
    in b, (c)
    bit 4, b
    jp z, input_set_a
    ld a, 0
    ret

input_is_6_down:
    ld bc, $effe
    in b, (c)
    bit 4, b
    jp z, input_set_a
    ld a, 0
    ret

input_is_7_down:
    ld bc, $effe
    in b, (c)
    bit 3, b
    jp z, input_set_a
    ld a, 0
    ret

input_is_8_down:
    ld bc, $effe
    in b, (c)
    bit 2, b
    jp z, input_set_a
    ld a, 0
    ret

input_is_9_down:
    ld bc, $effe
    in b, (c)
    bit 1, b
    jp z, input_set_a
    ld a, 0
    ret

input_is_0_down:
    ld bc, $effe
    in b, (c)
    bit 0, b
    jp z, input_set_a
    ld a, 0
    ret

input_set_a:
	ld a, 1
	ret

