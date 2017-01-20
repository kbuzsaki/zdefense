; This program changes runs the border color through each of the possible 
; colors in a loop
;

org 32768

; repeatedly sets the border color using a modulo counter
; a = (de % (number of shifts + 8))
	ld de, 0
loop:
	ld a, d
	srl a
	srl a
	srl a
	srl a
	srl a
	push de
	call 8859
	pop de
	inc de
	jp loop

