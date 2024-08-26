.data
	xByte:		.byte 	'X'
	oByte:		.byte	'O'
	pipe:		.asciiz " | "
	arr1:		.word	0, 0, 0
	arr2:		.word 	0, 0, 0
	arr3:		.word	0, 0, 0
	newLine:	.asciiz "\n"
	
	empty:		.byte '_'

	# for which character the user wants
	askXO: .asciiz "Enter either X or O for your character: "
	printAssignedToX: .asciiz "\nYou are X and the computer is O\n"
	printAssignedToO: .asciiz "\nYou are O and the computer is X\n"
	uppercaseX: .byte 'X'
	uppercaseO: .byte 'O'
	lowercaseX: .byte 'x'
	lowercaseO: .byte 'o'
	choiceXO: .byte 'X'
	computerXO: .byte 'O'
	
	# to ask what position
	row: .asciiz "Enter desired row (0, 1, or 2): "
	column: .asciiz "Enter desired column (0, 1, or 2): "
	
	playerWinsText: .asciiz "Player wins\n"
	computerWinsText: .asciiz "Computer wins\n"
	drawText: .asciiz "Draw\n"

.text

main:

	jal setChoice
	
	#s0, s1, s2 arrays
	#t0 while loop check if continue or not
	#t1, t2 positions in insert at position
	#t1, index in printing single array

	li $s3, 5 # First player can go at max 5 moves
	la $s0, arr1
	la $s1, arr2
	la $s2, arr3

	whileLoop: 
		# Print arrays
		add $a0, $s0, $zero
		jal print_array
		add $a0, $s1, $zero
		jal print_array
		add $a0, $s2, $zero
		jal print_array
		
		# ask for input
		jal askRowColumn #return v0 and v1
		move $a0, $v0 # $a0 = row
		move $a1, $v1 # $a1 = column
		li $a2, 1 # Player 1's move is 1
		jal insert_element_at
				
		#check if won
		jal checkWin
		beq $v0, 1, playerWins
		
		addi $s3, $s3, -1
		beq $s3, $zero, draw
		
		#computer choice
		#get random indices
		jal computerRowColumn # Returns $v0 = row, $v1 = column
		move $a0, $v0 # $a0 = row
		move $a1, $v1 # $a1 = column
		li $a2, 2 # Player 2's move is 2
		jal insert_element_at
		
		#check if won
		jal checkWin
		beq $v0, 1, computerWins
		
		j whileLoop
	endWhileLoop:
	
	playerWins:
		la $a0, playerWinsText
		j printAndExit
	computerWins:
		la $a0, computerWinsText
		j printAndExit
	draw:
		la $a0, drawText
		j printAndExit
	printAndExit:
		li $v0, 4
		syscall
		# Print arrays
		add $a0, $s0, $zero
		jal print_array
		add $a0, $s1, $zero
		jal print_array
		add $a0, $s2, $zero
		jal print_array
		li $v0, 10 # exit the program 
		syscall 


# $a0: i index
# $a1: j index
# $a2: move (1 or 2)
insert_element_at: 

	#a0 contains index of first number
	#a1 contains index of second number
	add $t1, $a0, $zero
	add $t2, $a1, $zero
	
	### insert_array: $t3 = &arr? ###
	beq $t1, 0, insert_array_1
	beq $t1, 1, insert_array_2
	beq $t1, 2, insert_array_3
	j else
	insert_array_1:
		la $t3, arr1
		j insert_array_endif
	insert_array_2:
		la $t3, arr2
		j insert_array_endif
	insert_array_3:
		la $t3, arr3
		j insert_array_endif
	insert_array_endif:
	### insert_array ###
	
	sll $t2, $t2, 2
	#multiplying index by 4 to address array not needed
	add $t2, $t3, $t2 # $t2 = &arr?[j]
	
	sw $a2, 0($t2) # arr?[j] = move (1 or 2)
	jr $ra
	
	else:
	#incorrect output
	jr $ra
	
print_array:
	addi $sp, $sp, -4	#
	sw $ra, 0($sp)		# store $ra at 0
	
	#a0 address of array
	add $t1, $a0, $zero
	
	lw $a0, 0($t1)
	jal print_move
	
	la $a0, pipe
	li $v0, 4
	syscall	
	
	lw $a0, 4($t1)
	jal print_move
	
	la $a0, pipe
	li $v0, 4
	syscall	
	
	lw $a0, 8($t1)
	jal print_move
	
	li $v0, 4	
	la $a0, newLine
	syscall 
		
	lw $ra, 0($sp)		# Load $ra at 0
	addi $sp, $sp, 4	#
	jr $ra

# $a0 = move (0 or 1 or 2)
# Print _ if 0
# Print choiceXO if 1
# Print computerXO if 2
print_move:
	beq $a0, 1, print_move_1
	beq $a0, 2, print_move_2
	beq $a0, 0, print_empty
	print_empty:
		lb $a0, empty
		j print_move_endif
	print_move_1:
		lb $a0, choiceXO
		j print_move_endif
	print_move_2:
		lb $a0, computerXO
		j print_move_endif
	print_move_endif:
		li $v0, 11
		syscall
	jr $ra

# Returns $v0 = row, $v1 = column
askRowColumn:
	addi $sp, $sp, -12
	sw $ra, 8($sp)  # Store $ra into 0($sp)
	
	askRowColumnWhile:
		#ask for row
		li $v0, 4
		la $a0, row	#prints msg asking for which row they want
		syscall

		li $v0, 5	#reads in an integer for row
		syscall
		move $t0, $v0 # Store row into $t0
		sw $v0, 4($sp) # Store row into 4($sp)
	
		#ask for column
		li $v0, 4
		la $a0, column	#prints msg asking for which column they want
		syscall

		li $v0, 5	#reads in an integer for column
		syscall
		sw $v0, 0($sp) # Store column into 0($sp)
	
		move $a1, $v0 # input for column in $a1
		move $a0, $t0 # input for row in $a0
		jal positionIsEmpty # $v0 = 1 if positionIsEmpty, else 0
		
		beqz $v0, askRowColumnWhile # Keep asking until position is not empty
	askRowColumnWhile_break:
	
	lw $v1, 0($sp) # $v1 = column
	lw $v0, 4($sp) # $v0 = row
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra
	
# Returns $v0 = row, $v1 = column
computerRowColumn:
	addi $sp, $sp, -12
	sw $ra, 8($sp)  # Store $ra into 0($sp)

	computerRowColumnWhile:
		li $a1, 3		#3 possible random numbers (0, 1, or 2)
		li $v0, 42		#generates random int
		syscall
		
		sw $a0, 4($sp) # Store row into 4($sp)
		move $t0, $a0		#stores randomized int into $t0 for row
	
		li $a1, 3		#3 possible random numbers (0, 1, or 2)
		li $v0, 42		#random int stored in $v0 for row
		syscall
		sw $a0, 0($sp) # Store column into 0($sp)
		move $a1, $a0 # Store randomized int into $a1 for column
	
		move $a0, $t0		#stores randomized int into $a0 for row
		jal positionIsEmpty # $v0 = 1 if positionIsEmpty, else 0
		
		beqz $v0, computerRowColumnWhile # Keep generating until position is not empty
	computerRowColumnWhile_break:
	
	lw $v1, 0($sp) # $v1 = column
	lw $v0, 4($sp) # $v0 = row
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	jr $ra

# $a0 = row, $a1 = column
# $v0 = 1 if arr[row][column] == 0, else 0
positionIsEmpty:
	beq $a0, 0, load_array_1
	beq $a0, 1, load_array_2
	beq $a0, 2, load_array_3
	load_array_1:
		la $t0, arr1
		j load_array_endif
	load_array_2:
		la $t0, arr2
		j load_array_endif
	load_array_3:
		la $t0, arr3
		# j insert_array_endif
	load_array_endif:
	
	sll $t1, $a1, 2
	add $t0, $t0, $t1  # $t0 = &arr[row][column]
	
	lw $t0, 0($t0)  # $t0 = arr[row][column]
	seq $v0, $t0, $0
	
	jr $ra
	
setChoice:
	# $t2 holds 'X' & $t3 holds 'O'
	lb $t2, uppercaseX
	lb $t3, uppercaseO
	lb $t4, lowercaseX
	lb $t5, lowercaseO
	#prompt for X or O
	li $v0, 4
	la $a0, askXO	#ask user if they want to be X or O
	syscall
	#reads in the character input
	li $v0, 12
	syscall
	#if user chose one character, set computer to the other
	beq $v0, $t2, computerO		#if user chose X, computerO
	beq $v0, $t3, computerX		#if user chose O, computerX
	beq $v0, $t4, computerO		#if user chose X, computerO
	beq $v0, $t5, computerX		#if user chose O, computerX	
	computerO:
		#sets choiceXO as X
		la $t0, choiceXO
		li $t1, 'X'
		sb $t1, ($t0)
	
		#sets computerXO as O
		la $t0, computerXO
		li $t1, 'O'
		sb $t1, ($t0)
	
		la $a0, printAssignedToX
		li $v0, 4
		syscall
		jr $ra
	computerX:
		#sets choiceXO as X
		la $t0, choiceXO
		li $t1, 'O'
		sb $t1, ($t0)
	
		#sets computerXO as O
		la $t0, computerXO
		li $t1, 'X'
		sb $t1, ($t0)
	
		la $a0, printAssignedToO
		li $v0, 4
		syscall
		jr $ra
		
# checkWin(): check if the current move creates a win
# returns 1 if win is found, 0 otherwise
checkWin:
	addi $sp, $sp, -4	#
	sw $ra, 0($sp)		# store $ra at 0

	winRow0:	# g[0][X]
		la $t2, arr1		# $t2 = &arr1
		lw $t3, 0($t2)		# $t3 = arr1[0]
		lw $t4, 4($t2)		# $t4 = arr1[1]
		lw $t5, 8($t2)		# $t5 = arr1[2]

		and $t6, $t3, $t4	# AND $t3, $t4, and $t5,
		and $t6, $t6, $t5	# if they are the same we should get 1 or 2
		bne $t6, $zero, winReturn	# if winner found, return 1

	winRow1:	# g[1][X]
		la $t2, arr2		# $t2 = &arr2
		lw $t3, 0($t2)		# $t3 = arr2[0]
		lw $t4, 4($t2)		# $t4 = arr2[1]
		lw $t5, 8($t2)		# $t5 = arr2[2]

		and $t6, $t3, $t4	# AND $t3, $t4, and $t5,
		and $t6, $t6, $t5	# if they are the same we should get 1 or 2
		bne $t6, $zero, winReturn	# if winner found, return 1

	winRow2:	# g[2][X]
		la $t2, arr3		# $t2 = &ROW_2
		lw $t3, 0($t2)		# $t3 = ROW_2[0]
		lw $t4, 4($t2)		# $t4 = ROW_2[1]
		lw $t5, 8($t2)		# $t5 = ROW_2[2]

		and $t6, $t3, $t4	# AND $t3, $t4, and $t5,
		and $t6, $t6, $t5	# if they are the same we should get 1 or 2
		bne $t6, $zero, winReturn	# if winner found, return 1

	winCol0:	# g[X][0]
		la $t1, arr1		# $t1 = &arr1
		lw $t3, 0($t1)		# $t3 = arr1[0]

		la $t1, arr2		# $t1 = &arr2
		lw $t4, 0($t1)		# $t3 = arr2[0]

		la $t1, arr3		# $t1 = $arr3
		lw $t5, 0($t1)		# $t3 = arr3[0]

		and $t6, $t3, $t4	# AND $t3, $t4, and $t5,
		and $t6, $t6, $t5	# if they are the same we should get 1 or 2
		bne $t6, $zero, winReturn	# if winner found, return 1

	winCol1:	# g[X][1]
		la $t1, arr1		# $t1 = &arr1
		lw $t3, 4($t1)		# $t3 = arr1[1]

		la $t1, arr2		# $t1 = &arr2
		lw $t4, 4($t1)		# $t3 = arr2[1]

		la $t1, arr3		# $t1 = $arr3
		lw $t5, 4($t1)		# $t3 = arr3[1]

		and $t6, $t3, $t4	# AND $t3, $t4, and $t5,
		and $t6, $t6, $t5	# if they are the same we should get 1 or 2
		bne $t6, $zero, winReturn	# if winner found, return 1

	winCol2:	# g[X][2]
		la $t1, arr1		# $t1 = &arr1
		lw $t3, 8($t1)		# $t3 = arr1[2]

		la $t1, arr2		# $t1 = &arr2
		lw $t4, 8($t1)		# $t3 = arr2[2]

		la $t1, arr3		# $t1 = $arr3
		lw $t5, 8($t1)		# $t3 = arr3[2]

		and $t6, $t3, $t4	# AND $t3, $t4, and $t5,
		and $t6, $t6, $t5	# if they are the same we should get 1 or 2
		bne $t6, $zero, winReturn	# if winner found, return 1
		
	winDiag0:
		la $t1, arr1		# $t1 = &arr1
		lw $t3, 0($t1)		# $t3 = arr1[0]

		la $t1, arr2		# $t1 = &arr2
		lw $t4, 4($t1)		# $t3 = arr2[1]

		la $t1, arr3		# $t1 = $arr3
		lw $t5, 8($t1)		# $t3 = arr3[2]

		and $t6, $t3, $t4	# AND $t3, $t4, and $t5,
		and $t6, $t6, $t5	# if they are the same we should get 1 or 2
		bne $t6, $zero, winReturn	# if winner found, return 1
		
	winDiag1:
		la $t1, arr1		# $t1 = &arr1
		lw $t3, 8($t1)		# $t3 = arr1[2]

		la $t1, arr2		# $t1 = &arr2
		lw $t4, 4($t1)		# $t3 = arr2[1]

		la $t1, arr3		# $t1 = $arr3
		lw $t5, 0($t1)		# $t3 = arr3[0]

		and $t6, $t3, $t4	# AND $t3, $t4, and $t5,
		and $t6, $t6, $t5	# if they are the same we should get 1 or 2
		bne $t6, $zero, winReturn	# if winner found, return 1

	noWinReturn:
		li $v0, 0	# return 0 - which means no winner
		lw $ra, 0($sp)		# load $ra at 0
		addi $sp, $sp, 4	#
		jr $ra			# return address

	winReturn:
		addi $v0, $zero, 1	# return 1
		lw $ra, 0($sp)		# store value of return address into stack
		addi $sp, $sp, 4	# pop from stack
		jr $ra			# return address
