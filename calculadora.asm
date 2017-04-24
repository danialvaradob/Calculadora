%include  "io.mac"


.DATA
prompt_msg      db      "Welcome!"
test_cal        db      "bin1001-bin01001"

.UDATA

.CODE
    .STARTUP
startCode:
    PutStr      prompt_msg
    mov         EBP,test_cal ; Copia el apuntador de donde empieza la variable

reading_type:
    cmp         byte[EBP],'b'
    jne         notBinary
    inc         EBP
    cmp         byte[EBP],

notBinary:
    