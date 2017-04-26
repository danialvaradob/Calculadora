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
    mov         EBP, hex_str
    mov         EBX, hex_str
    sub         ECX,ECX
    sub         EDX,EDX

reading_type:
    cmp         byte[EBP],0
    je          finish_reading
    inc         CX
    inc         EBP
    jmp         reading_type

finish_reading:
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

mult_withInt :   
    push        DX                  ;Mete en la pila lo que tenga AL
                                    ;guardar la multiplicacion de la pila

    push        CX                  ;guardo el contador en la pila para despues reemplazarlo
    call        binary_exponent
    pop         CX
    pop         DX                  ;se obtiene lo que se tenia guardado en AX
    mul         DX                  ;si es 2^3 en el AX hay un 8 y en el byte[ESP]
                                    ;esta lo que se encuentre en esa posicion 

    add         dword[resultadoTotal],EAX
    inc         EBX                  ;el puntero pasa a la siguiente posicion
    
    loop        finish_reading
  
end:
    PutStr      input_is
    PutStr      hex_str
    nwln
    PutInt      [resultadoTotal]   
    nwln  

    .EXIT 

error_outp:
    PutStr      errormsg
    jmp end

;----------------------------------------------------------
;Calling Functions
;----------------------------------------------------------
 
binary_exponent:
    mov         AX,1 
    mov         DL,16
    dec         CX ;En este momento el contador esta en 4, pero se requiere
    cmp         CX, 0
    je          zero

procedure:
    mul         DL      
    loop        procedure
    ret

zero:
    mov         AX, 1
    ret
    