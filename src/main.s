################################################################################
# Brainfuck Interpreter
#
# For debugging, use a hardcoded file path. Change to the location of a bf file.
# 
################################################################################
# actual start of the main program
.globl main

main:
	addu	$s7, $0, $ra	#save the return address in a global register

################################################################################
# Data
################################################################################
.data
request_file_text:  .asciiz "Enter a brainfuck file path: "
file_open_error_text:  .asciiz "ERROR: There was a problem opening the requested file"
file_read_error_text:  .asciiz "ERROR: There was a problem reading the requested file"

the_file:  .asciiz "/Users/mattbierner/Desktop/314-mips-brainfuck/src/hello.bf"


file:   .space 256 # Holds the file name
data:   .space 4096 # Holds the brainfuck data 
instr:  .space 4096 # Holds the program instructions 


# A jump table used to look up instruction functions
instr_table: 
.word bf_nop # (nul) 0
.word bf_nop # (soh) 1
.word bf_nop # (stx) 2
.word bf_nop # (etx) 3
.word bf_nop # (eot) 4
.word bf_nop # (enq) 5
.word bf_nop # (ack) 6
.word bf_nop # (bel) 7
.word bf_nop # (bs) 8
.word bf_nop # (ht) 9
.word bf_nop # (nl) 10
.word bf_nop # (vt) 11
.word bf_nop # (np) 12
.word bf_nop # (cr) 13
.word bf_nop # (so) 14
.word bf_nop # (si) 15
.word bf_nop # (dle) 16
.word bf_nop # (dc1) 17
.word bf_nop # (dc2) 18
.word bf_nop # (dc3) 19
.word bf_nop # (dc4) 20
.word bf_nop # (nak) 21
.word bf_nop # (syn) 22
.word bf_nop # (etb) 23
.word bf_nop # (can) 24
.word bf_nop # (em) 25
.word bf_nop # (sub) 26
.word bf_nop # (esc) 27
.word bf_nop # (fs) 28
.word bf_nop # (gs) 29
.word bf_nop # (rs) 30
.word bf_nop # (us) 31
.word bf_nop # (sp) 32
.word bf_nop # ! 33
.word bf_nop # " 34
.word bf_nop # # 35
.word bf_nop # $ 36
.word bf_nop # % 37
.word bf_nop # & 38
.word bf_nop # ' 39
.word bf_nop # ( 40
.word bf_nop # ) 41
.word bf_nop # * 42
.word bf_nop # + 43
.word get_in # , 44
.word bf_nop # - 45
.word print_out # . 46
.word bf_nop # / 47
.word bf_nop # 0 48
.word bf_nop # 1 49
.word bf_nop # 2 50
.word bf_nop # 3 51
.word bf_nop # 4 52
.word bf_nop # 5 53
.word bf_nop # 6 54
.word bf_nop # 7 55
.word bf_nop # 8 56
.word bf_nop # 9 57
.word bf_nop # : 58
.word bf_nop # ; 59
.word bf_nop # < 60
.word bf_nop # = 61
.word bf_nop # > 62
.word bf_nop # ? 63
.word bf_nop # @ 64
.word bf_nop # A 65
.word bf_nop # B 66
.word bf_nop # C 67
.word bf_nop # D 68
.word bf_nop # E 69
.word bf_nop # F 70
.word bf_nop # G 71
.word bf_nop # H 72
.word bf_nop # I 73
.word bf_nop # J 74
.word bf_nop # K 75
.word bf_nop # L 76
.word bf_nop # M 77
.word bf_nop # N 78
.word bf_nop # O 79
.word bf_nop # P 80
.word bf_nop # Q 81
.word bf_nop # R 82
.word bf_nop # S 83
.word bf_nop # T 84
.word bf_nop # U 85
.word bf_nop # V 86
.word bf_nop # W 87
.word bf_nop # X 88
.word bf_nop # Y 89
.word bf_nop # Z 90
.word bf_nop # [ 91
.word bf_nop # \ 92
.word bf_nop # ] 93
.word bf_nop # ^ 94
.word bf_nop # _ 95
.word bf_nop # ` 96
.word bf_nop # a 97
.word bf_nop # b 98
.word bf_nop # c 99
.word bf_nop # d 100
.word bf_nop # e 101
.word bf_nop # f 102
.word bf_nop # g 103
.word bf_nop # h 104
.word bf_nop # i 105
.word bf_nop # j 106
.word bf_nop # k 107
.word bf_nop # l 108
.word bf_nop # m 109
.word bf_nop # n 110
.word bf_nop # o 111
.word bf_nop # p 112
.word bf_nop # q 113
.word bf_nop # r 114
.word bf_nop # s 115
.word bf_nop # t 116
.word bf_nop # u 117
.word bf_nop # v 118
.word bf_nop # w 119
.word bf_nop # x 120
.word bf_nop # y 121
.word bf_nop # z 122
.word bf_nop # { 123
.word bf_nop # | 124
.word bf_nop # } 125
.word bf_nop # ~ 126
.word bf_nop # (del) 127


################################################################################
# Main Function
#
# =Steps=
# * Get a file name
# * Open the file
# * Read the file
# * Start execution
# * execute the program
#
# =Register use=
# s3 holds the end of the instr data
################################################################################
.text
# Get the input filename
    # print out text prompt
    la $a0, request_file_text 
    li $v0, 4
    syscall 
    # read file name from std in
    li $v0, 8
    la $a0, file
    li $a1, 256
    syscall
    
    
# Open file
    # Open the file, save file descriptor in $s0
    li $v0, 13
    la $a0, the_file # setup file path. 
    li $a1, 0 # open file for reading
    li $a2, 0 # no mode
    syscall 
    move $s0, $v0
    # Check for error opening file, error if $s0 < 0
    bgtz $s0, read_file
    # print error msg 
    la $a0, file_open_error_text 
    li $v0, 4
    syscall 
    j exit # and exit
    
# Read the file
read_file:
    li $v0, 14
    add $a0, $0, $s0 # setup file descriptor. 
    la $a1, instr # set output buffer
    li $a2, 4096 # set number of chars to read
    syscall
    # Check error
    blez $v0, read_error
    la $s1, instr
    move $s0, $v0 # save file length in s0
    add $s3, $s0, $s1 # save off end of file into s3
    j start_execution
read_error:
    # print error msg 
    la $a0, file_read_error_text 
    li $v0, 4
    syscall 
    j exit # and exit

# start the execution of the brainfuck program
start_execution:
    la $v0, instr
    la $v1, data
    
# main program run loop     
run_loop:
    # check for end of program
    slt $t0, $v0, $s3
    blez $t0, exit 
    #
    lb $t0, 0($v0)
    # Setup instruction arguments
    move $a0, $v0
    move $a1, $v1
    # Get the instruction function
    li $t1, 4
    mul $t2, $t0, $t1
    lw $t3, instr_table($t2)
    # execute the instruction
    la $ra, run_loop # return to run loop
    jr $t3  

exit:
    #Usual stuff at the end of the main
	addu	$ra, $0, $s7	#restore the return address
	jr	$ra		#return to the main program
	add	$0, $0, $0	#nop
    
    
    
    
################################################################################
# Brainfuck Instructions
################################################################################


# Function bf_nop
#
# nop instruction
#
# Used for every character besides the ones bf specifies
bf_nop:
    addiu $v0, $a0, 1 # increase instr pointer by one
    move $v1, $a1 # copy data pointer
    jr $ra

get_in:	
	li $v0, 12		
	syscall			#Character will be read into $v0
	sb $v0, 0($a1)	#Store $v0 into current data location
    addiu $v0, $a0, 1 # increase instr pointer by one
    move $v1, $a1 # copy data pointer
    jr $ra

print_out:
    addiu $t7, $a0, 1 # increase instr pointer by one
    move $v1, $a1 # copy data pointer

	li $v0, 11		
	lb $a0, 0($a1) 	#Load the byte to print
	syscall
	move $v0, $t7 	#Restore $v0
    move $v1, $a1 # copy data pointer
    jr $ra










