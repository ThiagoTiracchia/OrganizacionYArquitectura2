global invertirBytes_asm

; void invertirBytes_asm(uint8_t* p, uint8_t n, uint8_t m)


section .rodata
mivar: db 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

section .text


invertirBytes_asm:
    push rbp
    mov rbp, rsp
	xor rcx, rcx

	movdqu xmm15, [rdi] ;copio el vector que quiero modificar a xmm15

	cmp sil, dl
	jl .nMasChico
	;el valor más chico lo queremos tener en sil
	mov r8b, sil
	mov sil, dl
	mov dl, r8b

	.nMasChico:
	;creo la máscara para max(n, m)
	movdqu xmm0, [mivar]
	mov cl, dl ;cuantas veces shifteo
	.cycle1:
		PSLLDQ xmm0, 1 
	loop .cycle1

	pand xmm0, xmm15 ;me en xmm0 queda solo el byte que estaba en la posición max(n, m)

	;shifteo para mover el valor del byte más chico al más grande
	mov cl, dl 
	sub cl, sil
	.cycle2:
		PSRLDQ xmm0, 1
	loop .cycle2


	;creo la máscara para min(n, m)
	movdqu xmm1, [mivar]
	mov cl, sil ;cuantas veces shifteo
	.cycle3:
		PSLLDQ xmm1, 1 ;creo la máscara
	loop .cycle3

	pand xmm1, xmm15 ;me en xmm1 queda solo el byte que estaba en la posición min(n, m)

	;shifteo para mover el valor del byte más grande al más chico
	mov cl, dl 
	sub cl, sil
	.cycle4:
		PSLLDQ xmm1, 1
	loop .cycle4
	

	;me queda en xmm0 los valores de n y m swapeados, y el resto en 0
	por xmm0, xmm1 

	;creo la máscara para borrar los valores de n y m a corregir del vector original
	pxor xmm1, xmm1
	PCMPEQB xmm1, xmm0 ;nos pone todo en 1 los bytes que tenían 0 en xmm0 (los que no eran n ni m)

	;borro los valores de n y m del vector original, y luego se los vuelvo a agregar ya swapeados
	pand xmm15, xmm1
	por xmm15, xmm0	

	;copio el vector corregido en memoria
	movdqu [rdi], xmm15

	pop rbp
	ret

