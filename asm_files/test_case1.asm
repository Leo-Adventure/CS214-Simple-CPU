.data 0x0000
# a 0
# b 4
# num 8
.text 0xf000
start:
	
	ori $v0, $zero, 1
	syscall
	andi $v0, $v0, 0xffff

	sw $v0, 0($zero)
	or $a0, $zero, $v0
	ori $v0, $zero, 2
	syscall
	
	ori $v0, $zero, 1
	syscall
	andi $v0, $v0, 0xffff

	sw $v0, 4($zero)
	or $a0, $zero, $v0
	ori $v0, $zero, 2
	syscall
	
	
	
mainloop:	
	ori $v0, $zero, 1
	syscall
	or $s3, $zero, $v0
	srl $s3,$s3,21 #get s3 (the test case)
	ori $v0, $zero, 2
	
test1:
	bne  $s3, $zero, test3
case1:
	lw $t0,0($zero)
	add $t1, $zero, $zero # t1 存储 cnt ,初始化为 0
	add $t2, $zero, $t0 #  t2 存储 bit_num
	ori $t3, $zero, 8  # t3 存储 nums 地址
	j CAL_TEST1 # jump to middle

CAL_LOOP1:
	sll $t5, $t1, 2 # t5 = cnt * 4
	add $t5, $t3, $t5 # t5 代表当前数组地址
	andi $t6, $t2, 1 # t6 存储余数
	srl $t2, $t2, 1
	sw $t6, 0($t5)	# 由于余数非0即1，直接把余数放入数组当中
	addi $t1, $t1, 1 # cnt++
	
CAL_TEST1:
       	
	bne $t2, $zero, CAL_LOOP1 # 假如 bit_num != 0 , $t4 = 1, 进入while循环
	
Judge:
	add $t8, $zero, $zero # i = 0， t8 代表 i
	add $v0, $zero, $zero # flag = false, k0 代表 flag
	j test
loop:
	sll $a1, $t8, 2 # t8 是 i
	add $a1, $a1, $t3 # 找到对应的地址
	lw $a2, 0($a1) # nums[i]
	sub $t9, $t1, $t8 # cnt - i
	addi $t9, $t9, -1 # cnt - i - 1
	sll $t9, $t9, 2
	add $t9, $t9, $t3
	lw $a3, 0($t9) # nums[cnt - i - 1]
	beq $a2, $a3, jump
	addi $v0, $zero, 1 # 只要有不相等的就设置 t9 = 1
jump:
	addi $t8, $t8, 1	
test:	
	bne $t8, $t1, loop
	beq $v0, $t1, print_not
	ori $v0, $zero, 2
	ori $a0, $zero, 1
	syscall
	# TODO: print_string(" is binary palindrome, ")
	j exit
print_not:
	ori $v0, $zero, 2
	ori $a0, $zero, 0
	syscall
	# TODO: print_string(" is NOT binary palindrome, ")
	
	
test3:# b10
	ori $a0,$zero,2
	bne $s3, $a0, test4
case3:
	lw $t0,0($zero)
	lw $t1,4($zero)
	and $t2, $t0, $t1
	or $a0, $zero,$t2
	syscall

test4:
	ori $a0,$zero,3
	bne $s3, $a0, test5
case4:
	lw $t0,0($zero)
	lw $t1,4($zero)
	or $t2, $t0, $t1
	or $a0, $zero,$t2
	syscall

test5:
	ori $a0,$zero,4
	bne $s3, $a0, test6
case5:
	lw $t0,0($zero)
	lw $t1,4($zero)
	xor $t2, $t0, $t1
	or $a0, $zero,$t2
	syscall

test6:
	ori $a0,$zero,5
	bne $s3, $a0, test7
case6:
	lw $t0,0($zero)
	lw $t1,4($zero)
	sllv $t2, $t0, $t1
	or $a0, $zero,$t2
	syscall

test7:
	ori $a0,$zero,6
	bne $s3, $a0, test8
case7:
	lw $t0,0($zero)
	lw $t1,4($zero)
	srlv $t2, $t0, $t1
	or $a0, $zero,$t2
	syscall

test8:
	ori $a0,$zero,7
	bne $s3, $a0, exit
case8:
	lw $t0,0($zero)
	lw $t1,4($zero)
	srav $t2, $t0, $t1
	or $a0, $zero,$t2
	syscall


exit:
	j mainloop

	
	
