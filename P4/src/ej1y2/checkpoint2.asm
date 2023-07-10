section .rodata
miVar: times 4 dd 08
section .text

global checksum_asm

; uint8_t checksum_asm(void* array, uint32_t n)

checksum_asm:
 	push rbp
    mov rbp, rsp

	mov al, 0x1
	mov ecx, esi
	pxor xmm14, xmm14 ; xmm14 es un registro todo con ceros
	movdqu xmm15, [miVar] ; xmm15 es un registro son 4 qw con el número 8
	xor r8d, r8d

	.cycle:
		
		movdqu xmm0, [rdi]; A
		movdqu xmm4, [rdi]; A
		add rdi, 16;bytes?
		movdqu xmm1, [rdi]; B
		movdqu xmm5, [rdi]; B
		add rdi, 16;
		movdqu xmm2, [rdi]; CLow 
		add rdi, 16;
		movdqu xmm3, [rdi]; CHigh 
		add rdi, 16;

		; para ver si cuentita = CLow
		
		PUNPCKLWD xmm0, xmm14 ; xmm0 tiene la parte baja de A
		PUNPCKLWD xmm1, xmm14 ; xmm1 tiene la parte baja de B en cajitas de 32

		PADDD xmm0, xmm1 ; sumo ambas
		PMULLD xmm0, xmm15 ; multiplico por 8 cada cajita de 32 bits 

		PCMPEQD xmm0, xmm2 ; comparo con CLow, y si es igual a Clow en todos los casos, entonces xmm4 son todos "1"
		PCMPEQD xmm0, xmm14	; si xmm0==xmm2, debería devolver un vector todo de "0"
		PHADDD xmm0, xmm0	; la suma las 4 dwors, y eso debería darme 0, sino alguna no cumplía la cuentita
		movq r9, xmm0
		cmp r9, 0 ;si la suma no dio 0, entonces ya hay un caso que no cumplió, y con eso alcanza para decir que es falso
		jne .afuera

		; para ver si cuentita = CHigh
		PUNPCKHWD xmm4, xmm14 ; xmm4 tiene la parte alta de A
		PUNPCKHWD xmm5, xmm14 ; xmm5 tiene la parte alta de B en cajitas de 32

		PADDD xmm4, xmm5
		PMULLD xmm4, xmm15

		PCMPEQD xmm4, xmm3 ; comparo con CHigh
		PCMPEQD xmm4, xmm14
		PHADDD xmm4, xmm4
		movq r9, xmm4
		cmp r9, 0 
		jne .afuera

		SUB ecx, 1
		cmp ecx,0
	jne .cycle
	jmp .final

	.afuera:
		mov al , 0

	.final: 
	pop rbp
	ret 

