;
;
;
;
;Maximo Bin: 2^31
;Maximo Hex: 16^8
;Maximo Oct: 
;
;

%include "io.mac"

.DATA
welcome_msg             db       "Bienvenido a la calculadora BinOctHex!",0
input_sign              db       ">>",0
;operation                db      "b01010+h6B*22*2 =",0
;operation               db     "10+5 =h"
result_msg              db       "El resultado es: "
bin_error_msg            db      "Entrada binaria erronea",0
errormsg                 db      "ERROR",0
primer_op                db      1
overflow_error_mul 	db  	'Ocurrió un overflow en una multiplicación',0
byteVar db	0


.UDATA
operation      resb 256 
resultadoTotal resd 1
cont           resb 1        
exp            resd 256 ;where the exp op will be stored

complement     resb 1   ;flag
banderaBinario resb 1   ;si el usuario quiere el resultado en binario, se enciende 
banderaDecimal resb 1
banderaHex     resb 1
banderaOct     resb 1
first_1_bin    resb 1

.CODE
    .STARTUP

startCalc:
    nwln
    PutStr      welcome_msg
    nwln
    PutStr      input_sign
    GetStr      operation
    
    ;;;;;;;BANDERAS;;;;;;;;
    mov         byte[complement],0 ;resetea el complemento
    mov         byte[banderaBinario],0 ;resetea la bandera de binario
    mov         byte[banderaDecimal],1      ;DEFAULT
    mov         byte[banderaHex],0
    mov         byte[banderaOct],0
    mov         byte[first_1_bin],0
    
    mov         ESI,operation   ;Pointer to the start of the variable
    mov         EDI,exp     ;Pointer to the start if the memory variable 
    mov         CX,15   
    ;mov         BX,1            ;to compare
    cmp         byte[ESI],'#'
    je          startHelp
startAll:

    cmp         byte[ESI],'d'
    je         readingDecimal1
    cmp         byte[ESI],'b'
    je          startB
    cmp         byte[ESI],'h'
    je          startCodeHex
    cmp         byte[ESI],20h
    je          stack_elements         
    cmp         byte[ESI],'='
    je          stack_elements

check_ch:
    sub         EAX,EAX   
    cmp         byte[ESI],'0'
    jge         ch_number
    
    
not_number:

    jmp         operator_priority
operator_priority_end:
    
    inc         ESI             ;pasa a la siguiente celda de memoria
    jmp         startAll

      

ch_number:
    cmp         byte[ESI],'9'
    jg          not_number
    jmp         readingDecimal


add_exp:
    sub         EAX,EAX 
    sub         EDX,EDX
    sub         ECX,ECX
    sub         EBX,EBX

    mov        EAX,dword[resultadoTotal] 
    mov        dword[EDI],EAX  
    inc         ESI  
    inc         EDI   ;next memory varaible in exp
    inc         EDI
    inc         EDI
    inc         EDI
    jmp         startAll
        


    ; al terminar la operacion tiene que ir sacando todo lo de la pila y resolver

stack_elements:  ;Elementos que quedaron en el stack
    sub		EBX,EBX	
    pop	        EBX      ;element ToS
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
    inc         EDI
    inc         EDI
    inc         EDI
    jmp         stack_elements

endCode:
    mov     dword[EDI],'!'

;print_variable:

    cmp     byte[ESI + 2],'b'
    je      activar_banderaBin
    cmp     byte[ESI + 2],'h'
    je      activar_banderaHex
    cmp     byte[ESI + 2],'o'
    je      activar_banderaOct

    jmp     startEval
activar_banderaBin:
    mov     byte[banderaBinario],1
    mov         byte[banderaDecimal],0      ;DEFAULT
    mov         byte[banderaHex],0
    mov         byte[banderaOct],0
    jmp     startEval

activar_banderaHex:
    mov     byte[banderaBinario],0
    mov         byte[banderaDecimal],0      ;DEFAULT
    mov         byte[banderaHex],1
    mov         byte[banderaOct],0
    jmp     startEval

activar_banderaOct:
    mov     byte[banderaBinario],0
    mov         byte[banderaDecimal],0      ;DEFAULT
    mov         byte[banderaHex],0
    mov         byte[banderaOct],1
    jmp     startEval
    
        
                
;--------------------------------------------------------------------
;       Funcion utilizada para comparar los operandos
;   
;--------------------------------------------------------------------    
; byte[ESI] has the operator outside of the stack

    

operator_priority:
    cmp         byte[primer_op],1
    je          firsttime
    sub         EBX,EBX
    pop         EBX   ;element on ToS
    cmp         BL,'-'
    je          continue_priorityToSMinPlus
    cmp         BL,'+'
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
    push        EAX  
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
    push        EBX              ;pushes the ToS back to the stack
    sub         EAX,EAX 
    mov         AL,byte[ESI]    ;moves the '*' or '/' new element to the AL register
    push        EAX              ;pushes to the ToS the new element    
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
    inc         EDI
    inc         EDI
    inc         EDI
continue_right_paren:
    pop         EBX
    jmp         right_parenthesis
    


newE_to_stack:  ;less or equal priority enters the stack and adds the last element
                ;poped out of the stack to the variable
    sub         EAX,EAX       
    mov         AL,byte[ESI]	;copies the operator in the variable (lo que digita el usuario)
    push 	EAX
    mov         dword[EDI],EBX   ;moves the operand taken from stack to the memory variable
    inc         EDI
    inc         EDI
    inc         EDI
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
    sub         EAX,EBX       ;saves the new number in AX
    inc         ESI                  ;moves to the next memory cell   
    mov        AL,byte[ESI]
    mov        dword[EDI],EAX
    
    inc         ESI
    inc         EDI   ;next memory varaible in exp
    jmp         start 
    
 entry_error:
 PutCh  'Q'
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
  ;----------------------------------------------------------------------------------------
  ; String to Decimal
readingDecimal1:
    inc      ESI

readingDecimal:
     sub     EAX, EAX
     mov     EBX, ESI
     
condDecimal:   
     mov     EDX, 10
     cmp     byte[ESI],'-'
     je      question
     cmp     byte[ESI],'*'
     je      question
     cmp     byte[ESI],')'
     je      question
     cmp     byte[ESI],'/'
     je      question
     cmp     byte[ESI],'+'
     je      question
     cmp     byte[ESI],32
     je      question
     cmp     byte[ESI],'='
     je      question
     cmp     byte[ESI], '9'
     jg      error_outputDecimal
     cmp     byte[ESI], '0'
     jl      error_outputDecimal
     sub     byte[ESI], '0'
     mul     EDX
     sub     ECX, ECX
     mov     CL, byte[ESI]
     add     EAX, ECX
     inc     ESI 
     jmp condDecimal

question:
     jmp doneDecimal

error_outputDecimal:
     nwln
     PutStr  errormsg
     jmp question

doneDecimal:
    mov         dword[resultadoTotal],EAX
    dec         ESI
    jmp         add_exp  
    



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
    mov         EBX,ESI  ;Pointer to memory direction
    mov         CX,CX
    mov         DX,0
    cmp         byte[ESI],'1'
    je          complemento2
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
    cmp         byte[ESI],20h
    je          finish_reading
    
    ;-----
    ;-----
    cmp         byte[ESI],'2'
    jge         binary_error
    cmp         byte[ESI],'0'
    jl          binary_error
    ;-----
    ;-----
    cmp         byte[complement],1
    jne         continue_setting_counter
    cmp         byte[ESI],'0'
    je          change_zero
    dec         byte[ESI]
    jmp         continue_setting_counter
 
change_zero:
    inc         byte[ESI]         

    
continue_setting_counter:            
    inc         CX
    inc         ESI
    inc         byte[cont]
    mov         byte[resultadoTotal],0
    jmp         setting_counter




finish_reading:
    
binary_loop:
    sub         EDX,EDX
    mov         DL,byte[EBX]
    push        EBX
    sub         DL,'0'              ;Se obtiene su valor en binario
    
    push        EDX                  ;Mete en la pila lo que tenga AL
                                 ;guardar la multiplicacion de la pila

    push        CX                  ;guardo el contador en la pila para despues reemplazarlo
    jmp        binary_exponent
end_exponent:    
    pop         CX                 ;Prueba para ver que tiene CX

    pop        EDX                  ;se obtiene lo que se tenia guardado en AX
  
    pop        EBX                                                             ;el resultado del exponente binario
    mul        EDX                  ;si es 2^3 en el AX hay un 8 y en el byte[ESP]
                                     ;esta lo que se encuentre en esa posicion 
    add         dword[resultadoTotal],EAX
                                     ;mete el resultado en la pila
    inc         BX                  ;el puntero pasa a la siguiente posicion
    
    loop        binary_loop
    
endB:
    cmp         byte[complement],0
    je          terminarB
    inc         dword[resultadoTotal]
    not         dword[resultadoTotal]
    inc         dword[resultadoTotal]
    
terminarB:
    dec         ESI
    mov         byte[complement],0
    jmp         add_exp         

complemento2:
    mov         byte[complement],1
    jmp         setting_counter        
 


;----------------------------------------------------------
;Calling Functions
;----------------------------------------------------------
 
binary_exponent:
    sub         edx,edx
    sub         ebx, ebx
    mov         EAX,1    ;2 simplemente mueve un 2 al AX
    mov         EBX,2  ;2 mueve un 2 al DL ya que es un binary, si fuese hex seria un 16
    cmp         CX,1    ;si el contador es 1, salta a para retorna como resultado 1
    je         zero
    dec         CX      ;En este momento el contador esta en 4, pero se requiere
                        ;que este en 2 para que funcione el exponente
  
    
procedure:    
    mul         EBX
    
    loop        procedure

    jmp         end_exponent

zero:
    mov         EAX,1

    jmp         end_exponent


binary_error:
    nwln
    PutStr      bin_error_msg
    nwln
    

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
    je          finish_readingHex
    cmp         byte[ESI],'+'
    je          finish_readingHex
    cmp         byte[ESI],'/'
    je          finish_readingHex
    cmp         byte[ESI],'*'
    je          finish_readingHex
    cmp         byte[ESI],')'
    je          finish_readingHex
    cmp         byte[ESI],20h
    je          finish_readingHex

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
    sub         EDX,EDX
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
    sub         EDX, 55
    jmp         mult_withInt

sub_num:
    sub         EDX, '0'

mult_withInt:   
    push        EBX
    push        EDX                  ;Mete en la pila lo que tenga AL
                                    ;guardar la multiplicacion de la pila

    push        ECX                  ;guardo el contador en la pila para despues reemplazarlo
    jmp         Hex_exponent
hex_expo_end:
    
    pop         ECX
    pop         EDX                  ;se obtiene lo que se tenia guardado en AX
    pop         EBX
    mul         EDX                  ;si es 2^3 en el AX hay un 8 y en el byte[ESP]
                                    ;esta lo que se encuentre en esa posicion 
    
    add         dword[resultadoTotal],EAX
    inc         EBX                  ;el puntero pasa a la siguiente posicion
    
    loop        finish_readingHex
  
endHex:
    ;PutLInt      [resultadoTotal]  
    
    dec         ESI
    jmp         add_exp   


error_outp:
    nwln
    PutStr      errormsg
    nwln
    jmp endHex

;----------------------------------------------------------
;Calling Functions
;----------------------------------------------------------
 
Hex_exponent:
    sub         edx,edx
    sub         ebx, ebx
    mov         EAX,1 
    mov         EBX,16
    dec         CX ;En este momento el contador esta en 4, pero se requiere
    cmp         CX, 0
    je          zeroHex

procedureHex:
    mul         EBX      
    loop        procedureHex
    jmp         hex_expo_end         

zeroHex:
    mov         EAX, 1
    jmp         hex_expo_end


hexadecimal_error:
    cmp         byte[ESI],'A'
    jl          hexadecimal_error2
    cmp         byte[ESI],'F'
    jg          hexadecimal_error2
    jmp         reading_hex     

hexadecimal_error2:
    PutStr      errormsg
;=======================================================================================     
;=======================================================================================
;=======================================================================================
;=======================================================================================
;=======================================================================================
;=======================================================================================
 startEval:
 
    
 
    sub         EBX,EBX
    sub         EDX,EDX
    sub         ECX,ECX
    sub         EAX,EAX
    sub         ESI,ESI
    sub         EDI,EDI
    
    mov         ESI,exp ;Pointer to the start of the variable
    
start:
    sub 	EAX, EAX

    mov         EAX,dword[ESI]	;En en EAX queda el valor a comparar
    cmp 	EAX,'!'
    je 		done
    cmp         EAX,'+'
    je          is_sum
    cmp         EAX,'-'
    je          is_sub
    cmp         EAX,'*'
    je          is_mul
    cmp         EAX,'/'
    je          is_div
    inc 	ESI
    inc ESI
    inc ESI
    inc ESI
    jmp    	start

is_sum: 
    dec 	ESI
    dec 	ESI
    dec 	ESI
    dec 	ESI			;Por ejemplo,en la postfijo 34+, hay que posicionarse en el 4.
    mov         EDX, dword[ESI]    	;Copia el 4 al EDX
    dec 	ESI
    dec 	ESI
    dec 	ESI
    dec		ESI			;Se posiciona en el 3 y lo copia al EAX
    mov         EAX, dword[ESI]    
    PutLInt 	EAX
    PutCh	'+'
    PutLInt 	EDX
    nwln
    add         EAX, EDX      		;hace la suma
    mov         [ESI], EAX		;guarda el resulado en la posicion del 3
					;despues de hacer eso, el 4 y el + son inservibles,
					;entonces, la idea es mover todo lo que
					;esta despues del +, dos espacios para atras.
					;Por ejemplo, que despues del + haya 5- (34+5-). Mueve el 5 donde esta el 4 
					;y el - donde esta el +
    jmp 	rotateLeft

is_sub:
    dec 	ESI
    dec 	ESI
    dec 	ESI
    dec 	ESI			;Por ejemplo,en la postfijo 34+, hay que posicionarse en el 4.
    mov         EDX, dword[ESI]    	;Copia el 4 al EDX
    dec 	ESI
    dec 	ESI
    dec 	ESI
    dec		ESI			;Se posiciona en el 3 y lo copia al EAX
    mov         EAX, dword[ESI]    
    PutLInt 	EAX
    PutCh	'-'
    PutLInt 	EDX
    nwln
    sub         EAX, EDX      		;hace la suma
    mov         [ESI], EAX		;guarda el resulado en la posicion del 3
					;despues de hacer eso, el 4 y el + son inservibles,
					;entonces, la idea es mover todo lo que
					;esta despues del +, dos espacios para atras.
					;Por ejemplo, que despues del + haya 5- (34+5-). Mueve el 5 donde esta el 4 
					;y el - donde esta el +
    jmp 	rotateLeft

is_mul:
    sub 	EDX, EDX
    dec 	ESI
    dec 	ESI
    dec 	ESI
    dec 	ESI			;Por ejemplo,en la postfijo 34+, hay que posicionarse en el 4.
    mov         ECX, dword[ESI]    	;Copia el 4 al EDX
    dec 	ESI
    dec 	ESI
    dec 	ESI
    dec		ESI			;Se posiciona en el 3 y lo copia al EAX
    mov         EAX, dword[ESI]
    test   	ECX, 80000000h
    jnz 	num1_is_neg
    test 	EAX, 80000000h
    jnz         mul_is_negative
    jmp 	mul_is_positive

num1_is_neg:
    test 	EAX, 80000000h
    jz          mul_is_negative
    not 	ECX
    inc 	ECX
    not 	EAX
    inc 	EAX
    jmp 	mul_is_positive

mul_is_negative: 
    PutLInt 	EAX
    PutCh	'*'
    PutLInt 	ECX 
    nwln 
    mul		ECX			;Hace la multiplicacion, si queda el overflow en el EDX, manda un msj y termina
    cmp 	EAX, 0
    jg 		overflow_mul
    mov         [ESI], EAX
    		
    jmp  	rotateLeft

mul_is_positive:
    PutLInt 	EAX
    PutCh	'*'
    PutLInt 	ECX 
    nwln 
    mul		ECX			;Hace la multiplicacion, si queda el overflow en el EDX, manda un msj y termina

    test	EDX, 4294967295
    jnz		overflow_mul
    test 	EAX, 80000000h
    jnz 	overflow_mul
    mov         [ESI], EAX		
    jmp  	rotateLeft

is_div:
    sub 	EDX, EDX
    dec 	ESI
    dec 	ESI
    dec 	ESI
    dec 	ESI			;Por ejemplo,en la postfijo 34+, hay que posicionarse en el 4.
    mov         ECX, dword[ESI]    	;Copia el 4 al EDX
    dec 	ESI
    dec 	ESI
    dec 	ESI
    dec		ESI			;Se posiciona en el 3 y lo copia al EAX
    mov         EAX, dword[ESI]
    test   	ECX, 80000000h
    jnz 	div_num_is_neg
    jmp 	apply_div

div_num_is_neg:
    test 	EAX, 80000000h
    jz          apply_div
    not 	ECX
    inc 	ECX
    not 	EAX
    inc 	EAX
    jmp 	apply_div

apply_div:
    PutLInt 	EAX
    PutCh	'/'
    PutLInt 	EDX 
    nwln 
    div		ECX			;Hace la multiplicacion, si queda el overflow en el EDX, manda un msj y termina
    mov         [ESI], EAX		
    jmp  	rotateLeft

rotateLeft:
    inc   	ESI
    inc   	ESI
    inc   	ESI
    inc   	ESI
    mov         EBX, ESI
    inc 	EBX
    inc		EBX
    inc   	EBX
    inc   	EBX
    inc   	EBX
    inc   	EBX
    inc   	EBX
    inc   	EBX
    mov 	EAX, [EBX]
    mov         [ESI], EAX	;esa nueva posicion recibe el valor que tiene dos doubles por delante
    cmp		byte[EBX], '!'
    je		reset

 
    jmp		rotateLeft  

reset:
    mov 	ESI, exp
    jmp 	start
    
overflow_mul:
    PutStr	overflow_error_mul
    nwln
    jmp		exit

done:
    nwln
    cmp          byte[banderaBinario],1
    je          read_charBin
    cmp         byte[banderaHex],1
    je          read_charHex
    
    
    PutLInt      dword[exp]
    jmp         startCalc
;
;BIN---BIN-----BIN-----BIN----BIN----BIN-----BIN----BIN----
;BIN---BIN-----BIN-----BIN----BIN----BIN-----BIN----BIN----
;BIN---BIN-----BIN-----BIN----BIN----BIN-----BIN----BIN----
;BIN---BIN-----BIN-----BIN----BIN----BIN-----BIN----BIN----
;BIN---BIN-----BIN-----BIN----BIN----BIN-----BIN----BIN----
;BIN---BIN-----BIN-----BIN----BIN----BIN-----BIN----BIN----
;BIN---BIN-----BIN-----BIN----BIN----BIN-----BIN----BIN----
read_charBin:
     mov     byte[first_1_bin],1
     cmp     dword[exp],0
     jl      print_bin_complement 
read_charBin1:
     mov     EAX,dword[exp]       ;mueve el caracter al registro AL      
     mov     EDX,80000000H       ; mask byte = 80H
     mov     ECX,32        ; loop count to print 8 bits
     
print_bit:
     test    EAX,EDX        ; test does not modify AL
     jz      print_0      ; if tested bit is 0, print it
     cmp    byte[first_1_bin],1
     je     first_time_binary
print_1:     
     PutCh   '1'          ; otherwise, print 1
     jmp     skip1
print_0:
     cmp    byte[first_1_bin],1  
     je     skip1
     PutCh   '0'          ; print 0
skip1:
     shl     EAX,1         ; right-shift mask bit to test
                           ;  next bit of the ASCII code
     loop    print_bit    
    PutCh    " "
    jmp     startCalc
first_time_binary:
    PutCh   '0'
    mov     byte[first_1_bin],0
    jmp     print_1
    
    

print_bin_complement:
    mov         byte[first_1_bin],0
    jmp         read_charBin1      

;BIN---BIN-----BIN-----BIN----BIN----BIN-----BIN----BIN----
;BIN---BIN-----BIN-----BIN----BIN----BIN-----BIN----BIN----
;BIN---BIN-----BIN-----BIN----BIN----BIN-----BIN----BIN----
;BIN---BIN-----BIN-----BIN----BIN----BIN-----BIN----BIN----
;BIN---BIN-----BIN-----BIN----BIN----BIN-----BIN----BIN----
;BIN---BIN-----BIN-----BIN----BIN----BIN-----BIN----BIN----
;BIN---BIN-----BIN-----BIN----BIN----BIN-----BIN----BIN----


 ;-------HEX---HEX-----HEXHEXHEX-----HEX----HEX----HEX-----HEX-----
 ;-------HEX---HEX-----HEX-----------HEX----HEX----HEX-----HEX-----
 ;-------HEX---HEX-----HEX-----------HEX----HEX----HEX-----HEX-----
 ;-------HEX---HEX-----HEX-----------HEX----HEX----HEX-----HEX-----
 ;-------HEXHEXHEX-----HEXHEXHEX-----HEX----HEX----HEX-----HEX-----
 ;-------HEX---HEX-----HEX-----------HEX----HEX----HEX-----HEX-----
 ;-------HEX---HEX-----HEX-----------HEX----HEX----HEX-----HEX-----
 ;-------HEX---HEX-----HEX-----------HEX----HEX----HEX-----HEX-----
 ;-------HEX---HEX-----HEX-----------HEX----HEX----HEX-----HEX-----
 ;-------HEX---HEX-----HEXHEXHEX-----HEX----HEX----HEX-----HEX-----
 

read_charHex:
     mov     EAX, [exp]
     shr     EAX, 28        ; move upper 4 bits to lower half
     mov     CX,8         ; loop count - 2 hex digits to print
print_digitHex:
     test    AL, 1111b
     jz      byte_is_zeroHex
     jmp     byte_not_zeroHex

byte_is_zeroHex:
     cmp     byte[byteVar], 0
     je     skipHex2

byte_not_zeroHex:
     inc     byte[byteVar]
     cmp     AL,9         ; if greater than 9
     jg      A_to_FHex       ; convert to A through F digits
     add     AL,'0'       ; otherwise, convert to 0 through 9
     jmp     skipHex

A_to_FHex:
     add     AL,'A'-10    ; subtract 10 and add 'A'
                          ; to convert to A through F
skipHex:
     PutCh   AL           ; write the first hex digit

skipHex2:
     mov     EAX,[exp]   ; restore input character in AL
     cmp     CX,8
     je      count_is_8
     cmp     CX,7
     je      count_is_7
     cmp     CX,6
     je      count_is_6
     cmp     CX,5
     je      count_is_5
     cmp     CX,4
     je      count_is_4
     cmp     CX,3
     je      count_is_3
     and     AL, 0Fh

cont_printing_hex:
     loop    print_digitHex
     PutCh   'h'
     nwln
     jmp     exit_printing_hex

count_is_8:
     shr     EAX, 24
     and     AL, 0Fh
     jmp     cont_printing_hex
count_is_7:
     shr     EAX, 20
     and     AL, 0Fh
     jmp     cont_printing_hex 
count_is_6:
     shr     EAX, 16
     and     AL, 0Fh
     jmp     cont_printing_hex
count_is_5:
     shr     EAX, 12
     and     AL, 0Fh
     jmp     cont_printing_hex
count_is_4:
     shr     EAX, 8
     and     AL, 0Fh
     jmp     cont_printing_hex
count_is_3:
     shr     EAX, 4
     and     AL, 0Fh
     jmp     cont_printing_hex

exit_printing_hex:

    jmp     startCalc
 
 ;-------HEX---HEX-----HEX----HEX----HEX----HEX----HEX-----HEX-----
 ;-------HEX---HEX-----HEX----HEX----HEX----HEX----HEX-----HEX-----
 ;-------HEX---HEX-----HEX----HEX----HEX----HEX----HEX-----HEX-----
 ;-------HEX---HEX-----HEX----HEX----HEX----HEX----HEX-----HEX-----
 ;-------HEX---HEX-----HEX----HEX----HEX----HEX----HEX-----HEX-----
 ;-------HEX---HEX-----HEX----HEX----HEX----HEX----HEX-----HEX-----
 ;-------HEX---HEX-----HEX----HEX----HEX----HEX----HEX-----HEX-----
 ;-------HEX---HEX-----HEX----HEX----HEX----HEX----HEX-----HEX-----
 

exit:
    .EXIT
startHelp:
    jmp     startCalc

  
  