
org 32768

start:
    LD B, 0AH
    LD C, 0DH
    CALL Get_Pixel_Address
    LD (23677), HL
    CALL $2382
    JP start

    

; Code used from:
; http://www.animatez.co.uk/computers/zx-spectrum/screen-memory-layout/
; Will have to replace with own routine to calc pixel address
; Get screen address
; B = Y pixel position
; C = X pixel position
; Returns address in HL
Get_Pixel_Address:  LD A,B; Calculate Y2,Y1,Y0
                    AND %00000111; Mask out unwanted bits
                    OR %01000000; Set base address of screen
                    LD H,A; Store in H
                    LD A,B; Calculate Y7,Y6
                    RRA; Shift to position
                    RRA
                    RRA
                    AND %00011000; Mask out unwanted bits
                    OR H; OR with Y2,Y1,Y0
                    LD H,A; Store in H
                    LD A,B; Calculate Y5,Y4,Y3
                    RLA; Shift to position
                    RLA
                    AND %11100000; Mask out unwanted bits
                    LD L,A; Store in L
                    LD A,C; Calculate X4,X3,X2,X1,X0
                    RRA; Shift into position
                    RRA
                    RRA
                    AND %00011111; Mask out unwanted bits
                    OR L; OR with Y5,Y4,Y3
                    LD L,A; Store in L
                    RET
