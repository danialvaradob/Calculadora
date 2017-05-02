%include "io.mac"

.DATA
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



.CODE
    .STARTUP

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
    
    .EXIT