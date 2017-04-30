;
;Pasa de un string a su cantidad en Binario
;
;
;


%include  "io.mac"


.DATA
binary_str      db      "101110010-",0
contador        db      "contador: ",0
resultado       db      "Resultado dsps de mul por exponente: ",0


.UDATA
resultadoTotal resd 1
cont           resb 1

.CODE
    .STARTUP
startB:
    mov         EBX,binary_str  ;Pointer to memory direction
    mov         CX,CX
    mov         DX,0

setting_counter:
    cmp         byte[EBX],'-'
    je          finish_reading
    cmp         byte[EBX],'+'
    je          finish_reading
    cmp         byte[EBX],'/'
    je          finish_reading
    cmp         byte[EBX],'*'
    je          finish_reading
    cmp         byte[EBX],')'
    je          finish_reading
    inc         CX
    inc         EBX
    inc         byte[cont]
;    PutInt      CX
    mov         byte[resultadoTotal],0
    jmp         setting_counter

finish_reading:
    dec         EBX
    ;PutCh       byte[EBX]
    loop        finish_reading
    mov         CX,CX
    mov         CL,byte[cont]
    PutInt      CX
    
    
    nwln
    ;jmp endB
binary_loop:
    PutCh       byte[EBX]
    
    mov         DL,byte[EBX]
    sub         DL,'0'              ;Se obtiene su valor en binario
    push        DX                  ;Mete en la pila lo que tenga AL
                                    ;guardar la multiplicacion de la pila

    push        CX                  ;guardo el contador en la pila para despues reemplazarlo
    call        binary_exponent
    pop         CX                 ;Prueba para ver que tiene CX
    pop         DX                  ;se obtiene lo que se tenia guardado en AX
                                    ;el resultado del exponente binario
    mul         DX                  ;si es 2^3 en el AX hay un 8 y en el byte[ESP]
                                     ;esta lo que se encuentre en esa posicion 

    

    add         word[resultadoTotal],AX
                                     ;mete el resultado en la pila
    inc         BX                  ;el puntero pasa a la siguiente posicion
    
    loop        binary_loop
    
endB:
    ;nwln
    PutInt      [resultadoTotal]     


    .EXIT 

;----------------------------------------------------------
;Calling Functions
;----------------------------------------------------------
 
binary_exponent:
    mov         AX,1    ;2 simplemente mueve un 2 al AX
    mov         DL,10b  ;2 mueve un 2 al DL ya que es un binary, si fuese hex seria un 16
    cmp         CX,1    ;si el contador es 1, salta a para retorna como resultado 1
    je         zero
    dec         CX      ;En este momento el contador esta en 4, pero se requiere
                        ;que este en 2 para que funcione el exponente
  
    
procedure:
    mul         DL      
    loop        procedure
    ret

zero:
    mov         AX,1
    ret

    
   

             