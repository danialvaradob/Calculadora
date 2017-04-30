%include "io.mac"

.DATA
operation  db       "2*9-(5*3-9*2) =",0
voyPor      db       "Voy por ",0
aca         db          " aca",0

.UDATA
result      resd 1         
postFix     resd 256 ;where the postfix op will be stored

.CODE
    .STARTUP

    mov         ESI,operation   ;Pointer to the start of the variable
    mov         EDI,postFix     ;Pointer to the start if the memory variable 
    mov         CX,15   
    mov         BX,1            ;to compare
    
start:

    cmp         byte[ESI],20h
    je          stack_elements         
    cmp         byte[ESI],'='
    je          stack_elements

check_ch:
    sub         AX,AX   
    cmp         byte[ESI],'0'
    jge         ch_number
    
    
not_number:
    cmp         BX,1
    je          firstCh_op          ;first element is a sign operator
    
    jmp         operator_priority
operator_priority_end:
    
    inc         ESI             ;pasa a la siguiente celda de memoria
    jmp         start

      

ch_number:
    cmp         byte[ESI],'9'
    jg          not_number
    ;sub         byte[ESI],'0'   ;DESCOMENTAR ESO!!!!
    cmp         BX,1
    jne         add_postfix 
    sub         BX,BX           ;no first anymore

add_postfix:
    sub        AX,AX 
    mov        AL,byte[ESI]
    PutCh      AL
    mov        dword[result],EAX
    mov        EAX,dword[result]
    mov        dword[EDI],EAX
    
    inc         ESI
    ;nwln
    ;PutLInt     dword[EDI]
    inc         EDI   ;next memory varaible in postFix
    jmp         start
        


    ; al terminar la operacion tiene que ir sacando todo lo de la pila y resolver

stack_elements:  ;Elementos que quedaron en el stack
	
    sub		EBX,EBX	
    pop	         BX      ;element ToS
    ;PutCh           BL
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
    nwln
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
    cmp         CL,15
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
    sub         CX,CX
    ;PutCh       'Y'
    ;ret  
    jmp operator_priority_end

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
    PutCh      AL
    mov        dword[EDI],EAX
    
    inc         ESI
    ;nwln
    ;PutLInt     dword[EDI]
    inc         EDI   ;next memory varaible in postFix
    jmp         start 
entry_error:
    PutCh 'X'
