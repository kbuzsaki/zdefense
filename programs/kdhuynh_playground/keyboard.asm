; includes code originally referenced from these websites:
; http://www.animatez.co.uk/computers/zx-spectrum/keyboard/
; https://chuntey.wordpress.com/2012/12/18/how-to-write-zx-spectrum-games-chapter-1/

org 32768
start:
programstart:
LD BC,$FBFE        ; Load BC with the row port address
IN A,(C)           ; Read the port into the accumulator
AND %00000001      ; Mask out the key we are interested in
LD E, A
JR Z,changebackground ; If the result is zero, then the key has been pressed...

LD BC,$FBFE        ; Load BC with the row port address
IN A,(C)           ; Read the port into the accumulator
AND %00000010      ; Mask out the key we are interested in
LD E, A
JR Z,printqwert ; If the result is zero, then the key has been pressed...

LD BC,$FBFE        ; Load BC with the row port address
IN A,(C)           ; Read the port into the accumulator
AND %00000100      ; Mask out the key we are interested in
LD E, A
JR Z,printqwert ; If the result is zero, then the key has been pressed...

LD BC,$FBFE        ; Load BC with the row port address
IN A,(C)           ; Read the port into the accumulator
AND %00001000      ; Mask out the key we are interested in
LD E, A
JR Z,printqwert ; If the result is zero, then the key has been pressed...

LD BC,$FBFE        ; Load BC with the row port address
IN A,(C)           ; Read the port into the accumulator
AND %00010000      ; Mask out the key we are interested in
LD E, A
JR Z,printqwert ; If the result is zero, then the key has been pressed...

jp programstart

keyunpress:
LD BC,$FBFE        ; Load BC with the row port address
IN A,(C)           ; Read the port into the accumulator
AND %00000001      ; Mask out the key we are interested in
jr NZ,programstart
jp keyunpress

changebackground:
pop de
inc de
ld a, e
call 8859
inc de
inc de
push de
ld a, 42
rst 16

       ld a,49             ; blue ink (1) on yellow paper (6*8).
       ld (23693),a        ; set our screen colours.
       call 3503           ; clear the screen.
jp keyunpress

printqwert:
LD D, 0
push DE
ld      a, 2
call    $1601
ld hl,qwert
pop DE

qwertcheck:
LD E, A
AND %00000001
jp Z, foundqwert
srl E
inc D
jp qwertcheck 

foundqwert:

ld hl, qwert
LD E, D
LD D, 0
add hl, DE  
ld a,(hl)
rst 16
jp printend

printhello:
ld      a, 2                  ; channel 2 = "S" for screen
call    $1601                 ; Select print channel using ROM

ld hl,line                    ; Print line
call printline

printline:                     ; Routine to print out a line
ld a,(hl)                     ; Get character to print
cp '$'                        ; See if it '$' terminator
jp z,printend                 ; We're done if it is
rst 16                        ; Spectrum: Print the character in 'A'
inc hl                        ; Move onto the next character
jp printline                  ; Loop round

printend:
jp programstart

programend:
ret


; Data
line:    defb 'Hello, world.',13,'$'

qwert:   defb 'qwert'




