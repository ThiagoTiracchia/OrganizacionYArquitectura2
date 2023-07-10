
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global complex_sum_z
global packed_complex_sum_z
global product_9_f

;########### DEFINICION DE FUNCIONES
;extern uint32_t complex_sum_z(complex_item *arr, uint32_t arr_length);
;// Devuelve la suma del atributo z de todos los complex_item's del array
;registros: arr[rdi], arr_length[rsi]
complex_sum_z:
	;prologo
	push rbp
	mov rbp,rsp

	add rdi, 0x18 ; toi en 1er Z :-D 
	xor rax, rax

	mov rcx, rsi ; carga la cantidad de iteraciones a hacer al contador de vueltas
	.cycle:     ; etiqueta a donde retorna el ciclo que itera sobre arr
		add rax, [rdi]
		add rdi, 0x20
	loop .cycle ; decrementa ecx y si es distinto de 0 salta a .cycle

	;epilogo
	pop rbp
	ret

;extern uint32_t packed_complex_sum_z(packed_complex_item *arr, uint32_t arr_length);
;registros: arr[?], arr_length[?]
packed_complex_sum_z:
	;prologo
	push rbp
	mov rbp,rsp
	
	add rdi, 0x14 ; toi en 1er Z :-D 
	xor rax, rax

	mov rcx, rsi ; carga la cantidad de iteraciones a hacer al contador de vueltas
	.cycle:     ; etiqueta a donde retorna el ciclo que itera sobre arr
		add rax, [rdi]
		add rdi, 0x18
	loop .cycle ; decrementa ecx y si es distinto de 0 salta a .cycle

	;epilogo
	pop rbp
	ret


;extern void product_9_f(uint32_t * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[rsi], f1[xmm0], x2[rdx], f2[xmm1], x3[rcx], f3[xmm2], x4[r8], f4[xmm3]
;	, x5[r9], f5[xmm4], x6[rbp+0x10], f6[xmm5], x7[rbp+0x18], f7[xmm6], x8[rbp+0x20], f8[xmm7],
;	, x9[rbp+0x28], f9[rbp+0x30] 
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp

	;convertimos los flotantes de cada registro xmm en doubles 396
	; CVTPS2PD xmm0, xmm0
	; CVTPS2PD xmm1, xmm1
	CVTSS2SD xmm0, xmm0
	CVTSS2SD xmm1, xmm1
	CVTSS2SD xmm2, xmm2
	CVTSS2SD xmm3, xmm3
	CVTSS2SD xmm4, xmm4
	CVTSS2SD xmm5, xmm5
	CVTSS2SD xmm6, xmm6
	CVTSS2SD xmm7, xmm7
	CVTSS2SD xmm8, [rbp+0x30]


	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	mulsd xmm0, xmm1
	mulsd xmm0, xmm2
	mulsd xmm0, xmm3
	mulsd xmm0, xmm4
	mulsd xmm0, xmm5
	mulsd xmm0, xmm6
	mulsd xmm0, xmm7
	mulsd xmm0, xmm8

	; convertimos los enteros en doubles y los multiplicamos por xmm0.
	CVTSI2SD xmm1, rsi
	CVTSI2SD xmm2, rdx
	CVTSI2SD xmm3, rcx
	CVTSI2SD xmm4, r8
	CVTSI2SD xmm5, r9
	CVTSI2SD xmm6, [rbp+0x10]
	CVTSI2SD xmm7, [rbp+0x18]
	CVTSI2SD xmm8, [rbp+0x20]
	CVTSI2SD xmm9, [rbp+0x28]
	
	mulsd xmm0, xmm1
	mulsd xmm0, xmm2
	mulsd xmm0, xmm3
	mulsd xmm0, xmm4
	mulsd xmm0, xmm5
	mulsd xmm0, xmm6
	mulsd xmm0, xmm7
	mulsd xmm0, xmm8
	mulsd xmm0, xmm9

	movsd [rdi], xmm0

	; epilogo
	pop rbp
	ret

