%include "io.mac"

.DATA
overflow_error_mul 	db  	'Ocurrió un overflow en una multiplicación',0

.UDATA
exp          resd 256


.CODE
    .STARTUP
    mov         EBX, exp
    mov 	dword[EBX], -1400000
    inc		EBX
    inc 	EBX
    inc		EBX
    inc 	EBX
    mov 	dword[EBX], -15
    inc		EBX
    inc 	EBX
    inc		EBX
    inc 	EBX
    mov 	dword[EBX],'/'
    inc		EBX
    inc 	EBX
    inc		EBX
    inc 	EBX
    mov 	dword[EBX],'!'

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
    inc 	ESI
    inc 	ESI
    inc 	ESI
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
    mul		ECX			;Hace la multiplicacion, si queda el overflow en el EDX, manda un msj y termina
    cmp 	EAX, 0
    jg 		overflow_mul
    mov         [ESI], EAX
    		
    jmp  	rotateLeft

mul_is_positive:
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
    PutLInt      [exp]
    nwln

exit:
    .EXIT

