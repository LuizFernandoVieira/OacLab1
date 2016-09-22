.eqv VGA 0xFF000000
.eqv WIDTH 320
.eqv HEIGHT 240

.data
INF:   .float -2.0
SUP:   .float 2.0
UM:    .float 1.0

.text
MAIN:
  jal PLOT
	li $v0,10
	syscall

PLOT:
  la $t7, VGA
	li $t6, WIDTH

	li $t5,0xC0  		# cor

	# jal PRINTA_EIXO_X
	# jal PRINTA_EIXO_Y

  add $s5, $zero, $ra

	jal FUNCAO_A

	jr $s5

# a) F(x)=-x .. [-1,1]
FUNCAO_A:
	li $t0, -1		# int x = -1
	li $t1, 1		# menor que

	li $t2, -1		# F(x)=-x

TESTA:
	bne $t0, $t1, LOOP_A	# x = -1   while(atual!=fim) do
	jr $ra

# a0
# a1
LOOP_A:
  addi $sp, $sp, -4
  sw $ra, 0($sp)

	add $a0, $zero, $t0		# a0 = x (t0 ainda tem x)
	mul $a1, $t0, $t2	# a1 = y
	jal DESENHA

  lw $ra, 0($sp)
  addi $sp, $sp, 4

	addi $t0, $t0, 1	# x++
  j TESTA

# a0 = x
# a1 = y
DESENHA:
  mul $t3,$t6,$a1   	# $t3 = 320*Y
  add $t3,$t3,$a0   	# $t3 = Y*320+X
  add $t3,$t3,$t7   	# $t3 = Endereco
  sb $t5,0($t3)	  	# plota o pixel na tela
  jr $ra

# b) F(x)=x^2+1 .. [-2,2]
FUNCAO_B:

# c) F(x)=sqrt(x) .. [-1,10]
FUNCAO_C:

# d) F(x)=(x+1)^2*(x-1)*(x-2)/(x-1.5) .. [-2,3]
FUNCAO_D:

PRINTA_EIXO_X:
	# INT X
	# FOR X < 320
	# DESENHA

PRINTA_EIXO_Y:
	# INT Y
	# FOR Y < 240
	# DESENHA
