.eqv VGA 0xFF000000
.eqv WIDTH 320
.eqv HEIGHT 240
.eqv OFFSET_ORIGEM 38560
.eqv EIXO_X 38400
.eqv EIXO_Y 160

.data
ALTURA:	  .float  120.0
LARGURA:  .float  160.0
INF:      .float -100.0
SUP:      .float  100.0
UM:       .float +1.0
PRECISAO: .float  1.0
FUN_A:    .float -1.0
MENOS_UM: .float -1.0
DEBUG:    .asciiz "\n"
OFFSET:   .asciiz "Offset: "
ENDERECO: .asciiz "Endereco: "

.text
MAIN:
 	jal PLOT
	li $v0,10
	syscall

PLOT:
  la $t7, VGA
	li $t6, WIDTH

	li $t5,0x00  		# cor

	jal PRINTA_EIXO_X
	jal PRINTA_EIXO_Y

  li $t5, 0x7  		# cor

  add $s5, $zero, $ra

	jal ITEM_A

	jr $s5

# a) F(x)= -x .. [-1,1]
ITEM_A:
  l.s $f0, INF          # $f0 é o contador
	l.s $f1, SUP          # $f1 é o limite do contador
  l.s $f2, FUN_A		    # F(x)=-x
  l.s $f3, PRECISAO	    # x++
LOOP_A:
  c.lt.s $f0, $f1
  bc1t FUNCAO_A	          # while(atual<fim) do
  jr $ra
FUNCAO_A:
	mul.s $f12, $f0, $f2	      # $f12 = y
  j LABEL
LABEL:
  jal DESENHA
  add.s $f0, $f0, $f3     # x++
  j LOOP_A

# b) F(x)=x^2+1 .. [-2,2]
FUNCAO_B:

# c) F(x)=sqrt(x) .. [-1,10]
FUNCAO_C:

# d) F(x)=(x+1)^2*(x-1)*(x-2)/(x-1.5) .. [-2,3]
FUNCAO_D:

PRINTA_EIXO_X:
  li $t0, 0
  li $t1, 320
  li $t2, EIXO_X
VOLTA_PRINTA_X:
  bne $t0, $t1, PRINTA_X
  jr $ra
PRINTA_X:
  add $t3, $t2, $t7
  sb $t5, 0($t3)
  addi $t0, $t0, 1
  addi $t2, $t2, 1
  j VOLTA_PRINTA_X

PRINTA_EIXO_Y:
  li $t0, 0
  li $t1, 240
  li $t2, EIXO_Y
VOLTA_PRINTA_Y:
  bne $t0, $t1, PRINTA_Y
  jr $ra
PRINTA_Y:
  add $t3, $t2, $t7
  sb $t5, 0($t3)
  addi $t0, $t0, 1
  addi $t2, $t2, 320
  j VOLTA_PRINTA_Y

DESENHA:
  mtc1 $t6, $f4           # $f4 = $t6 = WIDTH (int)
 	cvt.s.w $f4, $f4        # $f4 = WIDTH (float)
 	mul.s $f5, $f4, $f12   	# $f5 = 320*Y

 	l.s $f20, MENOS_UM
 	mul.s $f5, $f5, $f20

 	add.s $f5, $f5, $f0   	# $f5 = Y*320+X (float)
  cvt.w.s $f5, $f5        # $f5 = Y*320+X (int)
  mfc1 $t9, $f5           # $t9 = offset

  add $t9, $t9, 38560

  add $t8, $t7, $t9   	# $t8 = Endereco + offset

 	sb $t5, 0($t8)	  	    # plota o pixel na tela

  li $v0, 32
  li $a0, 10
  syscall

  jr $ra
