extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_simplified
global alternate_sum_8
global product_2_f
global alternate_sum_4_using_c

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
; devuelve el resultado de la operación x1 - x2 + x3 - x4
alternate_sum_4:
	;prologo
	; COMPLETAR
	push rbp
	mov rbp, rsp

	mov rax, rdi
	sub rax, rsi
	add rax, rdx
	sub rax, rcx

	;recordar que si la pila estaba alineada a 16 al hacer la llamada
	;con el push de RIP como efecto del CALL queda alineada a 8

	;epilogo
	; COMPLETAR
	pop rbp

	ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
; devuelve el resultado la operación x1 - x2 + x3 - x4, usando obligatoriamente para las operaciones 
; las funciones provistas sumar_c y restar_c
alternate_sum_4_using_c:
	;prologo
	push rbp ; alineado a 16
	mov rbp,rsp

	call restar_c

	mov rdi, rax
	mov rsi, rdx
	call sumar_c

	mov rdi, rax
	mov rsi, rcx
	call restar_c

	;epilogo
	pop rbp
	ret


; uint32_t alternate_sum_4_simplified(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; registros: x1[rdi], x2[rsi], x3[rdx], x4[rcx]
;devuelve el resultado la operación x1 - x2 + x3 - x4. Esta función no crea ni el epílogo ni el prólogo
alternate_sum_4_simplified:
	mov rax, rdi
	sub rax, rsi
	add rax, rdx
	sub rax, rcx

	ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: x1[rdi], x2[rsi], x3[rdx], x4[rcx], x5[r8], x6[r9], x7[rbp+0x10], x8[rbp+0x18]
; devuelve el resultado de la operación x1 - x2 + x3 - x4 + x5 - x6 + x7 - x8
alternate_sum_8:
	;prologo
	push rbp
	mov rbp,rsp

	mov rax, rdi
	sub rax, rsi
	add rax, rdx
	sub rax, rcx
	add rax, r8
	sub rax, r9
	add rax, [rbp+0x10]
	sub rax, [rbp+0x18]

	;epilogo
	pop rbp
	ret


; SUGERENCIA: investigar uso de instrucciones para convertir enteros a floats y viceversa
;void product_2_f(uint32_t * destination, uint32_t x1, float f1);
;registros: destination[rdi], x1[rsi], f1[xmm0]

; Hace la multiplicación x1 * f1 y el resultado se almacena en destination. 
;Los dígitos decimales del resultado se eliminan mediante truncado

product_2_f:
	push rbp
	mov rbp,rsp

	cvtsi2ss xmm1, rsi 

	MULSs xmm0 , xmm1
	
	CVTTSs2SI rax, xmm0  ;algo con el truncado sale mal, ayuda
	
	mov [rdi], rax

	pop rbp
	ret

