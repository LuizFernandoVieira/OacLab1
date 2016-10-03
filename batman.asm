			jal FUNCAO_AMARELO
.eqv END_BASE 0xFF000000 # Endereço Base
.eqv COR_VERMELHA 0x07
.eqv COR_PRETA 0x00
.eqv COR_VERDE 0x28
.eqv COR_AMARELA 0x27
.eqv COR_AZUL 0xc0
.eqv WIDTH_INT 320
.eqv HEIGHT_INT 240

.data

	# Dados do Bitmap Display
	WIDTH:  .float 320
	HEIGHT: .float 240
	INTER: .float 0.05

	# Limites Inferiores e Superiores
	LINF_BAT: .float -7
	LSUP_BAT: .float 7

	# Auxiliares imediatos
	ZERO:   .float 0
	UM:     .float 1
	DOIS:   .float 2
	TRES:	  .float 3
	QUATRO: .float 4
	CINCO:  .float 5
	SETE:   .float 7

	M_UM:     .float -1
	M_TRES:	  .float -3
	M_QUATRO: .float -4

	# Auxiliares imediatos Amarelo
	AMARELO_AUX: .float 0.0913722

	# Auxiliares imediatos Verde
	VERDE_AUX_1: .float 2.71052
	VERDE_AUX_2: .float 1.5
	VERDE_AUX_3: .float 0.5
	VERDE_AUX_4: .float 1.35526
	VERDE_AUX_5: .float 0.9

	# Auxiliares imediatos Azul
	AZUL_AUX_1: .float 0.97
	AZUL_AUX_2: .float 0.5
	AZUL_AUX_3: .float 0.75


	PULA: .asciiz "\n "
	bla: .asciiz "teste"

.text

	MAIN:

		l.s $f0, LINF_BAT
		l.s $f1, LSUP_BAT

		jal PLANO_CARTESIANO
		jal INTERVALO
		jal DEFINE_QUADRADO

		jal DESENHA_VERMELHO
    l.s $f0, LINF_BAT
		jal DESENHA_AMARELO
    l.s $f0, LINF_BAT
		jal DESENHA_VERDE
    l.s $f0, LINF_BAT
		jal DESENHA_AZUL

		li $v0, 10
		syscall

  # FAUNÇÃO BATMAN
  # REFERENCIA = http://www.fernandosavio.com/simbolo-do-batman-no-resultado-do-google/

  # VERMELHA = (‑3)*sqrt(1-(x/7)^2)*sqrt( abs(abs(x)-4)/(abs(x)-4) )
	FUNCAO_VERMELHO:
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

		li $v0, 2
		syscall

		li $v0, 4
		la $a0, PULA
		syscall

		jr $ra

	# AMARELA = abs(x/2) - 0.0913722 * x^2 - 3 + sqrt(1-(abs(abs(x)-2)-1)^2)
	FUNCAO_AMARELO:
		l.s $f18, DOIS					# 2
		l.s $f19, TRES 					# 3
		l.s $f20, AMARELO_AUX  	# 0.0913722
		l.s $f21, UM 						# 1

		div.s $f14, $f0, $f18  # f14 = x / 2
		abs.s $f14, $f14 			 # f14 = abs (f14)
		mul.s $f13, $f0, $f0   # f13 = x * x
		mul.s $f13, $f20, $f13 # f13 = 0.0913722 * f13
		sub.s $f14, $f14, $f19 # f14 = f14 - 3
		sub.s $f13, $f14, $f13 # f13 = f14 - f13

		abs.s $f14, $f0        # f14 = abs(x)
		sub.s $f14, $f14, $f18 # f14 = f14 - 2
		abs.s $f14, $f14       # f14 = abs (f14)
		sub.s $f14, $f14, $f21 # f14 = f14 - 1
		mul.s $f14, $f14, $f14 # f14 = f14 * f14
		sub.s $f14, $f21, $f14 # f14 = 1 - f14
		sqrt.s $f14, $f14      # f14 = sqrt (f14)

		add.s $f12, $f13, $f14 # f12 = $f13 + $f14

		li $v0, 2
		syscall

		li $v0, 4
		la $a0, PULA
		syscall

		jr $ra

	# AZUL =
	# 2 * sqrt(  (‑abs(abs(x)-1)) * abs(3-abs(x)) / ((abs(x)-1)*(3-abs(x)))  )
	# *
	#		(1+abs(abs(x)-3)/(abs(x)-3))
	#		*
	#		sqrt(1-(x/7)^2)+(5+0.97*(abs(x-0.5)+abs(x+0.5))-3 * (abs(x-0.75)+abs(x+0.75)))
	#		*
	#		(1+abs(1-abs(x))/(1-abs(x)))
	FUNCAO_AZUL:
		l.s $f20, ZERO
		l.s $f21, TRES
		l.s $f22, UM
		l.s $f23, M_UM
		l.s $f24, DOIS
		l.s $f26, SETE
		l.s $f28, CINCO
		l.s $f29, AZUL_AUX_1			# 0.97
		l.s $f30, AZUL_AUX_2			# 0.5
		l.s $f31, AZUL_AUX_3			# 0.75

	  abs.s $f13, $f0        # f13 = abs (f0)			# abs(x)
	  add.s $f17, $f20, $f21 # f17 = 3						# 3
	  sub.s $f17, $f17, $f13 # f17 = f17 - f13 		# 3 - abs(x)
	  add.s $f16, $f20, $f17 # f16 = f17
		abs.s $f17, $f17       # f17 = abs (f17)		# abs(3 - abs(x))
	  sub.s $f13, $f13, $f22 # f13 = f13 - 1			# abs(x) - 1
	  add.s $f15, $f20, $f13 # f15 = f13
		abs.s $f13, $f13       # f13 = abs (f13) 		# abs(abs(x) - 1)
		mul.s $f13, $f13, $f23 # f13 = -f13					# (-abs(abs(x) - 1))
	  mul.s $f13, $f13, $f17 # f13 = f13 * f17  	# (‑abs(abs(x)-1))*abs(3-abs(x))
	  mul.s $f15, $f15, $f16 # f15 = f15 * f16  	# ((abs(x)-1)*(3-abs(x)))
		div.s $f13, $f13, $f15 # f13 = f13 / f15  	# (‑abs(abs(x)-1))*abs(3-abs(x)) / ((abs(x)-1)*(3-abs(x)))
		sqrt.s $f13, $f13      # f13 = sqrt (f13) 	# sqrt((‑abs(abs(x)-1))*abs(3-abs(x)) / ((abs(x)-1)*(3-abs(x))))
		mul.s $f13, $f13, $f24 # f13 = 2 * f13		 	# 2 * sqrt((‑abs(abs(x)-1))*abs(3-abs(x))/((abs(x)-1)*(3-abs(x))))

		div.s $f15, $f0, $f26  # f15 = f0 / 7				# x/7
		mul.s $f15, $f15, $f15 # f15 = f15 * f15		# (x/7)^2
		sub.s $f15, $f22, $f15 # f15 = 1 - f15			# 1 - (x/7)^2
		sqrt.s $f15, $f15      # f15 = sqrt(f15)		# sqrt(1 - (x/7)^2)

		mul.s $f15, $f15, $f13 # f15 = f15 * f13    # 2 * sqrt((‑abs(abs(x)-1))*abs(3-abs(x))/((abs(x)-1)*(3-abs(x))))  * sqrt(1 - (x/7)^2)

		sub.s $f16, $f0, $f30  # f16 = f0 - 0.5			# x - 0.5
		abs.s $f16, $f16       # f16 = abs(f16)			# abs(x - 0.5)
		add.s $f18, $f0, $f30  # f18 = f0 + 0.5			# x + 0.5
		abs.s $f18, $f18       # f18 = abs(f18)			# abs(x + 0.5)
		add.s $f16, $f16, $f18 # f16 = f16 + f18		# abs(x - 0.5) + abs(x + 0.5)
		mul.s $f16, $f29, $f16 # f16 = 0.97 * f16 	# 0.97 * (abs(x - 0.5) + abs(x + 0.5))
		add.s $f16, $f28, $f16 # f16 = 5 + f16			# 5 + 0.97 * (abs(x - 0.5) + abs(x + 0.5))
		sub.s $f17, $f0, $f31  # f17 = f0 - 0.75		# x - 0.75
		abs.s $f17, $f17       # f17 = abs(f17)			# abs(x - 0.75)
		add.s $f18, $f0, $f31  # f18 = f0 + 0.75		# x + 0.75
		abs.s $f18, $f18       # f18 = abs(f18)			# abs(x + 0.75)
		add.s $f17, $f17, $f18 # f17 = f17 + f18		# abs(x - 0.75) + abs(x + 0.75)
		mul.s $f17, $f21, $f17 # f17 = 3 * f17			# 3 * abs(x - 0.75) + abs(x + 0.75)
		sub.s $f17, $f16, $f17 # f17 = f16 - f17		# 5 + 0.97 * (abs(x - 0.5) + abs(x + 0.5)) - 3 * abs(x - 0.75) + abs(x + 0.75)

		abs.s $f16, $f0        # f16 = abs(f0)			# abs(x)
		sub.s $f16, $f22, $f16 # f16 = 1 - f16			# 1 - abs(x)
		add.s $f19, $f20, $f16 # f19 = f16
		abs.s $f16, $f16       # f16 = abs(f16) 		# abs(1 - abs(x))
		div.s $f16, $f16, $f19 # f16 = f16 / f19		# abs(1 - abs(x))/(1 - abs(x))
		add.s $f16, $f22, $f16 # f16 = 1 + f16			# 1 + abs(1 - abs(x))/(1 - abs(x))
		mul.s $f17, $f17, $f16 # f17 = f16 * f17		# (1 + abs(1 - abs(x))/(1 - abs(x))) * (5 + 0.97 * (abs(x - 0.5) + abs(x + 0.5)) - 3 * abs(x - 0.75) + abs(x + 0.75))

		abs.s $f14, $f0        # f14 = abs(f0)			# abs(x)
		sub.s $f14, $f14, $f21 # f14 = f14 - 3			# abs(x) - 3
		add.s $f19, $f20, $f14 # f19 = f14
		abs.s $f14, $f14       # f14 = abs(f14)			# abs(abs(x) - 3)
		div.s $f14, $f14, $f19 # f14 = f14 / f19		# abs(abs(x) - 3)/(abs(x) - 3)
		add.s $f14, $f22, $f14 # f14 = 1 + f14			# 1 + abs(abs(x) - 3)/(abs(x) - 3)
		mul.s $f15, $f15, $f14 # f15 = f15 * f14    # 2 * sqrt((‑abs(abs(x)-1))*abs(3-abs(x))/((abs(x)-1)*(3-abs(x))))  * sqrt(1 - (x/7)^2) * (1+​abs(​abs(​x)-​3)/​(abs(​x)-​3))

		add.s $f12, $f15, $f17 # f12 = f15 + f17    # 2 * sqrt((‑abs(abs(x)-1))*abs(3-abs(x))/((abs(x)-1)*(3-abs(x))))  * sqrt(1 - (x/7)^2) * (1+​abs(​abs(​x)-​3)/​(abs(​x)-​3)) + (1 + abs(1 - abs(x))/(1 - abs(x))) * (5 + 0.97 * (abs(x - 0.5) + abs(x + 0.5)) - 3 * abs(x - 0.75) + abs(x + 0.75))

		jr $ra

	# VERDE = (2.71052+1.5-0.5*abs(x) - 1.35526*sqrt(4-(abs(x)-1)^2)) * sqrt(abs(abs(x)-1)/(abs(x)-1)) + 0.9
	FUNCAO_VERDE:
		l.s $f18, VERDE_AUX_1 # 2.71052
		l.s $f19, VERDE_AUX_2 # 1.5
		l.s $f20, VERDE_AUX_3 # 0.5
		l.s $f21, VERDE_AUX_4 # 1.35526
		l.s $f22, VERDE_AUX_5	# 0.9
		l.s $f23, UM
		l.s $f24, QUATRO
														# (2.71052 + 1.5 -0.5*abs(x) - 1.35526 * sqrt(4-(abs(x)-1)^2))
		add.s $f13, $f18, $f19 	# f13 = 2.71052 + 1.5 									# 2.71052 + 1.5
		abs.s $f17, $f0 				# f17 = abs(f0)													# abs(x)
		mul.s $f17, $f17, $f20  # f17 = 0.5 * f17												# 0.5*abs(x)
		sub.s $f13, $f13, $f17  # f13 = f13 - f17												# 2.71052 + 1.5 - 0.5*abs(x)
		abs.s $f16, $f0 				# f16 = abs(f0)													# abs(x)
		sub.s $f16, $f16, $f23  # f16 = f16 - 1 												# abs(x) - 1
		mul.s $f16, $f16, $f16  # f16 = f16 * f16												# (abs(x)-1)^2)
		sub.s $f16, $f24, $f16  # f16 = 4 - f16													# 4 - (abs(x)-1)^2)
		sqrt.s $f16, $f16       # f16 = sqrt (f16)		 									# sqrt(4 - (abs(x)-1)^2))
		mul.s $f16, $f21, $f16  # 1.35526 * sqrt(4-(abs(x)-1)^2))				# 1.35526 * sqrt(4-(abs(x)-1)^2))
		sub.s $f13, $f13, $f16  # f13 = $f13 - $f16											# 2.71052 + 1.5 - 0.5*abs(x) - 1.35526 * sqrt(4-(abs(x)-1)^2))

										        # sqrt(abs(abs(x)-1)/(abs(x)-1))
		abs.s $f14, $f0         # f14 = abs ($f0)
		sub.s $f14, $f14, $f23  # f14 = f14 - 1
		abs.s $f15, $f14 				# f15 = abs (f14)
		div.s $f14, $f15, $f14  # f14 = f15 / f14
		sqrt.s $f14, $f14       # f14 = sqrt (f14)

		mul.s $f13, $f13, $f14 # f13 = $f13 * $f14
		add.s $f12, $f13, $f22  # f12 = $f13 + 0.9

		li $v0, 2
		syscall

		li $v0, 4
		la $a0, PULA
		syscall

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

#		l.s $f4, WIDTH
#		div.s $f27, $f25, $f4					# f4 = tamanho_x/320
		l.s $f27, INTER  							# determina um intervalo maior e mais exato para fins de eu decidi
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

	###################################################
	#
	# DESENHA VERMELHO
	#
	###################################################

	DESENHA_VERMELHO:

		li $v0, 4
		la $a0, bla
		syscall

		la $t2, END_BASE
		li $t3, COR_VERMELHA
		li $t4, WIDTH_INT
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		DESENHA_CALCULA_PONTO_VERMELHO:
			jal FUNCAO_VERMELHO

			# Verifica se o expoente é diferente de 255
			mfc1 $s0, $f12
			sll $s0, $s0, 1
			srl $s0, $s0, 24
			subi $s0, $s0, 255

			DESENHA_INCREMENTA_VERMELHO:
				add.s $f0, $f0, $f27			# x = x + tamanho_quadrado

				c.lt.s $f1, $f0						# se LSUP < x
				bc1t DESENHA_FIM_VERMELHO

				beq $s0, $zero, DESENHA_CALCULA_PONTO_VERMELHO		# Ignora f(x) = NaN ou f(x) = +/- inf

		DESENHA_CALCULA_X_VERMELHO:
			div.s $f4, $f0, $f27			# f4 = x/tamanho_quadrado
			floor.w.s $f4, $f4				# f4 = floor(f4)
			mfc1 $t0, $f4							# t0 = x/tamanho_quadrado

		DESENHA_CALCULA_Y_VERMELHO:
			div.s $f5, $f12, $f27			# f5 = y/tamanho_quadrado
			floor.w.s $f5, $f5				# f5 = floor(f5)
			mfc1 $t1, $f5

			subi $t1, $t1, 240
			abs $t1, $t1

		PLOTA_PONTO_VERMELHO:
			mul $t5, $t4, $t1					# t5 = 320*y
			add $t5, $t5, $t0					# t5 = 320*y + x
			add $t5, $t5, $t2					# t5 = END_BASE + 320*y + x

			addi $t5, $t5, -37920

			slt $s0, $t5, $t2					# se t5 < t2
			bne $s0, $zero, pula_print_VERMELHO

			sb $t3, 0($t5)						# plota o ponto no Bitmap Display

			pula_print_VERMELHO:
				j DESENHA_CALCULA_PONTO_VERMELHO

			# sb $t3, 0($t5)						# plota o ponto no Bitmap Display

			# j DESENHA_CALCULA_PONTO

		DESENHA_FIM_VERMELHO:
			lw $ra, 0($sp)
			addi $sp, $sp, 4

			jr $ra

	###################################################
	#
	# DESENHA AMARELO
	#
	###################################################

	DESENHA_AMARELO:

		li $v0, 4
		la $a0, bla
		syscall

		la $t2, END_BASE
		li $t3, COR_AMARELA
		li $t4, WIDTH_INT
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		DESENHA_CALCULA_PONTO_AMARELO:
			jal FUNCAO_AMARELO

			# Verifica se o expoente é diferente de 255
			mfc1 $s0, $f12
			sll $s0, $s0, 1
			srl $s0, $s0, 24
			subi $s0, $s0, 255

			DESENHA_INCREMENTA_AMARELO:
				add.s $f0, $f0, $f27			# x = x + tamanho_quadrado

				c.lt.s $f1, $f0						# se LSUP < x
				bc1t DESENHA_FIM_AMARELO

				beq $s0, $zero, DESENHA_CALCULA_PONTO_AMARELO		# Ignora f(x) = NaN ou f(x) = +/- inf

		DESENHA_CALCULA_X_AMARELO:
			div.s $f4, $f0, $f27			# f4 = x/tamanho_quadrado
			floor.w.s $f4, $f4				# f4 = floor(f4)
			mfc1 $t0, $f4							# t0 = x/tamanho_quadrado

		DESENHA_CALCULA_Y_AMARELO:
			div.s $f5, $f12, $f27			# f5 = y/tamanho_quadrado
			floor.w.s $f5, $f5				# f5 = floor(f5)
			mfc1 $t1, $f5

			subi $t1, $t1, 240
			abs $t1, $t1

		PLOTA_PONTO_AMARELO:
			mul $t5, $t4, $t1					# t5 = 320*y
			add $t5, $t5, $t0					# t5 = 320*y + x
			add $t5, $t5, $t2					# t5 = END_BASE + 320*y + x

			addi $t5, $t5, -37920

			slt $s0, $t5, $t2					# se t5 < t2
			bne $s0, $zero, pula_print_AMARELO

			sb $t3, 0($t5)						# plota o ponto no Bitmap Display

			pula_print_AMARELO:
				j DESENHA_CALCULA_PONTO_AMARELO

			# sb $t3, 0($t5)						# plota o ponto no Bitmap Display

			# j DESENHA_CALCULA_PONTO

		DESENHA_FIM_AMARELO:
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra

	###################################################
	#
	# DESENHA VERDE
	#
	###################################################

	DESENHA_VERDE:

		li $v0, 4
		la $a0, bla
		syscall

		la $t2, END_BASE
		li $t3, COR_VERDE
		li $t4, WIDTH_INT
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		DESENHA_CALCULA_PONTO_VERDE:
			jal FUNCAO_VERDE

			# Verifica se o expoente é diferente de 255
			mfc1 $s0, $f12
			sll $s0, $s0, 1
			srl $s0, $s0, 24
			subi $s0, $s0, 255

			DESENHA_INCREMENTA_VERDE:
				add.s $f0, $f0, $f27			# x = x + tamanho_quadrado

				c.lt.s $f1, $f0						# se LSUP < x
				bc1t DESENHA_FIM_VERDE

				beq $s0, $zero, DESENHA_CALCULA_PONTO_VERDE		# Ignora f(x) = NaN ou f(x) = +/- inf

		DESENHA_CALCULA_X_VERDE:
			div.s $f4, $f0, $f27			# f4 = x/tamanho_quadrado
			floor.w.s $f4, $f4				# f4 = floor(f4)
			mfc1 $t0, $f4							# t0 = x/tamanho_quadrado

		DESENHA_CALCULA_Y_VERDE:
			div.s $f5, $f12, $f27			# f5 = y/tamanho_quadrado
			floor.w.s $f5, $f5				# f5 = floor(f5)
			mfc1 $t1, $f5

			subi $t1, $t1, 240
			abs $t1, $t1

		PLOTA_PONTO_VERDE:
			mul $t5, $t4, $t1					# t5 = 320*y
			add $t5, $t5, $t0					# t5 = 320*y + x
			add $t5, $t5, $t2					# t5 = END_BASE + 320*y + x

			addi $t5, $t5, -37920

			slt $s0, $t5, $t2					# se t5 < t2
			bne $s0, $zero, pula_print_VERDE

			sb $t3, 0($t5)						# plota o ponto no Bitmap Display

			pula_print_VERDE:
				j DESENHA_CALCULA_PONTO_VERDE

			# sb $t3, 0($t5)						# plota o ponto no Bitmap Display

			# j DESENHA_CALCULA_PONTO

		DESENHA_FIM_VERDE:
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra

	###################################################
	#
	# DESENHA AZUL
	#
	###################################################

	DESENHA_AZUL:

		li $v0, 4
		la $a0, bla
		syscall

		la $t2, END_BASE
		li $t3, COR_AZUL
		li $t4, WIDTH_INT
		addi $sp, $sp, -4
		sw $ra, 0($sp)

		DESENHA_CALCULA_PONTO_AZUL:
			jal FUNCAO_AZUL

			# Verifica se o expoente é diferente de 255
			mfc1 $s0, $f12
			sll $s0, $s0, 1
			srl $s0, $s0, 24
			subi $s0, $s0, 255

			DESENHA_INCREMENTA_AZUL:
				add.s $f0, $f0, $f27			# x = x + tamanho_quadrado

				c.lt.s $f1, $f0						# se LSUP < x
				bc1t DESENHA_FIM_AZUL

				beq $s0, $zero, DESENHA_CALCULA_PONTO_AZUL		# Ignora f(x) = NaN ou f(x) = +/- inf

		DESENHA_CALCULA_X_AZUL:
			div.s $f4, $f0, $f27			# f4 = x/tamanho_quadrado
			floor.w.s $f4, $f4				# f4 = floor(f4)
			mfc1 $t0, $f4							# t0 = x/tamanho_quadrado

		DESENHA_CALCULA_Y_AZUL:
			div.s $f5, $f12, $f27			# f5 = y/tamanho_quadrado
			floor.w.s $f5, $f5				# f5 = floor(f5)
			mfc1 $t1, $f5

			subi $t1, $t1, 240
			abs $t1, $t1

		PLOTA_PONTO_AZUL:
			mul $t5, $t4, $t1					# t5 = 320*y
			add $t5, $t5, $t0					# t5 = 320*y + x
			add $t5, $t5, $t2					# t5 = END_BASE + 320*y + x

			addi $t5, $t5, -37920

			slt $s0, $t5, $t2					# se t5 < t2
			bne $s0, $zero, pula_print_AZUL

			sb $t3, 0($t5)						# plota o ponto no Bitmap Display

			pula_print_AZUL:
				j DESENHA_CALCULA_PONTO_AZUL

			# sb $t3, 0($t5)						# plota o ponto no Bitmap Display

			# j DESENHA_CALCULA_PONTO

		DESENHA_FIM_AZUL:
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
