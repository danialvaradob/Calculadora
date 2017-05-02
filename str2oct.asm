startCodeOct:
    sub         EAX,EAX
    mov         dword[resultadoTotal],EAX 
    inc         ESI
    mov         EBX,ESI
    sub         ECX,ECX
    sub         EDX,EDX

reading_typeOct:
    cmp         byte[ESI],'-'
    je          finish_readingOct
    cmp         byte[ESI],'+'
    je          finish_readingOct
    cmp         byte[ESI],'/'
    je          finish_readingOct
    cmp         byte[ESI],'*'
    je          finish_readingOct
    cmp         byte[ESI],')'
    je          finish_readingOct
    cmp         byte[ESI],20h
    je          finish_readingOct
    cmp     	byte[ESI],'='
    je      	finish_readingOct

reading_oct:
    inc         CX
    inc         ESI
    jmp         reading_typeOct

finish_readingOct:
    sub         EDX,EDX
    mov         DL,byte[EBX]
    cmp         DX, '7'
    jg          error_oct
    cmp         DX, '0'
    jl          error_oct
    sub         EDX, '0'  
    push        EBX
    push        EDX      
    push        ECX            
    jmp         Oct_exponent

oct_expo_end: 
    pop         ECX
    pop         EDX           
    pop         EBX
    mul         EDX
    add         dword[resultadoTotal],EAX
    inc         EBX
    
    loop        finish_readingOct
  
endOct:
    ;PutLInt      [resultadoTotal]  
    
    dec         ESI
    jmp         add_exp   


error_oct:
    nwln
    PutStr      errormsg
    nwln
    jmp endOct

Oct_exponent:
    sub         edx,edx
    sub         ebx, ebx
    mov         EAX,1 
    mov         EBX,8
    dec         CX
    cmp         CX, 0
    je          zeroOct

procedureOct:
    mul         EBX      
    loop        procedureOct
    jmp         oct_expo_end         

zeroOct:
    mov         EAX, 1
    jmp         oct_expo_end
