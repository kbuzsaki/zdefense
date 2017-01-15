;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The below code is copied from:
;; https://equant-retrochallenge.blogspot.com/2008/07/zx-spectrum-assembly-programming-under.html
;; and has been reproduced in full below.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Hello World in Z80 assembly language.
;  Assembles for ZX Spectrum
;
; Assembled/Tested under linux with the following tools...
; z80asm $@.asm ; utils/bin2tap a.bin $@.tap ; xspect $@.tap
;
; Author: Nathanial Hendler ; retards.org
; Adapted from Damien Guard's 99 Bottles of Beer on the wall...
; Adapted from the Alan deLespinasse's Intel 8086 version
org 32768

start:
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

; Data
line:    defb 'Hello, world.',13,'$'
