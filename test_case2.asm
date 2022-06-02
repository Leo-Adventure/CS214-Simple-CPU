.data # !!!remember to add 0x0000
 	# choose 8 * 9 + 10 bits as the space	
	# num1: .space 80
	# num2: .space 80
	# num3: .space 80
	# num4: .space 80
	
.text # !!!remember to add 0x0000

# ?????????maybe remember to add "start:"
.start:
	ori $v0, $zero, 1 # read test_num to $a0
	syscall
	
	ori $a0, $v0, 0
	ori $v0, $zero, 2
	syscall
	or $v1, $a0, $zero 
	
	ori $s1, $zero, 0
	ori $s2, $zero, 80
	ori $s3, $zero, 160
	ori $s4, $zero, 240
	
	add $t0, $zero, $zero # t0 as the counter i
loop1: # read the array's number
	ori $v0, $zero, 1 # read the number, now the number is stored in v0
	syscall
	
	
	
	sll $t1, $t0, 2
	sll $t2, $t0, 2
	sll $t3, $t0, 2
	sll $t4, $t0, 2
	
	add $t1, $s1, $t1 # t1 as the current address of num1
	add $t2, $s2, $t2 # t2 as the current address of num2
	add $t3, $s3, $t3 # t3 as the current address of num3
	add $t4, $s4, $t4 # t4 as the current address of num4
	
	sw $v0, 0($t1) # save the number in num1[i]
	sw $v0, 0($t2) # save the number in num2[i]
	
	lw $a0, 0($t1)
	ori $v0, $zero, 2
	syscall
	#display the input number

	srl $t5, $a0, 7
	andi $t5, $t5, 1 # get the sign bit
	
	addi $t6, $zero, 1 # just for temp reg storing 1
	beq $t5, $t6, negative_store # if the most significant bit is 1, then it's negative
positive_store:
	sw $a0, 0($t3) # save the number in num3[i]
	sw $a0, 0($t4) # save the number in num4[i]
	addi $t0, $t0, 1
	j test1 # jump away negative_store

negative_store:
	# get the correct negative number: (num[i] & 0b1111111) - 128;
	lui $t8, 0xffff
	ori $t8, $t8, 0xff7f
	xor $t6, $a0, $t8 #get negative first number
	addi $t6, $t6, 1
	sw $t6, 0($t3) # save the negative number in num3[i]
	sw $t6, 0($t4) # save the negative number in num4[i]
	addi $t0, $t0, 1
test1:# read number iteratively
	bne $t0, $v1, loop1 
	
	# after the read procedure, the t0 ~ t4 is free to use again
	# bubble sort for num2 and num4
	add $t6, $zero, $zero # reset tmp $t6 to zero (act as counter i)
	add $t7, $zero, $zero # reset tmp $t7 to zero (act as counter j)
	addi $a1, $v1, -1 # inside_loop sentinel: test_num - 1 in a1
	
	j outside_test
	
	addi $t0, $t0, 1
test_loop1: 
	bne $t0, $v1, loop1
	
outside_loop: # outside loop for bubble sort
	addi $t6, $t6, 1
	add $t7, $zero, $zero
	
inside_loop: # inside loop for bubble sort

	# get num2[j]
	sll $t0, $t7, 2
	add $t0, $t0, $s2
	lw $t1, 0($t0) # load data from num2[j] in t1
	# get num2[j + 1]
	addi $t0, $t7, 1
	sll $t0, $t0, 2
	add $t0, $t0, $s2
	lw $t2, 0($t0) # load data from num2[j + 1] in t2
	
exchange_test1:
	# blt $t1, $t2, exchange_test2 # if num2[j] < num2[j + 1], then jump out of following change part
	slt $t3, $t1, $t2 # if num2[j] < num2[j + 1], then t3 = 1
	bne $t3, $zero, exchange_test2 # if num2[j] < num2[j + 1], then jump out of following change part
	sw $t1, 0($t0) # num2[j + 1] = num2[j]
	# back to num2[j]
	sll $t0, $t7, 2
	add $t0, $t0, $s2
	sw $t2, 0($t0) # num2[j] = num2[j + 1]
	
exchange_test2:
	
	# get num4[j]
	sll $t0, $t7, 2
	add $t0, $t0, $s4
	lw $t1, 0($t0) # load data from num4[j] in t1
	# get num4[j + 1]
	addi $t0, $t7, 1
	sll $t0, $t0, 2
	add $t0, $t0, $s4
	lw $t2, 0($t0) # load data from num4[j + 1] in t2
	
	# blt $t1, $t2, exchange_out # if num2[j] < num2[j + 1], then jump out of following change part
	slt $t3, $t1, $t2
	bne $t3, $zero, exchange_out # if num2[j] < num2[j + 1], then jump out of following change part 
	sw $t1, 0($t0) # num4[j + 1] = num4[j]
	# back to num4[j]
	sll $t0, $t7, 2
	add $t0, $t0, $s4
	sw $t2, 0($t0) # num4[j] = num4[j + 1]

exchange_out:	
	
	addi $t7, $t7, 1

inside_test: # inside loop tester for bubble sort
	bne $t7, $a1, inside_loop
 
outside_test: # outside loop tester for bubble sort
	bne $t6, $v1, outside_loop	

main_test:

	ori $v0, $zero, 1
	syscall
	srl $s7, $v0, 21
	or $a0, $s7, $zero
	ori $v0, $zero, 2
	syscall
	
	# After that, the registers except s1 ~ s4 (which save the base address of array) and a0(which save the size of array)are free to use
case4:
	# input the idx of array
	ori $s6, $zero, 4
	bne $s7, $s6, case5
	
	ori $v0, $zero, 1
	syscall

	# move $a1, $v0 # idx of array(1 or 3)
	or $a1, $zero, $v0
	addi $t2, $zero, 3 # t2 save immediate 3 for comparing
	beq $a1, $t2, case4_idx3
	
case4_idx1:
	lw $t0, 0($s2) # first number (least number)

	add $t2, $zero, $zero # initialization t2 to 0
	addi $t2, $v1, -1
	sll $t2, $t2, 2 # offset
	add $t2, $t2, $s2 # find the place
	lw $t1, 0($t2) # last number (largest number)
	
	# lui $t8, 0xffff
	# ori $t8, $t8, 0xffff
	# xor $t0, $t0, $t8 #get negative first number
	# addi $t0, $t0, 1
	
	sub $t0, $t1, $t0 # t0 is the result
	ori $v0, $zero, 2 # display the answer
	# move $a0, $t0
	or $a0, $zero, $t0
	syscall 
	j case5
	
case4_idx3:
	lw $t0, 0($s4) # first number (least number)

	add $t2, $zero, $zero # initialization t2 to 0
	addi $t2, $v1, -1
	sll $t2, $t2, 2 # offset
	add $t2, $t2, $s2 # find the place
	lw $t1, 0($t4) # last number (largest number)

	# lui $t8, 0xffff
	# ori $t8, $t8, 0xffff
	# xor $t0, $t0, $t8 #get negative first number
	# addi $t0, $t0, 1

	sub $t0, $t1, $t0 # t0 is the result
	# li $v0, 1 # display the answer
	ori $v0, $zero, 2 # display the answer
	# move $a0, $t0
	or $a0, $zero, $t0
	syscall 


case5:
	ori $s6, $zero, 5
	bne $s7, $s6, case6
	
	ori $v0, $zero, 1
	syscall
	or $a0, $v0, $zero
	ori $v0, $zero, 2
	syscall

	# move $a1, $v0 # a1 save the idx of array
	or $a1, $zero, $a0
	ori $v0, $zero, 1
	syscall
	# move $a2, $v0 # a2 save the subscript of array
	or $a2, $zero, $v0
	addi $t2, $zero, 3 # t2 save immediate 3 for comparing
	beq $a1, $t2, case5_idx3
case5_idx1:
	sll $t0, $a2, 2 # find the place of required element
	add $t0, $t0, $s2
	
	lw $a0, 0($t0) # display it
	ori $v0, $zero, 2
	syscall
	j case6	
case5_idx3:
	sll $t0, $a2, 2 # find the place of required element
	add $t0, $t0, $s4
	
	lw $a0, 0($t0) # display it
	ori $v0, $zero, 2
	syscall

case6:
	ori $s6, $zero, 6
	bne $s7, $s6, case7

	ori $v0, $zero, 1
	syscall
	or $a0, $v0, $zero
	ori $v0, $zero, 2
	syscall

	# move $a1, $v0 # save the idx of array in $a1
	or $a1, $zero, $a0
	ori $v0, $zero, 1
	syscall
	or $a0, $v0, $zero
	ori $v0, $zero, 2
	syscall
	# move $a2, $v0 # save the subscript of array in $a2
	or $a2, $zero, $a0
	addi $t2, $zero, 2 # t2 save 2
	addi $t3, $zero, 3 # t3 save 3
	beq $a1, $t2, case6_idx2
	beq $a1, $t3, case6_idx3
	
	# After that, t2 and t3 are free to use
case6_idx1:
	sll $t0, $a2, 2
	add $t0, $t0, $s2
	lw $t4, 0($t0) # t4 save the target element
	
	# t2 save the signal bit and t3 save the exp bits
	slt $t2, $t4, $zero # if element is less than 0, then t2 is set to 1
	add $t3, $zero, $zero # initialize t3 to 0
	j test_shift_loop1
	
shift_loop1:
	addi $t3, $t3, 1 # exp += 1
	srl $t4, $t4, 1 # shift right 1 bit
	
test_shift_loop1:
	bne $t4, $zero, shift_loop1
	addi $t3, $t3, -1
	addi $t3, $t3, 127
	
	# display sign bit
	ori $v0, $zero, 2
	# move $a0, $t2
	or $a0, $zero, $t2
	syscall
	ori $v0, $zero, 4
	syscall
	syscall
	syscall

	# display exp bits
	ori $v0, $zero, 2
	# move $a0, $t3
	or $a0, $zero, $t3
	syscall
	j case7
	
case6_idx2:
	sll $t0, $a2, 2
	add $t0, $t0, $s3
	lw $t4, 0($t0) # t4 save the target element
	
	# t2 save the signal bit and t3 save the exp bits
	slt $t2, $t4, $zero # if element is less than 0, then t2 is set to 1
	beq $t2, $zero, positive
	sub $t4, $zero, $t4 # make t4 positive
positive:
	add $t3, $zero, $zero # initialize t3 to 0
	j test_shift_loop2
	
shift_loop2:
	addi $t3, $t3, 1 # exp += 1
	srl $t4, $t4, 1 # shift right 1 bit
	
test_shift_loop2:
	bne $t4, $zero, shift_loop2
	addi $t3, $t3, -1
	addi $t3, $t3, 127
	# display sign bit
	ori $v0, $zero, 2
	# move $a0, $t2
	or $a0, $zero, $t2
	syscall

	ori $v0, $zero, 4
	syscall
	syscall
	syscall
	# display exp bits
	ori $v0, $zero, 2
	# move $a0, $t3
	or $a0, $zero, $t3
	syscall
	
	j case7
case6_idx3:
	sll $t0, $a2, 2
	add $t0, $t0, $s4
	lw $t4, 0($t0) # t4 save the target element
	
	# t2 save the signal bit and t3 save the exp bits
	slt $t2, $t4, $zero # if element is less than 0, then t2 is set to 1
	beq $t2, $zero, positive2
	sub $t4, $zero, $t4 # make t4 positive
positive2:
	add $t3, $zero, $zero # initialize t3 to 0
	j test_shift_loop3
	
shift_loop3:
	addi $t3, $t3, 1 # exp += 1
	srl $t4, $t4, 1 # shift right 1 bit
	
test_shift_loop3:
	bne $t4, $zero, shift_loop3
	addi $t3, $t3, -1
	addi $t3, $t3, 127

	# display sign bit
	ori $v0, $zero, 2
	# move $a0, $t2
	or $a0, $zero, $t2
	syscall

	ori $v0, $zero, 4
	syscall
	syscall
	syscall

	# display exp bits
	ori $v0, $zero, 2
	# move $a0, $t3
	or $a0, $zero, $t3
	syscall


case7:
	ori $s6, $zero, 7
	bne $s7, $s6, exit

	ori $v0, $zero, 1
	syscall
	or $a0, $v0, $zero
	ori $v0, $zero, 2
	syscall

	# move $a2, $v0 # a2 save the subscript of array
	or $a2, $zero, $a0

	sll $t0, $a2, 2
	add $t1, $t0, $s1
	add $t0, $t0, $s3
	lw $a3, 0($t1) #the target element in dataset1
loop_case7:
	lw $t4, 0($t0) # t4 save the target element

case7_1:
	# move $a0, $t4
	andi $a0, $a3, 0x00ff
	ori $v0, $zero, 2
	syscall
	ori $v0, $zero, 4
	syscall
	syscall
	syscall
	syscall
	syscall


case7_2:
	# t2 save the signal bit and t3 save the exp bits
	slt $t2, $t4, $zero # if element is less than 0, then t2 is set to 1
	beq $t2, $zero, positive3
	sub $t4, $zero, $t4 # make t4 positive
positive3:
	add $t3, $zero, $zero # initialize t3 to 0
	j test_shift_loop
	
shift_loop:
	addi $t3, $t3, 1 # exp += 1
	srl $t4, $t4, 1 # shift right 1 bit
	
test_shift_loop:
	bne $t4, $zero, shift_loop
	addi $t3, $t3, -1
	addi $t3, $t3, 127

	sll $t2, $t2, 23
	or $t3, $t3, $t2

	# display exp&sign bits
	ori $v0, $zero, 2
	# move $a0, $t3
	or $a0, $zero, $t3
	syscall

	ori $v0, $zero, 4
	syscall
	syscall
	syscall
	syscall
	syscall
	j loop_case7

exit:
	j main_test
 
	
