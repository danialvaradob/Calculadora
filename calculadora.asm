;El siguiente programa es una calculadora que puede utilizar distintas bases y el resultado correcto, en decimal o en la 
;base deseada por el usuario
;
;Creado por: 
;    Daniel Alvarado
;    Sergio Hidalgo
;
;
;
;
;

%include "io.mac"

.DATA
welcome_msg              db       "Bienvenido a la calculadora BinOctHex!",0
input_sign               db       ">>",0
;operation                db      "b01010+h6B*22*2 =",0     ;variables para prueba
;operation               db     "10+5+o10 =o"
;operation                db      "#ayuda"
result_msg               db       "El resultado es: "
bin_error_msg            db      "Entrada binaria erronea",0
errormsg                 db      "ERROR",0
primer_op                db      1
overflow_error_mul 	db  	'Ocurrió un overflow en una multiplicación',0
byteVar                  db	0
byteVarOct               db	0







ayuda0			db 	'----------------AYUDA----------------',0
ayuda1			db	'La calculadora BinOctHex realiza operaciones combinadas utilizando los operadores aritméticos básicos: +, -, * y /',0
ayuda2			db	'Adicionalmente a estos operadores básicos, puede hacer uso de paréntesis para indicar alguna operación con mayor prioridad: (expresión).',0
ayuda3			db	'*NOTA*: Si hay operandos antes de iniciar un paréntesis, debe indicar qué operador desea aplicar entre el operando anterior al parentesis y el resultado de la expresión dentro de los paréntesis; igualemente, debe indicar el operador si hay operandos después del paréntesis.',0
ayuda4			db	'*OPERANDOS*: La calculadora permite 4 diferentes bases para indicar un número: binario, octal, decimal y hexadecimal. El valor máximo posible a representar para cada base es 2^31-1 (2147483647 en decimal).',0
ayuda5			db	'Para indicar una base, se coloca una letra reservada antes de escribir el número, las letras son: b-(binario), o-(octal), d-(decimal) y h-(hexadecimal), si se encuentra un numero sin letra al inicio, se toma como un número decimal.',0
ayuda6			db	'*NÚMEROS BINARIOS*: Por posición solo acepta un 1 o un 0. Si el número inicia con un 1 se tomará como complemento a la base 2, de lo contrario, tomará el numero de manera positiva.',0
ayuda7			db   	'*NÚMEROS OCTALES*: Por posición acepta todos los digitos entre el 0 y el 7',0
ayuda8			db   	'*NÚMEROS HEXADECIMALES*: Por posición acepta todos los digitos entre el 0 y el 9, y todas las letras entre A y F',0
ayuda9			db   	'*NÚMEROS DECIMALES*: Por posición acepta todos los digitos entre el 0 y el 9',0
ayuda10			db	'Para poder evaluar una expresión deberá escribir los operandos y operadores de forma correcta anteriormente explicado, cuando tenga lista la expresión DEBE agregar un espacio y un = al final de la expresión. Esto dará el resultado en decimal.',0
ayuda11			db	'Si desea imprimir el resultado en alguna base específica del programa, puede agregar una letra reservada despues del =',0
ayuda12			db	'Por ejemplo: num+(num2*num3/num4)-num5 =b   Esto dará el resultado de la expresión en binario',0


.UDATA
;operation      resb 256 
resultadoTotal  resd 1
cont            resb 1        
exp             resd 256 ;where the exp op will be stored

complement      resb 1   ;flag
banderaBinario  resb 1   ;si el usuario quiere el resultado en binario, se enciende 
banderaDecimal  resb 1   ;si el usuario quiere el resultado en decimal, se enciende
banderaHex      resb 1   ;si el usuario quiere el resultado en hexadecimal, se enciende 
banderaOct      resb 1   ;si el usuario quiere el resultado en octal, se enciende 
first_1_bin     resb 1   
minus_sign_flag resb 1   ;bandera utilizada para saber si se debe de cambiar el signo

.CODE
    .STARTUP

startCalc:
    nwln
    PutStr      welcome_msg
    nwln
    PutStr      input_sign
    GetStr      operation
    
    ;;;;;;;BANDERAS;;;;;;;;
    mov         byte[complement],0 ;   resetea el complemento
    mov         byte[banderaBinario],0 ;resetea la bandera de binario
    mov         byte[banderaDecimal],1      ;DEFAULT
    mov         byte[banderaHex],0     ;resetea la bandera de Hex
    mov         byte[banderaOct],0     ;resetea la bandera de Oct
    mov         byte[first_1_bin],0    ;bandera utilizada para el primer bit del binario, si es 1 se le aplica complemento a 2
    
    mov         ESI,operation   ;Puntero que recorre la expresion dada por el usuario
    mov         EDI,exp         ;Puntero que recorre la expresion post fijo que se crea a traves del programa
    mov         CX,15   
    cmp         byte[ESI],'#'   
    je          startHelp
startAll:

    cmp         byte[ESI],'d'
    je         readingDecimal1
    cmp         byte[ESI],'b' ;Salto a Binario
    je          startB
    cmp         byte[ESI],'h' ;Salto a Hexadecimal
    je          startCodeHex
    
    cmp         byte[ESI],'o'  ;Salto a Octal
    je          startCodeOct
    
    
    cmp         byte[ESI],20h  ;es un espacio, utilizado para saber cuando termino la expresion numerica
    je          stack_elements          
    cmp         byte[ESI],'='  ;el = es utilizado para saber cuando ya termino la variable
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
    cmp         byte[ESI],'9' 	;No hubo letra alguna, si es un numero, procede a leer ese numero como un decimal
    jg          not_number
    jmp         readingDecimal


add_exp:
    sub         EAX,EAX 
    sub         EDX,EDX
    sub         ECX,ECX
    sub         EBX,EBX

    mov        EAX,dword[resultadoTotal] ;resultadoTotal contiene el resultado de las conversiones a las diferentes bases u operandos
    mov        dword[EDI],EAX  		 ;se guardan en la lista postfijo siguiendo el orden de prioridades de los operadores
    inc         ESI  
    inc         EDI   
    inc         EDI
    inc         EDI
    inc         EDI			 ;se posiciona en el siguiente double de la variable postfijo
    jmp         startAll
        


stack_elements:  ;Operadores que quedaron en el stack
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

endCode: 			  ;terminó de mover los operadores que quedaron en la pila a la variable postfijo
    mov     dword[EDI],2147483647 ;condición de salida a la hora de evaluar la expresión postfijo

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
;             y saber cual agregar a la pila
;   
;--------------------------------------------------------------------    
;

    

operator_priority:
    cmp         byte[primer_op],1           ;si es el primero operador, sin importar lo que sea lo inserta en la pila
    je          firsttime
    sub         EBX,EBX
    pop         EBX                         ;toma lo que esta de primero en el stack
    cmp         BL,'-'
    je          continue_priorityToSMinPlus 
    cmp         BL,'+'
    je          continue_priorityToSMinPlus
    cmp         BL,'/'
    je          continue_priorityToSMultDiv
    cmp         BL,'*'
    je          continue_priorityToSMultDiv
    cmp         BL,'('
    jmp         both_elements_to_stack      ; si lo que saca es un parentesis, entonces el siguiente elemento debe de tomaro e insertarlo en la pila
    jmp         end_priority

firsttime:
    sub         EAX,EAX     
    mov         AL,byte[ESI]
    push        EAX  
    inc         byte[primer_op]
    jmp         operator_priority_end

continue_priorityToSMinPlus:        ;ToS es un '-'  o '+'
    cmp         byte[ESI],'('   
    je          both_elements_to_stack  ;si el nuevo operando es un parentesis inserta ambos elementos
    cmp         byte[ESI],')'
    je          right_parenthesis       ;se tiene que sacar todo hasta que se encuentre el parentesis izquierdo                      
    cmp         byte[ESI],'+'
    je         newE_to_stack            ;si el nuevo elemento es un +
    cmp         byte[ESI],'-'
    je         newE_to_stack            ;si el nuevo elemento es un -
    ;jmp         newE_to_stack         
both_elements_to_stack:        
    push        EBX                     ;inserta (pushes) de nuevo el elemento que se habia obtenido del stack
    sub         EAX,EAX 
    mov         AL,byte[ESI]            ;mueve el '*' o '/' al registro AL 
    push        EAX                     ;inserta (pushes) ese elmento en la pila    
    jmp         end_priority1               

continue_priorityToSMultDiv:            ;ToS es un * o /
    cmp         byte[ESI],'('   
    je          both_elements_to_stack  ; parentesis izquierdo mete ambos operadores a la pila
    cmp         byte[ESI],')'
    je          right_parenthesis       ; parentesis derecho                 
    jmp         newE_to_stack           ;el nuevo elemento siempre es agregado al stack y sacando el ultimo (que es una * o /)
                                        
                                
right_parenthesis:                    ;ciclo que obtiene todos los operadores hasta encontrarse el (
    cmp         BL,'('
    je          end_priority1         ;el ( simplemente se pierde, y ya se termina el ciclo
    mov         dword[EDI],EBX        ;agrega los operadores a la expresion posfijo
    inc         EDI
    inc         EDI
    inc         EDI
    inc         EDI
continue_right_paren:
    pop         EBX
    jmp         right_parenthesis
    


newE_to_stack:                  
                                ;con una prioridad menor o igual toma el ultimo elemento del stack y lo agrega a la variable
                                ;y el nuevo lo mete al stack (push)
                                
    sub         EAX,EAX       
    mov         AL,byte[ESI]	   ;toma el operador dela variable  (lo que digita el usuario)
    push 	EAX
    mov         dword[EDI],EBX   ;mueve el operando tomado de la pila a la variable postfijo
    inc         EDI
    inc         EDI
    inc         EDI
    inc         EDI

end_priority1: 
               
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
    cmp         byte[ESI+1],'-'   
    je         minus_sign   
    cmp         byte[ESI +1],'0'
    jl          not_number_nor_oper
    cmp         byte[ESI + 1],'9'
    jg          not_number_nor_oper 
    jmp         is_a_number
    
 
sum_sign:
    sub         BX,BX   
    jmp         operator_priority_end         
      
minus_sign:
    mov         byte[minus_sign_flag],0      
    
 entry_error:
 PutCh  'Q'
    PutStr      errormsg

not_number_nor_oper:
    PutStr      errormsg
 is_a_number:

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
     mul     EDX              ;se multiplica por 10 para luego sumarle el digito nuevo, 15 ---> 0*10 + 1 = 1 y luego 
                              ;                                                         1*10 + 5 = 15
     sub     ECX, ECX
     mov     CL, byte[ESI]
     add     EAX, ECX         ;aca hace la suma, donde se va acumulando el valor decimal
     inc     ESI 
     jmp condDecimal

question:
     jmp doneDecimal

error_outputDecimal:
     nwln
     PutStr  errormsg
     jmp question

doneDecimal:
    mov         dword[resultadoTotal],EAX  ;lo mueve a esta variable para luego ser agregado a la expresion posfijo
    dec         ESI                        ;decrementa el ESI, se devuelve un espacio en la expresion dada por el usuario
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
    mov         EBX,ESI         ;crea un segundo puntero a donde comienza el binario y poder obtener la cantidad de digitos
    mov         CX,CX
    mov         DX,0
    cmp         byte[ESI],'1'   ;si el primer bit que encuentra en el stirng es un 1
				;se debe aplicar complemento a 2 al numero binario
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
    cmp         byte[complement],1            ;si esta encendido empieza a invertir los digitos para el complemento, 1's por 0's y viceversa
    jne         continue_setting_counter      ;si esta apagado, sigue contando los bits normalmente
    cmp         byte[ESI],'0'
    je          change_zero
    dec         byte[ESI]
    jmp         continue_setting_counter
 
change_zero:
    inc         byte[ESI]         

    
continue_setting_counter:            
    inc         CX                 ;contador que lleva la cantidad de digitos
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
    
    push        EDX                  ;Mete en la pila lo que tenga EDX (nuevo valor binario)
                                     ;guardar la multiplicacion de la pila

    push        CX                  ;guardo el contador en la pila para despues reemplazarlo
    jmp        binary_exponent
end_exponent:    
    pop         CX                  ;obtiene el valor previo de CX

    pop        EDX                  ;se obtiene lo que se tenia guardado en AX
    pop        EBX     		    ;posicion del puntero en el string
    			            ;el resultado del exponente binario
    mul        EDX                  ;si es 2^3 en el AX hay un 8 y en el EDX esta el digito a multiplicar por la posicion
    add         dword[resultadoTotal],EAX   ;va agregando el resultado a esa posicion para asi 
                                            ;obener el resultado final de todas las sumas 
                                     
    inc         BX                  ;el puntero pasa a la siguiente posicion
    
    loop        binary_loop
    
endB:
    cmp         byte[complement],0 	;si no tiene encendida la bandera de complemento
    je          terminarB		;terminó de leer el número binario
    inc         dword[resultadoTotal]   ;de lo contrario, le incrementa (2do paso de la codificacion a complemento)
    not         dword[resultadoTotal]   ;y se convierte nuevamente a un numero negativo aplicando complemento
    inc         dword[resultadoTotal]
    
terminarB:
    dec         ESI
    mov         byte[complement],0
    jmp         add_exp         

complemento2:
    mov         byte[complement],1 	;se enciende la bandera que indica si se debe realizar el complemento
    jmp         setting_counter        
 


;----------------------------------------------------------
;Calling Functions
;----------------------------------------------------------
 
binary_exponent:
    sub         edx,edx
    sub         ebx, ebx
    mov         EAX,1    ;1 simplemente mueve un 1 al AX
    mov         EBX,2  ;2 mueve un 2 al DL ya que es un binary, si fuese hex seria un 16
    cmp         CX,1    ;si el contador es 1, salta a para retorna como resultado 1
    je         zero
    dec         CX      ;CX contiene la cantidad de digitos del numero, para acceder a la posicion de decrementa 1
  
    
procedure:              ;este loop se utiliza para sacar el resultado del exponente
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
    jmp         startCalc
  ;----------------------------------------------------------------------
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
  ; Octal
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
    cmp         DX, '7'		;revisa que digito hay en el string a la hora de leer un numero octal
    jg          error_oct	;si es mayor que 7 o menor que 0, no es número octal
    cmp         DX, '0'
    jl          error_oct
    sub         EDX, '0'  	;si lo que encuentra está entre 0 y 7, obtiene su valor 
    push        EBX		;inserta el puntero a la pila;
    push        EDX      	;inserta el valor del caractér a la pila
    push        ECX             ;y el contador de los digitos del numero
    jmp         Oct_exponent	;se procede a sacar el exponente de la posicion del numero

oct_expo_end: 
    pop         ECX		;saca los valores de la pila recientemente agregados, en orden
    pop         EDX           
    pop         EBX
    mul         EDX 		;multiplica el exponente obtenido en Oct_exponent por el valor del digito
    add         dword[resultadoTotal],EAX 	;se suma en la variable para luego insertar el resultado a la expresion postfijo
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

Oct_exponent: 	;Saca el exponente de un numero octal de acuerdo con su posicion 
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
    cmp         DX, 'F'		;revisa que digito hay en el string a la hora de leer un hexadecimal
    jg          error_outp	;si es mayor que F, menor que A, mayor que 9 o menor que 0, no es un valor hexadecimal
    cmp         DX, 'A'
    jge         is_letter	;si es una letra, hace una conversion
    cmp         DX, '9'
    jg          error_outp
    cmp         DX, '0'
    jge         sub_num		;si es un numero, hace otra conversion
    jmp 	error_outp

is_letter:
    sub         EDX, 55           ;le resta el valor decimal del valor de la letra 'A' en el codigo ASCII 
    jmp         mult_withInt

sub_num:
    sub         EDX, '0'	  ;le resta el valor '0' al EDX para obtener su valor real

mult_withInt:   
    push        EBX		;inserta el puntero a la pila,
    push        EDX             ;inserta el valor del caractér a la pila

    push        ECX             ;y el contador de los digitos del número para hacer un loop
    jmp         Hex_exponent
hex_expo_end:
    
    pop         ECX		;saca los valores de la pila recientemente agregados, en orden
    pop         EDX                  
    pop         EBX
    mul         EDX             ;multiplica el exponente obtenido en Hex_exponent por el valor del digito
    
    add         dword[resultadoTotal],EAX 	;se suma para guardar el resultado de la conversion
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
    jmp         startCalc

;----------------------------------------------------------
;Calling Functions
;----------------------------------------------------------
 
Hex_exponent: 	;Funcion que obtiene el exponente de un número hexadecimal utilizando su posicion
    sub         edx,edx
    sub         ebx, ebx
    mov         EAX,1 
    mov         EBX,16
    dec         CX 
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
 
    
    ;se limpian todos los registros
    sub         EBX,EBX
    sub         EDX,EDX
    sub         ECX,ECX
    sub         EAX,EAX
    sub         ESI,ESI
    sub         EDI,EDI
    
    mov         ESI,exp ;Puntero donde comienza la variable
    
start:
    sub 	       EAX, EAX

    mov         EAX,dword[ESI]	;En en EAX queda el valor a comparar
    ;
    ;se posiciona en el primer operador que encuentre para determinar que operacion se debe de hacer primero
    ;
    cmp 	      EAX,2147483647
    je 		      done
    cmp         EAX,'+'
    je          is_sum
    cmp         EAX,'-'
    je          is_sub
    cmp         EAX,'*'
    je          is_mul
    cmp         EAX,'/'
    je          is_div
    inc 	      ESI
    inc         ESI
    inc         ESI
    inc         ESI
    jmp    	    start

is_sum: 				;si entró aqui, se sabe que el operador es un '+', entonces debemos sacar
					;los dos operandos antes del operador y aplicarles la operación
    dec 	ESI
    dec 	ESI
    dec         ESI
    dec         ESI			;Por ejemplo,en la postfijo encuentra un 34+, entonces se posiciona en 4
    mov         EDX, dword[ESI]    	;y lo copia al EDX
    dec         ESI
    dec         ESI
    dec         ESI
    dec         ESI			 ;lo mismo con el otro operando, se posiciona en el 3 y lo copia al EAX
    mov         EAX, dword[ESI]    
    PutLInt 	  EAX
    PutCh	      '+'
    PutLInt 	  EDX
    nwln
    add         EAX, EDX      		;realiza la suma del primer operando (3) con el segundo (4)
    mov         [ESI], EAX		;guarda el resulado en la posicion del 3
					;despues de hacer eso, el 4 y el + son inservibles,
		                        ;entonces, se debe hacer un corrimiento de todos los valores
					;que se encuentran despues del +, dos espacios hacia atras.
					;Por ejemplo, que despues del 34+ haya 5- (34+5-). Se mueve el 5 donde esta el 4 
					;y el - donde esta el +
    jmp 	      rotateLeft

is_sub:
    dec         ESI
    dec         ESI
    dec         ESI
    dec         ESI			
    mov         EDX, dword[ESI]    	
    dec 	ESI
    dec         ESI
    dec         ESI
    dec	        ESI			
    mov         EAX, dword[ESI]    
    PutLInt     EAX
    PutCh	      '-'
    PutLInt 	  EDX
    nwln
    sub         EAX, EDX      		;saca los dos valores antes del operador y los resta
    mov         [ESI], EAX		;guarda el resulado en la posicion del ESI actual (ultimo operando visitado)
    jmp 	rotateLeft		;una vez que guarda el resultado hace el corrimiento de la expresion postfijo explicado en la suma

is_mul:
    sub         EDX, EDX
    dec         ESI
    dec         ESI
    dec         ESI
    dec         ESI			
    mov         ECX, dword[ESI]    	
    dec         ESI
    dec         ESI
    dec         ESI
    dec	        ESI			
    mov         EAX, dword[ESI]		;saca los dos valores antes del operador
    test    	  ECX, 80000000h	;revisa si son numero regativos con una mascara
    jnz         num1_is_neg		;si el resultado da cero, el numero es positivo, de lo contrario es negativo
    test        EAX, 80000000h		;si solo el segundo es negativo, la operacion es negativa
    jnz         mul_is_negative
    jmp 	mul_is_positive

num1_is_neg:
    test    	  EAX, 80000000h 	;si el segundo numero es positivo, la operacion es negativa (- x + = -)
    jz          mul_is_negative
    not         ECX 			;si ambos numeros son negativos, hay que hacerlos positivos y operarlos
    inc         ECX
    not 	      EAX
    inc 	      EAX
    jmp 	      mul_is_positive

mul_is_negative: 
    PutLInt 	  EAX
    PutCh	      '*'
    PutLInt 	  ECX 
    nwln 
    mul	    	  ECX			;Hace la multiplicacion, si queda el overflow en el EDX, manda un msj y termina
    cmp 	      EAX, 0
    jg 		      overflow_mul
    mov         [ESI], EAX
    		
    jmp  	      rotateLeft

mul_is_positive:
    PutLInt 	  EAX
    PutCh	      '*'
    PutLInt 	  ECX 
    nwln 
    mul		      ECX			;Hace la multiplicacion, si queda el overflow en el EDX, manda un msj y termina

    test	       EDX, 4294967295 		;mascara FFFFFFFFh
    jnz		       overflow_mul		;si es 0, no hay overflow
    test 	       EAX, 80000000h		;si en el EAX, el bit más significativo está encendido el hay overflow
    jnz 	       overflow_mul
    mov         [ESI], EAX		
    jmp  	       rotateLeft

is_div:
    sub 	       EDX, EDX
    dec 	       ESI
    dec 	       ESI
    dec        	 ESI
    dec 	       ESI			
    mov          ECX, dword[ESI]    	
    dec 	       ESI
    dec 	       ESI
    dec 	       ESI
    dec		       ESI			
    mov          EAX, dword[ESI] 	
    test   	     ECX, 80000000h	;revisa si el primer numero es negativo
    jnz 	       div_num_is_neg   ;si no da cero, es negativo
    jmp 	       apply_div

div_num_is_neg:
    test 	      EAX, 80000000h	;si el segundo tambien es negativo
    jz          apply_div
    not         ECX			;los convierte a positivos
    inc 	ECX
    not		EAX
    inc         EAX
    jmp         apply_div

apply_div:
    PutLInt 	 EAX
    PutCh	     '/'
    PutLInt 	 EDX 
    nwln 
    div		     ECX		;Realiza la division entre el EAX y el EXC
    mov        [ESI], EAX		
    jmp  	     rotateLeft

rotateLeft:    ;Funcion que mueve los operadores y operandos dos espacios atras, despues de hacer un operación
    inc        ESI
    inc   	   ESI
    inc   	   ESI
    inc   	   ESI
    mov        EBX, ESI
    inc 	     EBX
    inc		     EBX
    inc   	   EBX
    inc   	   EBX
    inc   	   EBX
    inc   	   EBX
    inc   	   EBX
    inc   	   EBX
    mov 	     EAX, [EBX]
    mov        [ESI], EAX	;esa nueva posicion recibe el valor que tiene dos doubles por delante
    cmp		     dword[EBX],2147483647
    je		     reset

 
    jmp		     rotateLeft  

reset:
    mov 	     ESI, exp
    jmp 	     start
    
overflow_mul:
    PutStr	   overflow_error_mul
    nwln
    jmp		     exit

done:
    nwln
    cmp         byte[banderaBinario],1    ;Saltos dependiendo de la representacion que quiera el usuario
    je          read_charBin
    cmp         byte[banderaHex],1
    je          read_charHex
    cmp         byte[banderaOct],1
    je          read_char_oct
    
    
    PutLInt      dword[exp]
    ;.EXIT
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
     shr     EAX, 28        	;mueve los 4 bits mas significativos a la mitad menor
     mov     CX,8           	;contador para el ciclo - 8 digitos hexadecimales a imprimir
print_digitHex:
     test    AL, 1111b
     jz      byte_is_zeroHex
     jmp     byte_not_zeroHex

byte_is_zeroHex:
     cmp     byte[byteVar], 0
     je     skipHex2

byte_not_zeroHex:
     inc     byte[byteVar]
     cmp     AL,9 		;si el valor de los 4 bits es mayor que 9
     jg      A_to_FHex       	;se convierte a letras
     add     AL,'0'       	;si no, se convierte en su caractér numérico correspondiente
     jmp     skipHex

A_to_FHex:
     add     AL,'A'-10    ; resta 10 y añade 'A'
skipHex:
     PutCh   AL           ;imprime el digito hexadecimal

skipHex2:
     mov     EAX,[exp]   ;restaura el valor del EAX
     cmp     CX,8 	 ;dependiendo del registro CX, el movimiento de los bits siempre será diferente
 			 ;siempre se van a mover de 4 en 4 bits dependiendo del CX y se aplica un 'and' de 0Fh al AL
			 ;para dejar el valor solo en los primeros 4 bits del AL
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
 
 
;------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT
;------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT
;------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT
;------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT
;------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT
;------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT
;------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT
;------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT

 
 read_char_oct:
     mov     EAX, [exp]
     shr     EAX, 30      ;mueve los 4 bits mas significativos a la mitad menor
     mov     CX,11        ;contador para el ciclo - 11 digitos octales a imprimir
print_digit_oct:
     test    AL, 111b
     jz      oct_is_zero
     jmp     oct_not_zero

oct_is_zero:
     cmp     byte[byteVarOct], 0
     je      skip_oct

oct_not_zero:
     inc     byte[byteVarOct]
     add     AL,'0'       ;se convierte en su caractér numérico correspondiente
     PutCh   AL           ;se imprime el caracter octal

skip_oct:
     mov     EAX,[exp]    ;restaura el valor del EAX
     cmp     CX,11	  ;dependiendo del registro CX, el movimiento de los bits siempre será diferente
 			  ;siempre se van a mover de 3 en 3 bits dependiendo del CX y se aplica un 'and' de 07h al AL
			  ;para dejar el valor solo en los primeros 3 bits del AL
     je      count_oct_is_11
     cmp     CX,10
     je      count_oct_is_10
     cmp     CX,9
     je      count_oct_is_9
     cmp     CX,8
     je      count_oct_is_8
     cmp     CX,7
     je      count_oct_is_7
     cmp     CX,6
     je      count_oct_is_6
     cmp     CX,5
     je      count_oct_is_5
     cmp     CX,4
     je      count_oct_is_4
     cmp     CX,3
     je      count_oct_is_3
     and     AL, 07h

cont_printing_oct:
     loop    print_digit_oct
     PutCh   'o'
     nwln
     jmp     exit_printing_oct

count_oct_is_11:
     shr     EAX, 27
     and     AL, 07h
     jmp     cont_printing_oct 
count_oct_is_10:
     shr     EAX, 24
     and     AL, 07h
     jmp     cont_printing_oct
count_oct_is_9:
     shr     EAX, 21
     and     AL, 07h
     jmp     cont_printing_oct
count_oct_is_8:
     shr     EAX, 18
     and     AL, 07h
     jmp     cont_printing_oct
count_oct_is_7:
     shr     EAX, 15
     and     AL, 07h
     jmp     cont_printing_oct 
count_oct_is_6:
     shr     EAX, 12
     and     AL, 07h
     jmp     cont_printing_oct
count_oct_is_5:
     shr     EAX, 9
     and     AL, 07h
     jmp     cont_printing_oct
count_oct_is_4:
     shr     EAX, 6
     and     AL, 07h
     jmp     cont_printing_oct
count_oct_is_3:
     shr     EAX, 3
     and     AL, 07h
     jmp     cont_printing_oct

exit_printing_oct:
      jmp startCalc
      
      
      
;
;------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT
;------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT
;------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT
;------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT
;------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT
;------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT
;------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT
;------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT------OCT

exit:
    .EXIT
startHelp:
    cmp         byte[ESI+1],'a'
    jne         endHelp
    cmp         byte[ESI+2],'y'
    jne         endHelp
    cmp         byte[ESI+3],'u'
    jne         endHelp
    cmp         byte[ESI+4],'d'
    jne         endHelp
    cmp         byte[ESI+5],'a'
    
    
    
    PutStr	ayuda0
    nwln
    PutStr      ayuda1
    nwln
    PutStr	ayuda2
    nwln
    PutStr	ayuda3
    nwln
    PutStr	ayuda4
    nwln
    PutStr	ayuda5
    nwln
    PutStr	ayuda6
    nwln
    PutStr	ayuda7
    nwln
    PutStr	ayuda8
    nwln
    PutStr	ayuda9
    nwln
    PutStr	ayuda10
    nwln
    PutStr	ayuda11
    nwln
    PutStr	ayuda12
    nwln
endHelp:
    .EXIT
    jmp     startCalc

  
  