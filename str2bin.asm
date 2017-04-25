;
;Pasa de un string a su cantidad en Binario
;Lo imprime en entero
;
;


%include  "io.mac"


.DATA
binary_str      db      "1100",0
binary_str1     db      "0010",0
contador        db      "contador: ",0
binary          db      10b
resultado       db      "Resultado dsps de mul por exponente: ",0


.UDATA
exponente      resb 1
resultadoTotal resd 1

.CODE
    .STARTUP
startCode:
    mov         EBP,binary_str
    mov         EBX,binary_str
    mov         CX,CX
    mov         DX,0

reading_type:
    cmp         byte[EBP],0
    je          finish_reading
    inc         CX
    inc         EBP
;    PutInt      CX
    mov         byte[resultadoTotal],0
    jmp         reading_type

finish_reading:
    ;PutInt      CX
    ;PutStr      llego   
    nwln
    mov         DL,byte[EBX]
    sub         DL,'0'              ;Se obtiene su valor en binario
    push        DX                  ;Mete en la pila lo que tenga AL
                                    ;guardar la multiplicacion de la pila
                                    
    PutStr      contador
    PutInt      CX
    nwln
    push        CX                  ;guardo el contador en la pila para despues reemplazarlo
    call        binary_exponent
    ;mov         CX,[ESP]
    pop         CX
    PutStr      contador
    PutInt      CX                  ;Prueba para ver que tiene CX
    pop         DX                  ;se obtiene lo que se tenia guardado en AX
    ;mul         byte[ESP]            ;el resultado del exponente binario
    mul         DX                                 ;si es 2^3 en el AX hay un 8 y en el byte[ESP]
                                     ;esta lo que se encuentre en esa posicion 
    nwln
    PutStr      resultado
    PutInt      AX

    add         word[resultadoTotal],AX
    ;push        AX                  ;mete el resultado en la pila
    inc         BX                  ;el puntero pasa a la siguiente posicion
    
    loop        finish_reading
    
end:
    nwln
    PutInt      [resultadoTotal]     


    .EXIT 

;----------------------------------------------------------
;Calling Functions
;----------------------------------------------------------
 
binary_exponent:
    mov         AX,10b ;2 simplemente mueve un 2 al AX
    mov         DL,10b ;2 mueve un 2 al DL ya que es un binary, si fuese hex seria un 16
    dec         CX ;En este momento el contador esta en 4, pero se requiere
    dec         CX ;que este en 2 para que funcione el exponente

procedure:
    mul         DL      
    loop        procedure
    sub         DL,DL
    ret

    
   

             