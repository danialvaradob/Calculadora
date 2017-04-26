%include "io.mac"

.DATA
operation  db       "2+9-5x2 =",0

.UDATA
op          resb

.CODE
    .STARTUP
    

    mov         ESI,operation ;Pointer to the start of the variable
    
start:
    cmp         byte[ESI],20h
    jne         stack_start
    cmp         byte[ESI],'='
    je          endCode
stack_start:



check_operator:
    
    .EXIT
    
   