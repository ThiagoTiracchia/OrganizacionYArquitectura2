
; 							| -1, -1, -1 |
; float sharpen[3][3] = 	| -1,  9, -1 |
; 							| -1, -1, -1 |

; hacible:
; idea: de la matriz p2-1,1 + p2-1,2 + p2-1,3 + 
; 				     p2-2,1 + p2-0   + p2-2,3 + 
; 				     p2-3,1 + p2-3,2 + p2-3,3		   

.rodata:
mask1: dd 0x00000000, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF
mask2: dd 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0x00000000
nueve: times 2 dw 9, 9, 9, 9

transparencia: 	 times 4 db 0x00, 0x00, 0x00, 0xFF


.text:
global Sharpen_asm

; *src = rdi, *dst = rsi, width = rdx, height = rcx, src_row_size = r8, dst_row_size = r9
Sharpen_asm:
	push rbp
	mov rbp, rsp
	push r13 	; :-(
	push r14	; :-)
	push r15	; :-(
	push r12 	; :-)

	mov r11, rdx ; ancho
	sub r11, 2 ; r11 = rdx - 3

	mov r12, rcx ; alto
	sub r12, 2	 ; r12 = rcx - 3


	xor r15, r15
	xor r14, r14

	xor r13, r13 ;iterador de pixeles

	movdqu xmm14, [mask2]	; agarra a P1
	movdqu xmm15,[mask1] 	; agarra a P2
	movdqu xmm9, [nueve] 	; tiene dieces

;DESPUES: esto es para saltear la 1era fila de dst, arreglar despues

	movdqu xmm13, [transparencia] 
	xor r10, r10 ; iterador para las columnas
	.primFilaNegra:
		movdqu [rsi + 4*r10], xmm13		; quiero leer 16 bytes después, que es lo mismo de decir que 4 pixeles de tamaño 4 bytes
		add r10, 4
		cmp r10, rdx    ; mientras r10 no sea igual al ancho es porque todavía me falta analizar columnas
	jne .primFilaNegra

	.fila:
		xor r14, r14
		movd [rsi + r9], xmm13	; pinto el primer pixel de la fila en negro
	
		.col:
			xor r10, r10 
			; siendo p1 y p2 los píxeles a analizar, y las "x" los pixeles de alrededor"
			movdqu xmm0, [rdi + r10] ; | x  x x  x |
			add r10, r8 ;iterador de fila a leer
			movdqu xmm1, [rdi + r10] ; | x p1 p2 x |
			add r10, r8
			movdqu xmm2, [rdi + r10] ; | x  x x  x |
									 ; 0			FF

			movdqa xmm3, xmm0 ; en xmm3 queda lo que necesito para p2 (Fila1) 
			pand xmm0, xmm14 ; en xmm0 para p1 fila1 
			pand xmm3, xmm15
			PSRLDQ xmm3, 4

			movdqa xmm4, xmm1 ; en xmm4 queda lo que necesito para p2 (Fila2)     0| 0 p1 p2 x |FF
			pand xmm1, xmm14 ; en xmm1 para p1 fila2    0 | x p1 p2 0 | FF
			pand xmm4, xmm15
			PSRLDQ xmm4, 4  ; 0| p1 p2 x 0 |FF

			movdqa xmm5, xmm2 ; en xmm4 queda lo que necesito para p2 (Fila3)
			pand xmm2, xmm14; en xmm2 para p1 fila3
			pand xmm5, xmm15
			PSRLDQ xmm5, 4

			xor rax, rax ; donde guardo mis 2 pixeles

		;para p2: xmm3 FILA1 , xmm4 es fila2, xmm5 es fila 3 

			movdqu xmm8, xmm4	; uso temp a xmm8
			;PSRLDQ xmm8, 4 		; xmm8 <- p1 p2 x x
			PMOVZXBW xmm8, xmm8 ; xmm8 <- dw tengo cada color: 0 | p1 p2 | FF
			PMULLW xmm8, xmm9 	; 9*xmm8 en cada word
			movdqu xmm7, xmm8
			PSRLDQ xmm7, 8      ; xmm7 <- 9*p2 x 

			;xmm3 <- 0 | x x x 0 | FF
			pshufd xmm6, xmm3, 0b11_11_00_11
			pshufd xmm12, xmm5, 0b11_11_11_00
			PSRLDQ xmm3, 4
			PSRLDQ xmm5, 4
			por xmm6, xmm12

			PMOVZXBW xmm3, xmm3
			PMOVZXBW xmm5, xmm5
			PMOVZXBW xmm6, xmm6

			PADDUSW xmm3, xmm5
			PADDUSW xmm3, xmm6 
			
			pshufd xmm5, xmm4, 0b11_11_10_00 ; xmm5 =  0| p1 x 0 0 |FF     xmm4 = 0| p1 p2 x 0 |FF
			PMOVZXBW xmm5, xmm5

			PADDUSW xmm3, xmm5
			movdqu xmm5, xmm3
			PSRLDQ xmm5, 8
			PADDUSW xmm3, xmm5

			PSUBUSW xmm7, xmm3
			PACKUSWB xmm7, xmm7
			MOVD eax, xmm7

			SHL rax, 32

		;para p1: xmm0 FILA1 , xmm1 es fila2, xmm2 es fila 3
			; xmm8 <- 9*p1 x
			;xmm0 <- 0 | x x x 0 | FF
			pshufd xmm5, xmm0, 0b11_11_00_11
			pshufd xmm6, xmm2, 0b11_11_11_00
			PSRLDQ xmm0, 4
			PSRLDQ xmm2, 4
			por xmm6, xmm5

			PMOVZXBW xmm0, xmm0
			PMOVZXBW xmm2, xmm2
			PMOVZXBW xmm6, xmm6

			PADDUSW xmm0, xmm2
			PADDUSW xmm0, xmm6 
			
			pshufd xmm2, xmm1, 0b11_11_10_00 ; xmm5 =  0| p1 x 0 0 |FF     xmm4 = 0| p1 p2 x 0 |FF
			PMOVZXBW xmm2, xmm2

			PADDUSW xmm0, xmm2
			movdqu xmm2, xmm0
			PSRLDQ xmm2, 8
			PADDUSW xmm0, xmm2

			PSUBUSW xmm8, xmm0
			PACKUSWB xmm8, xmm8
			xor r13, r13
			MOVD r13d, xmm8

			or rax, r13


			mov [rsi + r9 + 4], rax					;Escribo una fila y una columna después de donde haya leído (el centro del rectándulo)
			add rsi, 8 ; avanzo los siguientes 2 pixeles en salida
			add rdi, 8

			add r14, 2
			cmp r14, r11 ; cmp con ancho
		jl .col
		movd [rsi + r9 + 4], xmm13	; pinto el último pixel de la fila de negro
		add rsi, 8
		add rdi, 8

		inc r15	
		cmp r15, r12 	; cmp con alto
	jne .fila
	
	add rsi, r9
	xor r10, r10 ; iterador para las columnas
	.ultFilaNegra:
		movdqu [rsi + 4*r10], xmm13	; quiero leer 16 bytes después, que es lo mismo de decir que quiero leer 4 pixeles de tamaño 4 bytes
		add r10, 4
		cmp r10, rdx    ; mientras r10 no sea igual al ancho es porque todavía me falta analizar columnas
	jne .ultFilaNegra


	pop r12		; :-(
	pop r15		; :-)
	pop r14		; :-(
	pop r13 	; :-)
	pop rbp
	ret

