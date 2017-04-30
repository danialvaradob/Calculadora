;
;
;
;
;
;
%include "io.mac"

.DATA
input_is        db	"Input is: ",0
hex_str      	db      "FA",0
errormsg        db      "Wrong Input",0


.UDATA
resultadoTotal resd 1

.CODE
    .STARTUP
startCode:
    sub         ECX,ECX
    inc         ESI
    mov         EBX,ESI
    sub         ECX,ECX
    sub         EDX,EDX

reading_typeHex:
    cmp         byte[ESI],'-'
    je          endHex
    cmp         byte[ESI],'+'
    je          endHex
    cmp         byte[ESI],'/'
    je          endHex
    cmp         byte[ESI],'*'
    je          endHex
    cmp         byte[ESI],')'
    je          endHex

    ;-----
    ;-----
    cmp         byte[ESI],'9'
    jge         hexadecimal_error
    cmp         byte[ESI],'0'
    jl          hexadecimal_error
    ;-----
    ;-----
reading_hex:

    inc         CX
    inc         EBP
    jmp         reading_typeHex

finish_readingHex:
    mov         DL,byte[EBX]
    cmp         DX, 'F'
    jg          error_outp
    cmp         DX, 'A'
    jge         is_letter
    cmp         DX, '9'
    jg          error_outp
    cmp         DX, '0'
    jge         sub_num
    jmp 	error_outp

is_letter:
    sub         DX, 55
    jmp         mult_withInt

sub_num:
    sub         DX, '0'

mult_withInt:   
    push        DX                  ;Mete en la pila lo que tenga AL
                                    ;guardar la multiplicacion de la pila

    push        CX                  ;guardo el contador en la pila para despues reemplazarlo
    jmp         Hex_exponent
hex_expo_end:
    
    pop         CX
    pop         DX                  ;se obtiene lo que se tenia guardado en AX
    mul         DX                  ;si es 2^3 en el AX hay un 8 y en el byte[ESP]
                                    ;esta lo que se encuentre en esa posicion 

    add         dword[resultadoTotal],EAX
    inc         EBX                  ;el puntero pasa a la siguiente posicion
    
    loop        finish_readingHex
  
endHex:

    PutInt      [resultadoTotal]   
    dec         ESI
    jmp         add_postfix   


error_outp:
    PutStr      errormsg
    jmp endHex

;----------------------------------------------------------
;Calling Functions
;----------------------------------------------------------
 
Hex_exponent:
    mov         AX,1 
    mov         DL,16
    dec         CX ;En este momento el contador esta en 4, pero se requiere
    cmp         CX, 0
    je          zeroHex

procedureHex:
    mul         DL      
    loop        procedureHex
    jmp         hex_expo_end         

zeroHex:
    mov         AX, 1
    jmp         hex_expo_end


hexadecimal_error:
    cmp         byte[ESI],'A'
    jl          hexadecimal_error2
    cmp         byte[ESI],'F'
    jg          hexadecimal_error2
    jmp         reading_hex     

hexadecimal_error2:
    PutStr      hex_error_msg
      
