extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
; // Compara dos strings en orden lexicográfico. Ver https://es.wikipedia.org/wiki/Orden_lexicografico.
; // Debe retornar: 
; // 0 si son iguales
; // 1 si a < b
; //-1 si a > b
strCmp:
	push rbp
	mov rbp,rsp

	xor rax, rax ; r=0
	xor r8, r8

	.cycle:     ; etiqueta a donde retorna el ciclo que itera sobre arr

		mov r11b, [rdi + r8]
		cmp r11b, 0
		je .preFinal

		mov r9b, [rsi + r8]
		cmp r9b, 0
		je .menorB
	
		cmp r11b,  r9b
		jl .menorA
		jg .menorB

		inc r8
	jmp .cycle 

	.preFinal:
		cmp byte [rsi + r8], 0
		jne .menorA
	jmp .final

	.menorA:
		inc rax
	jmp .final

	.menorB:
		dec rax
	jmp .final

	.final:
	pop rbp
	ret

strClone:
	push rbp
	mov rbp,rsp

	push rdi
	sub rsp, 8
	call strLen ; obtengo la longitud del string a copiar
	mov rdi, rax
	mov r12, rax
	inc r12
	inc rdi ; para el caracter nulo que no es incluido en Len
	call malloc WRT ..plt ; pido la memoria para copiarlo (1 char ocupa 1 byte)
	add rsp, 8
	pop rdi

	xor r11b, r11b
	xor r9, r9
	mov rcx, r12
	
	.cycle:     ; etiqueta a donde retorna el ciclo que itera sobre arr
		mov byte r11b, [rdi + r9]
		mov [rax + r9], r11b
		inc r9
	loop .cycle ; decrementa ecx y si es distinto de 0 salta a .cycle

	pop rbp
	ret

; void strDelete(char* a)
strDelete:
	; Esto no funciona porque copia el puntero al string
	; pero no el string en sí mismo
	push rbp
	mov rbp,rsp

	call free WRT ..plt
	
	pop rbp
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
	push rbp
	mov rbp,rsp

	call fprintf wrt ..plt
	
	pop rbp
	ret

; uint32_t strLen(char* a)
strLen:
	push rbp
	mov rbp,rsp

	mov r9, rdi
	xor rax, rax
	cmp byte [r9], 0
	je .fin


	.cycle:     ; etiqueta a donde retorna el ciclo que itera sobre arr
		inc rax
		inc r9
		cmp byte [r9], 0
	jne .cycle 


	.fin:
	pop rbp
	ret


; char* strClone(char* a)
