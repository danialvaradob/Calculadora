%include  "io.mac"


.DATA
binary_str      db      "0010",0
binary_str1      db      "0010",0

.UDATA

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
    PutInt      CX
    jmp         reading_type

finish_reading:
    mov         AL,byte[BX]
    sub         AL,'0'              ;Se obtiene su valor en binario
    mul         CL                  ;lo multiplica por el contador 
                                    ;para sacar su valor en binario
    add         DX,AX               ;suma el resultado a DX
    inc         BX                  ;el puntero pasa a la siguiente posicion
    loop        finish_reading
    
end:
    PutInt      DX     


    .EXIT 
       