;Hex equivalent of characters              HEX1CHAR.ASM
;
;        Objective: To print the hex equivalent of
;                   ASCII character code.
;            Input: Requests a character from the user.
;           Output: Prints the ASCII code of the
;                   input character in hex.
%include "io.mac"
	
.DATA
exp 	dd	6753413
byteVar db	0

.CODE

     .STARTUP
read_charHex:
     mov     EAX, [exp]
     shr     EAX, 28        ; move upper 4 bits to lower half
     mov     CX,8         ; loop count - 2 hex digits to print
print_digitHex:
     test    AL, 1111b
     jz      byte_is_zeroHex
     jmp     byte_not_zeroHex

byte_is_zeroHex:
     cmp     byte[byteVar], 0
     je     skipHex2

byte_not_zeroHex:
     inc     byte[byteVar]
     cmp     AL,9         ; if greater than 9
     jg      A_to_FHex       ; convert to A through F digits
     add     AL,'0'       ; otherwise, convert to 0 through 9
     jmp     skipHex

A_to_FHex:
     add     AL,'A'-10    ; subtract 10 and add 'A'
                          ; to convert to A through F
skipHex:
     PutCh   AL           ; write the first hex digit

skipHex2:
     mov     EAX,[exp]   ; restore input character in AL
     cmp     CX,8
     je      count_is_8
     cmp     CX,7
     je      count_is_7
     cmp     CX,6
     je      count_is_6
     cmp     CX,5
     je      count_is_5
     cmp     CX,4
     je      count_is_4
     cmp     CX,3
     je      count_is_3
     and     AL, 0Fh

cont_printing_hex:
     loop    print_digitHex
     PutCh   'h'
     nwln
     jmp     exit_printing_hex

count_is_8:
     shr     EAX, 24
     and     AL, 0Fh
     jmp     cont_printing_hex
count_is_7:
     shr     EAX, 20
     and     AL, 0Fh
     jmp     cont_printing_hex 
count_is_6:
     shr     EAX, 16
     and     AL, 0Fh
     jmp     cont_printing_hex
count_is_5:
     shr     EAX, 12
     and     AL, 0Fh
     jmp     cont_printing_hex
count_is_4:
     shr     EAX, 8
     and     AL, 0Fh
     jmp     cont_printing_hex
count_is_3:
     shr     EAX, 4
     and     AL, 0Fh
     jmp     cont_printing_hex

exit_printing_hex:
     .EXIT
