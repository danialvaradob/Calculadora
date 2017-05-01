;Hex equivalent of characters              HEX1CHAR.ASM
;
;        Objective: To print the hex equivalent of
;                   ASCII character code.
;            Input: Requests a character from the user.
;           Output: Prints the ASCII code of the
;                   input character in hex.
%include "io.mac"
	
.DATA
;exp 	dd	6753413
exp 	dd	10
;exp     dd       0
.UDATA
first_1_bin     resb 1
.CODE

     .STARTUP
     mov     byte[first_1_bin],1
     
read_charBin:
     ;sub     dword[exp],10 
     cmp     dword[exp],0
     jl      print_bin_complement 
read_charBin1:
     mov     EAX,dword[exp]       ;mueve el caracter al registro AL      
     mov     EDX,80000000H       ; mask byte = 80H
     mov     ECX,32        ; loop count to print 8 bits
     
print_bit:
     test    EAX,EDX        ; test does not modify AL
     jz      print_0      ; if tested bit is 0, print it
     cmp    byte[first_1_bin],1
     je     first_time_binary
print_1:     
     PutCh   '1'          ; otherwise, print 1
     jmp     skip1
print_0:
     cmp    byte[first_1_bin],1  
     je     skip1
     PutCh   '0'          ; print 0
skip1:
     shl     EAX,1         ; right-shift mask bit to test
                           ;  next bit of the ASCII code
     loop    print_bit    
    PutCh    " "
    jmp     exit
first_time_binary:
    PutCh   '0'
    mov     byte[first_1_bin],0
    jmp     print_1
    

    
    
    
end:
    ;nwln
    ;PutInt  [resultadoTotal]
    ;.EXIT 

print_bin_complement:
    mov         byte[first_1_bin],0
    jmp         read_charBin1      
 
 
exit:
    .EXIT
