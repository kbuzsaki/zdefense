music_entry_point:
	ld hl, music_note_index
	ld a, $3c
	and (hl)
	inc (hl)
	rrca
	rrca
	ld b, 0
	ld c, a
	ld hl, music_sequence
	add hl, bc
	ld e, (hl)
	ld ixl, e
	ld a, ($fdcc)
	ld c, 6

music_note_loop:
	out ($fe), a
	dec e
	jp nz, music_decrement_duration_counter
	ld e, ixl
	xor $10

music_decrement_duration_counter:
	djnz music_note_loop
	dec c
	jp nz, music_note_loop

	ret

music_sequence:
	defb 151
	defb 127
	defb 135
	defb 127
	defb 151
	defb 0
	defb 151
	defb 135
	defb 127
	defb 85
	defb 101
	defb 0
	defb 0
	defb 0
	defb 0
	defb 0

music_sequence_1:
	defb 120
	defb 120
	defb 60
	defb 0
	defb 80
	defb 80
	defb 0
	defb 85
	defb 0
	defb 90
	defb 0
	defb 101
	defb 0
	defb 120
	defb 101
	defb 90


music_note_index:
	defb $00
