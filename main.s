#actual start of the main program
	    .globl main
main:
	addu	$s7, $0, $ra	#save the return address in a global register
	    .data
	    .text


	    #Usual stuff at the end of the main
	addu	$ra, $0, $s7	#restore the return address
	jr	$ra		#return to the main program
	add	$0, $0, $0	#nop