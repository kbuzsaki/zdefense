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

input_set_a:
	ld a, 1
	ret

