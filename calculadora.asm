
%include "io.mac"

.DATA
operation       db      "b01101011*h6-5*3-9*2 =",0
bin_error_msg   db      "Entrada binaria erronea",0
errormsg           db      "ERROR",0
primer_op       db      1

.UDATA
resultadoTotal resd 1
cont           resb 1        
postFix        resd 256 ;where the postfix op will be stored

.CODE
    .STARTUP

    mov         ESI,operation   ;Pointer to the start of the variable
    mov         EDI,postFix     ;Pointer to the start if the memory variable 
    mov         CX,15   
    ;mov         BX,1            ;to compare
    
start:
    PutCh       byte[ESI]
    cmp         byte[ESI],'b'
    je          startB
    cmp         byte[ESI],'h'
    je          startCodeHex
    cmp         byte[ESI],20h
    je          stack_elements         
    cmp         byte[ESI],'='
    je          stack_elements

check_ch:
    sub         AX,AX   
    cmp         byte[ESI],'0'
    jge         ch_number
    
    
not_number:

    jmp         operator_priority
operator_priority_end:
    
    inc         ESI             ;pasa a la siguiente celda de memoria
    jmp         start

      

ch_number:
    cmp         byte[ESI],'9'
    jg          not_number
    ;sub         byte[ESI],'0'   ;DESCOMENTAR ESO!!!!
    sub         EAX,EAX
    mov         AL,byte[ESI]
    mov         dword[resultadoTotal],EAX


add_postfix:
    sub         EAX,EAX 
    sub         EDX,EDX
    sub         ECX,ECX
    sub         EBX,EBX

    mov        EAX,dword[resultadoTotal] 
    mov        dword[EDI],EAX   
    inc         ESI  
    inc         EDI   ;next memory varaible in postFix

    jmp         start
        


    ; al terminar la operacion tiene que ir sacando todo lo de la pila y resolver

stack_elements:  ;Elementos que quedaron en el stack
	
    sub		EBX,EBX	
    pop	         BX      ;element ToS
    cmp          BL,'+'
    je          add_operator              
    cmp         BL,'-'
    je          add_operator
    cmp          BL,'*'
    je          add_operator
    cmp          BL,'/'
    je          add_operator
    jmp         endCode
    
add_operator:
    mov         dword[EDI],EBX
    inc         EDI
    jmp         stack_elements

endCode:
    
    mov         ESI,postFix
    mov         CX,25
    mov     dword[EDI],'!'
    ;nwln
print_variable:
    mov     EBX,dword[ESI]
    PutCh   BL
    inc     ESI
    loop    print_variable
    
    .EXIT
    
;--------------------------------------------------------------------
;       Funcion utilizada para comparar los operandos
;   
;--------------------------------------------------------------------    
; byte[ESI] has the operator outside of the stack

    

operator_priority:
    cmp         byte[primer_op],1
    je          firsttime
    sub         EBX,EBX
    pop         BX   ;element on ToS
    cmp         BL,'-'
    je          continue_priorityToSMinPlus
    cmp         BL,'+'
    ;PutCh       'X'
    je          continue_priorityToSMinPlus
    cmp         BL,'/'
    je          continue_priorityToSMultDiv
    cmp         BL,'*'
    je          continue_priorityToSMultDiv
    cmp         BL,'('
    jmp         both_elements_to_stack
    jmp         end_priority

firsttime:
    sub         EAX,EAX
    mov         AL,byte[ESI]
    push        AX
    ;inc         ESI
    ;sub         CX,CX
    ;PutCh       'Y'
    ;ret  
    inc         byte[primer_op]
    jmp         operator_priority_end

continue_priorityToSMinPlus:  ;ToS is a '-'  or '+'
    cmp         byte[ESI],'('   
    je          both_elements_to_stack
    cmp         byte[ESI],')'
    je          right_parenthesis
                                
    cmp         byte[ESI],'+'
    je         newE_to_stack    ;if the new element is not a / or * is a - or +
    cmp         byte[ESI],'-'
    je         newE_to_stack    ;if the new element is not a / or * is a - or +
    ;jmp         newE_to_stack         
both_elements_to_stack:        
    push        BX              ;pushes the ToS back to the stack
    sub         AX,AX 
    mov         AL,byte[ESI]    ;moves the '*' or '/' new element to the AL register
    push        AX              ;pushes to the ToS the new element    
    jmp         end_priority1               
                            
                           


continue_priorityToSMultDiv:    ;ToS is a '*' or '/'
    cmp         byte[ESI],'('   
    je          both_elements_to_stack
    cmp         byte[ESI],')'
    je          right_parenthesis
                                
    jmp         newE_to_stack    ;the new element always enters the stack and the last eleme
                                 ;is added to the variable
            
                            
right_parenthesis:
    cmp         BL,'('
    je          end_priority1   ;no need to save the '(' anywhere
    mov         dword[EDI],EBX
    ;mov         CX,4
    ;jmp         next_dword
    inc         EDI
continue_right_paren:
    pop         BX
    jmp         right_parenthesis
    


newE_to_stack:  ;less or equal priority enters the stack and adds the last element
                ;poped out of the stack to the variable
    sub         AX,AX       
    mov         AL,byte[ESI]	;copies the operator in the variable (lo que digita el usuario)
    push        AX
    mov         dword[EDI],EBX   ;moves the operand taken from stack to the memory variable
    inc         EDI

end_priority1: ;ends function when an '/' or '*' is the new element and the last element
               ;is a '-' or '+'
               
    jmp         operator_priority_end         

end_priority:
    push        EBX
    jmp         operator_priority_end





;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;xxxxxxxxxxxxx         SIGNO    NO FUNCIONA AUN     xxxxxxxxxxxxxxxxxxxxxxxxx
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
firstCh_op:
          
    cmp         byte[ESI],'/'
    je          entry_error   
    cmp         byte[ESI],'*'
    je          entry_error   
    cmp         byte[ESI + 1],'+'    
    je          entry_error            ;2 consecutives operators == error   
    cmp         byte[ESI + 1],'-'    
    je          entry_error            ;2 consecutives operators == error
    cmp         byte[ESI + 1],'/'    
    je          entry_error            ;2 consecutives operators == error
    cmp         byte[ESI + 1],'*'    
    je          entry_error            ;2 consecutives operators == error
    cmp         byte[ESI],'+'          ;does nothing, +1 = 1
    je          sum_sign       
    jmp         minus_sign   

 
sum_sign:
    sub         BX,BX   
    jmp         operator_priority_end         
      
minus_sign:
    sub         EBX,EBX
    sub         EAX,EAX
    mov         AX,0
    mov         BL,byte[ESI+1]
    ;mov         dword[result]
    sub         EAX,EBX       ;saves the new number in AX
    inc         ESI                  ;moves to the next memory cell   
    mov        AL,byte[ESI]
    ;PutCh      AL
    mov        dword[EDI],EAX
    
    inc         ESI
    ;nwln
    ;PutLInt     dword[EDI]
    inc         EDI   ;next memory varaible in postFix
    jmp         start 
    
 entry_error:
    PutStr      errormsg

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;xxxxxxxxxxxxx         SIGNO         xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;BINARY STR TO DECIMAL
  
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------

startB:
    sub         CX,CX
    inc         ESI
    ;PutCh       byte[ESI]
    mov         EBX,ESI  ;Pointer to memory direction
    mov         CX,CX
    mov         DX,0

setting_counter:
    
    cmp         byte[ESI],'-'
    je          finish_reading
    cmp         byte[ESI],'+'
    je          finish_reading
    cmp         byte[ESI],'/'
    je          finish_reading
    cmp         byte[ESI],'*'
    je          finish_reading
    cmp         byte[ESI],')'
    je          finish_reading
    
    ;-----
    ;-----
    cmp         byte[ESI],'2'
    jge         binary_error
    cmp         byte[ESI],'0'
    jl          binary_error
    ;-----
    ;-----
    
    inc         CX
    inc         ESI
    inc         byte[cont]
;    PutInt      CX
    mov         byte[resultadoTotal],0
    jmp         setting_counter

finish_reading:

binary_loop:
    
    mov         DL,byte[EBX]
    sub         DL,'0'              ;Se obtiene su valor en binario
    push        DX                  ;Mete en la pila lo que tenga AL
                                    ;guardar la multiplicacion de la pila

    push        CX                  ;guardo el contador en la pila para despues reemplazarlo
    jmp        binary_exponent
end_exponent:    
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
    ;nwln
    dec         ESI
    jmp         add_postfix         
 


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
    jmp         end_exponent

zero:
    mov         AX,1
    jmp         end_exponent


binary_error:
    PutStr      bin_error_msg
    

  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ;----------------------------------------------------------------------------------------
  ; HEXADECIMAL
startCodeHex:
    sub         EAX,EAX
    mov         dword[resultadoTotal],EAX 
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
;    cmp         byte[ESI],'9'
;    jge         hexadecimal_error
;    cmp         byte[ESI],'0'
;    jl          hexadecimal_error
    ;-----
    ;-----
reading_hex:

    inc         CX
    inc         ESI
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
    jmp 	        error_outp

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
    PutCh       'I'
    PutInt      [resultadoTotal] 
    PutCh       'I'  
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
    PutStr      errormsg
      
  
  
  