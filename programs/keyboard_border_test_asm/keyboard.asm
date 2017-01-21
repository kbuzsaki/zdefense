; This program reads from keyboard input and sets the border color depending
; on which keys are depressed.
;
; the behavior is as follows:
;   start with black
;   if q is pressed, add red
;   if w is pressed, add green
;   if e is pressed, add blue
;   set the border color
;   repeat
;
; so just q pressed sets the color to red, just w sets the color to green,
; q and w set the color to yellow.
;
; the full combinations are:
;   none - black
;    q   - red
;     w  - green
;      e - blue
;    qw  - yellow
;    q e - magenta
;     we - cyan
;    qwe - white
;
; the program also prints the bits of the color value that the border is set
; to every time the value changes
;

org 32768

    ; initialize stored to 0
    ld b, 0
    push bc

main_loop_b:
    ; read keyboard into e (reading key state of qwert)
    ld bc, $fbfe
    in a, (c)
    ld e, a

    ; default is black
    ld a, 0

    ; q adds red
test_q:
    bit 0, e
    jp nz, test_w
    add a, 2

    ; e adds green
test_w:
    bit 1, e
    jp nz, test_e
    add a, 4

    ; e adds blue
test_e:
    bit 2, e
    jp nz, set_color
    add a, 1

    ; set border color
set_color:
    push af
    call 8859
    pop af

    ; compare against previous value
    pop bc
    push af
    cp b
    jp z, main_loop_b

    call print_8_bits
    call new_line

    jp main_loop_b




; in progress: read from keyboard and print it as bits
readkey:
    ld bc, $fbfe
    in a, (c)
    call print_8_bits
    call new_line
    jp readkey

jp end


; prints 0 to 63 in binary
    ld a, 0
main_loop_a:
    push af
    call print_8_bits
    call new_line
    pop af
    inc a
    cp 64
    jp nz, main_loop_a

jp end


; prints the 8 bits in a
print_8_bits:
    ld b, 8

print_bits:
    ld c, a
    rlc c

print_8_bits_loop:
    push bc
    ld a, c
    call print_bit
    pop bc             
    rlc c
    djnz print_8_bits_loop
    ret

; prints the least significant bit of a
print_bit:
    and 1
    cp 1
    jp z, print_bit_zero

    ld a, 48
    rst 16
    ret

print_bit_zero:
    ld a, 49
    rst 16
    ret

new_line:
    ld a, 13
    rst 16
    ret


jp end


; print the printable ascii characters
    ld c, 48
loop:
    push bc
    ld a, c
    rst 16
    pop bc

    inc c

    ld a, c
    cp 127
    ; jump conditionally on carry flag
    jp c,loop

end:
