; includes code originally referenced from 
; http://www.animatez.co.uk/computers/zx-spectrum/keyboard/


org 32768
start:
programstart:
LD BC,($FB)        ; Load BC with the row port address
IN A,(C)           ; Read the port into the accumulator
AND %00000001      ; Mask out the key we are interested in
JR Z,printhello ; If the result is zero, then the key has been pressed...
jp programstart

printhello:
ld      a, 2                  ; channel 2 = "S" for screen
call    $1601                 ; Select print channel using ROM

ld hl,line                    ; Print line
call printline
ret                        

printline:                     ; Routine to print out a line
ld a,(hl)                     ; Get character to print
cp '$'                        ; See if it '$' terminator
jp z,printend                 ; We're done if it is
rst 16                        ; Spectrum: Print the character in 'A'
inc hl                        ; Move onto the next character
jp printline                  ; Loop round

printend:
ret

programend:
ret


; Data
line:    defb 'Hello, world.',13,'$'




