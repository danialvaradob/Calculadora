;
;Pasa de un string a su cantidad en Binario
;
;
;


%include  "io.mac"


.DATA
binary_str      db      "101110010",0
contador        db      "contador: ",0
binary          db      10b
resultado       db      "Resultado dsps de mul por exponente: ",0


.UDATA
exponente      resb 1
resultadoTotal resd 1

.CODE
    .STARTUP
startCode:
    mov         ESI,binary_str  ;Pointer to memory direction
    mov         EBX,binary_str  ;Pointer to memory direction
    mov         CX,CX
    mov         DX,0

setting_counter:
    cmp         byte[ESI],0
    je          finish_reading
    inc         CX
    inc         ESI
;    PutInt      CX
    mov         byte[resultadoTotal],0
    jmp         setting_counter

finish_reading:   
    ;nwln
    mov         DL,byte[EBX]
    sub         DL,'0'              ;Se obtiene su valor en binario
    push        DX                  ;Mete en la pila lo que tenga AL
                                    ;guardar la multiplicacion de la pila
                                    
    ;PutStr      contador
    ;PutInt      CX
    ;nwln
    push        CX                  ;guardo el contador en la pila para despues reemplazarlo
    call        binary_exponent
    pop         CX
    ;PutStr      contador
    ;PutInt      CX                  ;Prueba para ver que tiene CX
    pop         DX                  ;se obtiene lo que se tenia guardado en AX
                                    ;el resultado del exponente binario
    mul         DX                  ;si es 2^3 en el AX hay un 8 y en el byte[ESP]
                                     ;esta lo que se encuentre en esa posicion 
    ;nwln
    ;PutStr      resultado
    ;PutLInt     EAX
    

    add         word[resultadoTotal],AX
    ;push        AX                  ;mete el resultado en la pila
    inc         BX                  ;el puntero pasa a la siguiente posicion
    
    loop        finish_reading
    

    PutInt      [resultadoTotal]  
    nwln   
    mov     ESI,resultadoTotal 
    push    dword[resultadoTotal]
    sub     EAX,EAX   

read_char:
     mov     EAX,[ESI]       ;mueve el caracter al registro AL 
     ;PutCh   '['
     ;PutCh   byte[ESI] 
     ;PutCh   ']'
     ;PutCh   ' '      
     mov     EDX,8000H       ; mask byte = 80H
     mov     ECX,32        ; loop count to print 8 bits
print_bit:
     test    EAX,EDX        ; test does not modify AL
     jz      print_0      ; if tested bit is 0, print it
     PutCh   '1'          ; otherwise, print 1
     jmp     skip1
print_0:
     PutCh   '0'          ; print 0
skip1:
     shl     EAX,1         ; right-shift mask bit to test
                          ;  next bit of the ASCII code
     loop    print_bit    
    PutCh    " "
    inc ESI             ;pasa a la siguiente celda de memoria
    ;jmp function       ;salto incondicional

end:
    nwln
    PutInt  [resultadoTotal]
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

    
   

             