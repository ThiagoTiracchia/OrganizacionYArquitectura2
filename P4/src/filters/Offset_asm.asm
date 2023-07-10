;gdb --args simd Offset -i asm paisaje.bmp
;se rompe sigsev noooooooo

.rodata:
azul:		 times 4 db 0x00,0xFF, 0xFF, 0x00
azulVerde: 	 times 4 db 0x00,0x00, 0xFF, 0x00
todoMenosTrans: times 4 db 0xFF, 0xFF, 0xFF, 0x00
transparencia: 	 times 4 db 0x00, 0x00, 0x00, 0xFF

.text:
global Offset_asm
;void Offset_asm (uint8_t *src, uint8_t *dst, int width, int height, int src_row_size, int dst_row_size);
;rdi = *src, rsi = *dst; rdx = width, rcx = height, r8 = src_row_size, r9 = dst_row_size
Offset_asm:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	sub rsp, 8
	
	xor r10, r10 ; iterador para las filas

	mov r12, rcx
	sub r12, 8		; r12 = rcx - 8

	mov r13, rdx
	sub r13, 8		; r13 = rdx - 8

	.primerasF:
		xor r11, r11 ; iterador para las columnas
		.primCol:
			movdqu xmm0, [transparencia] 
			movdqu [rsi], xmm0

			add rdi, 16		; sino muevo la foto que quiero sacar al final
			add rsi, 16
			add r11, 4
			cmp r11, rdx    ; mientras r11 no sea igual al ancho es porque todavía me falta analizar columnas
		jne .primCol

		inc r10
		cmp r10, 8  		; mientras r10 no sea igual al alto es porque todavía me falta anaizar filas
	jl .primerasF

	 
	.filasMedio:
		xor r11, r11 ; iterador para las columnas
		.colMedio:
			cmp r11, 8	; Si r11<8 no estoy en las primeras 8 columnas y todo bien, pero sino, tengo que hacer el borde negro
			jge .noPrincipio

			;Coloreamos los 4 pixeles en negro
			movdqu xmm0, [transparencia] 
			movdqu [rsi], xmm0
			jmp .finCol

			.noPrincipio:

			cmp r11, r13	; Si r11<rdx-8 no estoy en las últimas 8 columnas y todo bien, pero sino, tengo que hacer el borde negro
			jl .colores

			;Coloreamos los 4 pixeles en negro
			movdqu xmm0, [transparencia] 
			movdqu [rsi], xmm0
			jmp .finCol

			;Coloreamos los 4 pixeles con offset
			.colores:
				movdqu xmm2, [rdi + 8 * r8] 			; pixeles de donde voy a calcular el azul
				movdqu xmm3, [rdi + 8 * 4]				; pixeles de donde voy a calcular para calcular el verde
				movdqu xmm4, [rdi + 8 * r8 + 8 * 4] 	; pixeles de donde voy a calcular para calcular el rojo



				movdqu xmm1, xmm2 			; xmm1 = xmm2, y xmm2 es de donde quiero sacar el azul 

				movdqu xmm0, [azul]	 		; máscara para el blend, me quedo del xmm1 SOLO los bytes donde tengo el azul
				pblendvb xmm1, xmm3    		; el resto de los bytes que NO son azul quedan igual a los del xmm3

				movdqu xmm0, [azulVerde]		; máscara para el blend, me quedo del xmm1 SOLO los bytes donde tengo el azul y verde
				pblendvb xmm1, xmm4    		; el resto de los bytes que NO son azul ni verde quedan igual a los del xmm4

				movdqu xmm0, [todoMenosTrans]
				movdqu xmm2, [transparencia]
				pand xmm1, xmm0 	; y seteo todas las transparencias en 0xFF
				por xmm1, xmm2

				movdqu [rsi], xmm1		; guardo en el destino el resultado 
	

			.finCol:		; aumento los iteradores
			add rdi, 16
			add rsi, 16
			add r11, 4

			cmp r11, rdx    ; mientras r11 no sea igual al ancho es porque todavía me falta analizar columnas
		jne .colMedio

		inc r10
		cmp r10, r12  		; mientras r10 no sea igual al alto es porque todavía me falta anaizar filas
	jne .filasMedio

	.ultF:
		xor r11, r11 ; iterador para las columnas
		
		.ultCol:
			movdqu xmm0, [transparencia] 
			movdqu [rsi], xmm0

			add rsi, 16
			add r11, 4
			cmp r11, rdx    ; mientras r11 no sea igual al ancho es porque todavía me falta analizar columnas
		jne .ultCol
	
		inc r10
		cmp r10, rcx  		; mientras r10 no sea igual al alto es porque todavía me falta anaizar filas
	jne .ultF

	add rsp, 8
	pop r13
	pop r12
	pop rbp
	ret




