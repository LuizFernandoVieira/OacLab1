.eqv END_BASE 0xFF000000 # Endereço Base
.eqv COR_VERMELHA 7
.eqv COR_PRETA 0
.eqv WIDTH_INT 320
.eqv HEIGHT_INT 240

.data

	# Dados do Bitmap Display
	WIDTH: .float 320
	HEIGHT: .float 240
	
	# Limites Inferiores e Superiores
	LINF_A: .float -1
	LSUP_A: .float 1
	
.text

	MAIN:
		
		l.s $f0, LINF_A
		l.s $f1, LSUP_A
		
		jal PLANO_CARTESIANO
		jal INTERVALO
		jal DEFINE_QUADRADO
		jal DESENHA
		
		li $v0, 10
		syscall
		
	# FUNÇÃO A => f(x) = -x
	FUNCAO_A:
		neg.s $f12, $f0
		jr $ra	
	
	# REG Nº 25 TEM O TAMANHO DO INTERVALO DE X
	INTERVALO:
		
		sub.s $f25, $f1, $f0					# f25 = LSUP - LINF
		abs.s $f25, $f25
		floor.w.s $f25, $f25
		cvt.s.w $f25, $f25
		
		jr $ra
		
	# REG Nº 27 TEM O TAMANHO DO QUADRADO
	DEFINE_QUADRADO:
	
		l.s $f4, WIDTH
		div.s $f27, $f25, $f4					# f4 = tamanho_x/320
		
		jr $ra

	PLANO_CARTESIANO:
		
		la $t0, END_BASE
		li $t1, HEIGHT_INT
		li $t2, WIDTH_INT
		li $t3, COR_PRETA
		
		addi $t4, $t0, 160					# t0 = end_base + 160 pixels
		
		EIXO_Y:
			sb $t3, 0($t4)
			
			addi $t1, $t1, -1						# t1 = t1 - 1 = height - 1
			beq $t1, $zero, EXIT_Y
			addi $t4, $t4, 320
			j EIXO_Y
			
			EXIT_Y:
				addi $t0, $t0, 38400			# offset para plotar eixo x
			
		EIXO_X:
			sb $t3, 0($t0)
			
			addi $t2, $t2, -1						# t2 = t2 - 1 = width - 1
			beq $t2, $zero, EXIT_X
			addi $t0, $t0, 1
			j EIXO_X
		
			EXIT_X:
				jr $ra

	DESENHA:
		
		la $t2, END_BASE
		li $t3, COR_VERMELHA
		li $t4, WIDTH_INT
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		DESENHA_CALCULA_PONTO:
			jal FUNCAO_A
		
			# Verifica se o expoente é diferente de 255
			mfc1 $s0, $f12
			sll $s0, $s0, 1
			srl $s0, $s0, 24
			subi $s0, $s0, 255
			
			DESENHA_INCREMENTA:
				add.s $f0, $f0, $f27			# x = x + tamanho_quadrado
			
				c.lt.s $f1, $f0						# se LSUP < x
				bc1t DESENHA_FIM
			
				beq $s0, $zero, DESENHA_CALCULA_PONTO		# Ignora f(x) = NaN ou f(x) = +/- inf
		
		DESENHA_CALCULA_X:
			div.s $f4, $f0, $f27			# f4 = x/tamanho_quadrado
			floor.w.s $f4, $f4				# f4 = floor(f4)
			mfc1 $t0, $f4							# t0 = x/tamanho_quadrado
					
		DESENHA_CALCULA_Y:
			div.s $f5, $f12, $f27			# f5 = y/tamanho_quadrado
			floor.w.s $f5, $f5				# f5 = floor(f5)
			mfc1 $t1, $f5

			subi $t1, $t1, 240
			abs $t1, $t1
					
		PLOTA_PONTO:
			mul $t5, $t4, $t1					# t5 = 320*y
			add $t5, $t5, $t0					# t5 = 320*y + x
			add $t5, $t5, $t2					# t5 = END_BASE + 320*y + x
			
			addi $t5, $t5, -25079
			
			sb $t3, 0($t5)						# plota o ponto no Bitmap Display
		
			j DESENHA_CALCULA_PONTO
										
		DESENHA_FIM:
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
