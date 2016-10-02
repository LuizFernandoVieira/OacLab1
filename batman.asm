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
	LINF_BAT: .float -7
	LSUP_BAT: .float 7

	# Auxiliares como imediato
	ZERO: .float 0
	UM: .float 1
	DOIS: .float 2
	TRES:	.float 3
	SETE: .float 7

	M_QUATRO: .float -4
	M_TRES:	.float -3

	AMARELO_AUX: .float 0.0913722

.text

	MAIN:

		l.s $f0, LINF_BAT
		l.s $f1, LSUP_BAT

		jal PLANO_CARTESIANO
		jal INTERVALO
		jal DEFINE_QUADRADO
		jal DESENHA

		li $v0, 10
		syscall

  # FAUNÇÃO BATMAN
  # REFERENCIA = http://www.fernandosavio.com/simbolo-do-batman-no-resultado-do-google/
  
  # VERMELHA = (‑3)*sqrt(1-(x/7)^2)*sqrt( abs(abs(x)-4)/(abs(x)-4) )  
	FUNCAO_VERMELHO:	
		# x ta em $f0	

		l.s $f17, ZERO					# f17 = 0 (fiz isso para usar f17 como $zero)

		abs.s $f15, $f0 				# f15 = abs(x) 
		l.s $f18, M_QUATRO
		add.s $f15, $f15, $f18 	# f15 = f15 - 4
		add.s $f16, $f17, $f15	# f16 = f15
		abs.s $f15, $f15				# f15 = abs ($f15)
		div.s $f15, $f15, $f16  # f15 = f15 / f16
		sqrt.s $f14, $f15 		  # $f14 = sqrt ($f15)

		l.s $f18, SETE
		add.s $f13, $f17, $f18  # $f13 = 7
		div.s $f13, $f0, $f13		# $f13 = x/7
		mul.s $f13, $f13, $f13  # $f13 = $f13 * $f13
		l.s $f18, UM
		add.s $f15, $f17, $f18	#	$f15 = 1 ... CUIDADO!!! assumi que o f15 de cima nao seria mais util
		sub.s $f13, $f15, $f13  # $f13 = 1 - $f13
		sqrt.s $f13, $f13 			# $f13 = sqrt ($f13)

		mul.s $f13, $f13, $f14	# $f13 = $f13 * $f14
		l.s $f18, M_TRES
		add.s $f15, $f17, $f18 #	$f15 = -3 ... CUIDADO!!! assumi que o f15 de cima nao seria mais util
		mul.s $f12, $f13, $f15  # $f12 = $f13 * -3
		
		jr $ra

	# AMARELA = abs(x/2) - 0.0913722*x^2-3 + sqrt(1-(abs(abs(x)-2)-1)^2)
	FUNCAO_AMARELO:	

		l.s $f17, ZERO
		l.s $f18, DOIS
		l.s $f19, TRES
		l.s $f20, AMARELO_AUX
		l.s $f21, UM

		div.s $f14, $f0, $f18  # f14 = x / 2
		abs.s $f14, $f14 			 # f14 = abs (f14)
		mul.s $f13, $f0, $f0   # f13 = x * x
		sub.s $f13, $f13, $f19 # f13 = f13 - 3
		mul.s $f13, $f20, $f13 # f13 = 0.0913722 * f13
		sub.s $f13, $f14, $f13 # f13 = f14 - f13

		abs.s $f14, $f0        # f14 = abs(x)
		sub.s $f14, $f14, $f18 # f14 = f14 - 2
		abs.s $f14, $f14       # f14 = abs (f14)
		sub.s $f14, $f14, $f18 # f14 = f14 - 1
		mul.s $f14, $f14, $f14 # f14 = f14 * f14
		sub.s $f14, $f21, $f14 # f14 = 1 - f14
		sqrt.s $f14, $f14      # f14 = sqrt (f14)

		add.s $f12, $f13, $f14 # f12 = $f13 + $f14

		jr $ra

	# AZUL = 2*sqrt((‑abs(abs(x)-1))*abs(3-abs(x))/((abs(x)-1)*(3-abs(x))))*(1+abs(abs(x)-3)/(abs(x)-3))*sqrt(1-(x/7)^2)+(5+0.97*(abs(x-0.5)+abs(x+0.5))-3*(abs(x-0.75)+abs(x+0.75)))*(1+abs(1-abs(x))/(1-abs(x)))
	FUNCAO_AZUL:
		jr $ra

	# VERDE = (2.71052+1.5-0.5*abs(x)-1.35526*sqrt(4-(abs(x)-1)^2))*sqrt(abs(abs(x)-1)/(abs(x)-1))+0.9  
	FUNCAO_VERDE:
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
			jal FUNCAO_AMARELO

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
