;String input converted to integer              STRINT.ASM
;
;        Objective: To convert the equivalent decimal number ot a string.
;            Input: Requests a string from the user.
;           Output: Prints the decimal number of the string.
%include "io.mac"
	
.DATA
string_prompt db  "Please enter a number: ",0
out_msg       db  "The number is ",0
error_msg     db  "Wrong input!",0
query_msg     db  "Do you want to try again?(Y/N): ",0

.UDATA
string       rest 1

.CODE
     .STARTUP
reading:
     PutStr  string_prompt  ; request a char. input
     GetStr  string          ; read input string
     sub     EAX, EAX
     mov     EBX, string
     
cond:   
     mov     DX, 10
     cmp     byte[EBX], 0
     je      question
     cmp     byte[EBX], '9'
     jg      error_output
     cmp     byte[EBX], '0'
     jl      error_output
     sub     byte[EBX], '0'
     mul     EDX
     sub     ECX, ECX
     mov     CL, byte[EBX]
     add     EAX, ECX
     inc     EBX 
     jmp cond

question:
     PutLInt EAX
     nwln
     PutStr  query_msg    ; query user whether to terminate
     GetCh   AL           
     cmp     AL,'Y'
     je     reading
     jmp done

error_output:
     nwln
     PutStr  error_msg
     jmp question

done:
     .EXIT