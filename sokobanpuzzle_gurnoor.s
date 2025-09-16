.data
.align 2
gridsize:   .byte 8,8 
# TO PLAY THE GAME OPEN THIS FILE IN https://cpulator.01xz.net/?sys=rv32-spim
# My enhancements are the replay mode and the multiplayer mode
# I implemented them by storing information on the stack and then later iterating through it
# Please turn off the following settings in cpulator
# Function clobbered ra or sp AND Function clobbered callee-saved register
.align 2
newline:    .byte 10
.align 2
character:  .byte 0,0
.align 2
box:        .byte 0,0
.align 2
target:     .byte 0,0
.align 2
ocharacter:  .byte 0,0
.align 2
obox:        .byte 0,0
.align 2
otarget:     .byte 0,0
.align 2
player_count: .word 0
.align 2
curr_player:.word 0
.align 2
curr_player_pointer: .space 4
.align 2
input_char: .space 1
.align 2
replay_pointer: .word 0
.align 2
end_pointer: .word 0
.align 2
total_moves: .word 0
player_count_prompt: .asciz "Welcome to Sokoban! How many players are playing?"
game_instruction: .asciz "Use the  w  a  s  d   keys to move around and  r  to restart"
wrong_input: .asciz "Incorrect input, please only use 	w a s d  as inputs"
whos_playing: .asciz "Current player playing is player "
player_tag: .asciz "Player "
congrats: .asciz "You have beaten the game :)"
finished: .asciz "Moves taken to win: "
# for me the ascii stuff isnt working so imma just do immidiate values of the ascii

.text
.global _start

_start:
	# im gonna do rand of each and every time it equals smth previous im gonna reset
	#IMPORTANT: I should prolly acess the 8 from memory of the gridsize
	li sp, 0x7ffffff0
	j next
create_map:
	la a0, gridsize
	lb s0, 0(a0)
	lb s1, 1(a0)
	
genrate_player:
	mv a0, s0
	mv s9, ra
	jal notrand
	mv t0, a0
	la t6, character
	sb t0, 0(t6) # store character row
	mv a0, s1
	jal notrand
	mv t1, a0
	sb t1, 1(t6) # store character col

generate_box:
	#t2 is row of box, t3 is col of box
	mv a0, s0
	jal notrand
	mv t2, a0
	mv a0, s1
	jal notrand
	mv t3, a0
	beq t2, x0, top
top_label:
	addi t6, s0, -1
	beq t2, t6, bottom
bottom_label:
	#check if equal to player location
	la t6, character
	lb t0, 0(t6)
	lb t1, 1(t6)
	bne t2, t0, save_box
	bne t3, t1, save_box
	j generate_box
	
top:
	beq t3, x0, generate_box
	addi t6, s1, -1
	beq t3, t6, generate_box
	j top_label

bottom:
	beq t3, x0, generate_box
	addi t6, s1, -1
	beq t3, t6, generate_box
	j bottom_label

save_box:
	la t6, box
	sb t2, 0(t6)
	sb t3, 1(t6)

generate_target:
	mv a0, s0
	jal notrand
	mv t4, a0
	mv a0, s1
	jal notrand
	mv t5, a0
	# need to make sure if box spawns on edge, target is on the same edge
	# I STILL NEED TO DO THIS
	la t6, box
	lb t2, 0(t6)
	lb t3, 1(t6)
	#if not on edge
	addi s11, s0, -1 # setting edges of boxes
	addi s10, s1, -1
	
	
	beq t2, x0, worry_top
box_is_top_return:
	beq t2, s11, worry_bottom
box_is_bottom_return:
	beq t3, x0, worry_left
box_is_left_return:
	beq t3, s10, worry_right
box_is_right_return:
	j dont_worry_edge
	
worry_top:
	mv t4, x0
	j box_is_top_return
worry_bottom:
	mv t4, s11
	j box_is_bottom_return
worry_left:
	mv t5, x0
	j box_is_left_return
worry_right:
	mv t5, s10
	j box_is_right_return
	
dont_worry_edge:
	#check for character
	la t6, character
	lb t0, 0(t6)
	lb t1, 1(t6)
	bne t4, t0, extra_check
	bne t5, t1, extra_check
	j generate_target

extra_check:
	#check for box
	la t6, box
	lb t2, 0(t6)
	lb t3, 1(t6)
	bne t4, t2, save_target
	bne t5, t3, save_target
	j generate_target

save_target:
	la t6, target
	sb t4, 0(t6)
	sb t5, 1(t6)
	j print_gameboards
	
	
print_gameboard: #the call to print gameboard
	mv s9, ra
print_gameboards:
	la a0, gridsize
	lb s0, 0(a0)
	lb s1, 1(a0)
	li s11, 0
print_wall_loopa: # the upper wall of #
	li a0, 35
	li a7, 11
	ecall
	addi s11, s11, 1
	blt s11, s1, print_wall_loopa
	ecall
	ecall
	la a0, newline
	lb a0, 0(a0)
	ecall

	# player = p	target = t	box = b 	empty space = + 	wall = #
	# for loop for upper wall
	# then i do a for loop where i print every peice while checking of the current row/col is p/t/b
	# the another for loop for lower wall

    	# s0 = number of rows
	# s1 = number of columns
	    
	li t2, 0              # Row counter
print_row_loop: 
	# we go here to set the column counter back to 0 after reaching new row
	li t3, 0              # Column counter
	li a7, 11
	li a0, 35
	ecall
    
print_column_loop:
	# Determine what symbol to print
	li a0, 43
	la t6, character
	lb t4, 0(t6)
	lb t5, 1(t6)
	la t6, box
	lb s2, 0(t6)
	lb s3, 1(t6)
	la t6, target
	lb s4, 0(t6)
	lb s5, 1(t6)
	beq t2, t4, is_player_col # we see if it is a player before if we see if it is target so we good
player_col_label:
	beq t2, s4, is_target_col
target_col_label:
	beq t2, s2, is_box_col
box_col_label:
	j continue_print
    
is_player_col:
	beq t3, t5, is_player
	j player_col_label

is_player:
	li a0, 80
	j continue_print

is_target_col:
	beq t3, s5, is_target
	j target_col_label

is_target:
	li a0, 84
	j continue_print

is_box_col:
	beq t3, s3, is_box
	j box_col_label

is_box:
	li a0, 66
	j continue_print


continue_print:
	# Print the character
	li a7, 11              # syscall for printing string
	ecall

	# Move to the next column
	addi t3, t3, 1
	blt t3, s1, print_column_loop

	# print wall
	li a7, 11
	li a0, 35
	ecall

	# Print a newline after each row
	la a0, newline
	lb a0, 0(a0)
	li a7, 11
	ecall
    
	# Move to the next row
	addi t2, t2, 1
	blt t2, s0, print_row_loop


	li s11, 0
print_wall_loopb: # print bottom floor #
	li a0, 35
	li a7, 11
	ecall
	addi s11, s11, 1
	blt s11, s1, print_wall_loopb
	ecall
	ecall
	la a0, newline
	lb a0, 0(a0)
	ecall
	mv ra, s9
	jr ra
#game starts here
next:#-----------------------------------------------------------------------------------
	li a7, 4
	la a0, player_count_prompt #ask the player for player count
	ecall
	li a7, 5 #read the player count
	ecall #player_count is in a0
	la t1, player_count
	sw a0, 0(t1)
	jal create_map #print game map
	#here im saving all the original locations so i can reset the values for new players
	la s1, character
	lb t2, 0(s1)
	lb t3, 1(s1)
	la s1, ocharacter
	sb t2, 0(s1)
	sb t3, 1(s1)
	la s1, target
	lb t2, 0(s1)
	lb t3, 1(s1)
	la s1, otarget
	sb t2, 0(s1)
	sb t3, 1(s1)
	la s1, box
	lb t2, 0(s1)
	lb t3, 1(s1)
	la s1, obox
	sb t2, 0(s1)
	sb t3, 1(s1)
	
	
	#SAVE THE STACK POINTER ORIGIN HERE---------------------------------------------
	la t5, replay_pointer
	sw sp, 0(t5)
	#we will start from this location for leaderboard and replay
	#replay_pointer
	
	
cycle_players: #GO HERE WHEN NEXT PLAYER
	la t1, curr_player 
	lw t2, 0(t1) #load current player
	addi t2, t2, 1 #add 1 to current player
	sw t2, 0(t1)
	la t3, player_count 
	lw t4, 0(t3) #load total number of players
	
	# 1 byte telling us theres a new player (1)--------------------------------------------
	addi sp, sp, -4
	li t5, 1
	sb t5, 0(sp)
	
	# add a random byte thats 1 byte to the stack here
	# WE ALSO NEED TO SAVE THIS INTO MEMORY {curr_player}
	la t5, curr_player_pointer
	sb sp, 0(t5)
	#also if we RESTART we set the stack pointer to curr_player
	
	bge t4, t2, play_games # check if current player is >= total number of players
	j show_leaderboard # game is over show the leaderboard
	#while #ofplayersplayed is <= total_players; play on 
play_games:
	li a7, 4
	la a0, whos_playing
	ecall
	li a7, 1
	mv a0, t2
	ecall
	li a7, 11
	la a0, newline
	lb a0, 0(a0)
	ecall
play_game: #GO HERE FOR NEXT MOVE
	#read inputs making sure its only a single key
	jal print_gameboard #print the game
	li a7, 4
	la a0, game_instruction #tell player about intructions
	ecall
	li a7, 11
	la a0, newline
	lb a0, 0(a0)
	ecall
	li t0, '\n'
	la a0, input_char
	la a1, 3
	li a7, 8 #read string
	ecall
	la t1, input_char
	lb t2, 0(t1)
	lb t3, 1(t1)
	
	#ADD THE MOVE (t2) TO THE STACK HERE-----------------------------------------------
	addi sp, sp, -4
	sb t2, 0(sp)
	
	bne t3, t0, incorrect_input
	
#   correct_input
	la t1, gridsize
	lb s0, 0(t1)
	lb s1, 1(t1)
	
	la t1, character
	lb s2, 0(t1)
	lb s3, 1(t1)

	la t1, target
	lb s4, 0(t1)
	lb s5, 1(t1)

	la t1, box
	lb s6, 0(t1)
	lb s7, 1(t1)

	li t0, 114
	beq t0, t2, restart
	li t0, 119
	beq t0, t2, up_move
	li t0, 97
	beq t0, t2, left_move
	li t0, 115
	beq t0, t2, down_move
	li t0, 100
	beq t0, t2, right_move

	#imgonna have a correct_input section where i add move count and add move to memory
up_move:
	li t1, 0
	beq s2, t1, incorrect_input #does it hit the top wall
	addi t2, s2, -1 #s2 is now where it is moving
	# if we push a box into a corner we cant move one up
	bne t2, s6, up_no_box #no box in the same row
	bne s3, s7, up_no_box #no box in the same col
	beq s6, t1, incorrect_input #same row but box is top row
	la t4, box
	addi s6, s6, -1
	sb s6, 0(t4) #update new box location	
up_no_box:
	la t4, character
	sb t2, 0(t4) #store new character location
	j correct_input

down_move:
	addi t1, s0, -1
	beq s2, t1, incorrect_input #does it hit the bottom wall
	addi t2, s2, 1 #s2 is now where it is moving
	# if we push a box into a corner we cant move one up
	bne t2, s6, down_no_box #no box in the same row
	bne s3, s7, down_no_box #no box in the same col
	beq s6, t1, incorrect_input #same col but box is bottom row
	la t4, box
	addi s6, s6, 1
	sb s6, 0(t4)	
down_no_box:
	la t4, character
	sb t2, 0(t4)
	j correct_input

left_move:
	li t1, 0
	beq s3, t1, incorrect_input #does it hit the left wall
	addi t2, s3, -1 #s3 is now where it is moving
	# if we push a box into a corner we cant move one up
	bne t2, s7, left_no_box #no box in the same col
	bne s2, s6, left_no_box #no box in the same row
	beq s7, t1, incorrect_input #same row but box is left col
	la t4, box
	addi s7, s7, -1
	sb s7, 1(t4) #update new box location	
left_no_box:
	la t4, character
	sb t2, 1(t4) #store new character location
	j correct_input

right_move:
	addi t1, s0, -1
	beq s3, t1, incorrect_input #does it hit the right wall
	addi t2, s3, 1 #s3 is now where it is moving
	# if we push a box into a corner we cant move one up
	bne t2, s7, right_no_box #no box in the same col
	bne s2, s6, right_no_box #no box in the same row
	beq s7, t1, incorrect_input #same row but box is left col

	la t4, box
	addi s7, s7, 1
	sb s7, 1(t4) #update new box location	
right_no_box:
	la t4, character
	sb t2, 1(t4) #store new character location
	j correct_input

correct_input:
# add move count by 1 !!! i dont have this anymore im counting moves from the replay
# check if game over (if it is then do a next player by going to cycle_players)
	la t1, target
	lb s4, 0(t1)
	lb s5, 1(t1)

	la t1, box
	lb s6, 0(t1)
	lb s7, 1(t1)
	beq s4, s6, win_check
	j play_game
win_check:
	bne s5, s7, play_game
	#loading original game board
	la s1, ocharacter
	lb t2, 0(s1)
	lb t3, 1(s1)
	la s1, character
	sb t2, 0(s1)
	sb t3, 1(s1)
	la s1, otarget
	lb t2, 0(s1)
	lb t3, 1(s1)
	la s1, target
	sb t2, 0(s1)
	sb t3, 1(s1)
	la s1, obox
	lb t2, 0(s1)
	lb t3, 1(s1)
	la s1, box
	sb t2, 0(s1)
	sb t3, 1(s1)
	la a0, congrats #congradulations message on winning the game
	li a7, 4 
	ecall
	li a7, 11
	la a0, newline
	lb a0, 0(a0)
	ecall #newline	
# reset board to original
	j cycle_players

incorrect_input:
#dont increase move count
	la a0, wrong_input
	li a7, 4
	ecall
	li a7, 11
	la a0, newline
	lb a0, 0(a0)
	ecall
	j play_game
#ask for another move

restart:
#MOVE THE STACKPOINTER BACK TO curr_player------------------------------------------
	la t5, curr_player_pointer
	lw t5, 0(t5)
	mv sp, t5
	la s1, ocharacter #im setting the values for original gameboard so we can create it again
	lb t2, 0(s1)
	lb t3, 1(s1)
	la s1, character
	sb t2, 0(s1)
	sb t3, 1(s1)
	la s1, otarget
	lb t2, 0(s1)
	lb t3, 1(s1)
	la s1, target
	sb t2, 0(s1)
	sb t3, 1(s1)
	la s1, obox
	lb t2, 0(s1)
	lb t3, 1(s1)
	la s1, box
	sb t2, 0(s1)
	sb t3, 1(s1)
# reset board to original
# do not reset the total moves
	j play_game
	

la t0, end_pointer#----------------------------------------------
sw sp, 0(t0) #this points to the end of the stack

#this will print the players name, then it will have all their moves one by one
#then followed by their move total which will reset apon a reset
show_leaderboard:#this will show the players 
	li t6, 0
	la t5, player_count 
	lw t5, 0(t5) #total number of players
	li s7, 0 #current player
	la t0, replay_pointer #address to the pointer to the first
	lw t0, 0(t0) #pointer to the first
	mv sp, t0
show_moves:
	li t0, 1
	lw t2, 0(sp) #word at sp
	beq t2, t1, new_player #if its a new player indicator
	li a7, 4
	mv a0, t2
	ecall #print move
	addi s6, s6, 1 #add move count by 1
	addi sp, sp, -4 #move sp
	li a7, 11
	la a0, newline
	lb a0, 0(a0)
	ecall #newline
	la t5, end_pointer
	lw t5, 0(t5)
	beq sp, t5, exit # if at end then exit
	j show_moves
new_player:#we initialize the stack with the number 1 so we go here first
	li a7, 4
	la a0, player_tag
	ecall 
	addi s7, s7, 1 #increase player count by 1
	la a0, finished #print a messgae to show total moves taken to win
	li a7, 4
	ecall
	li a7, 1
	mv a0, s6 #print the total number of moves
	ecall
	li s6, 0 # reset the player moves for the next person
	li a7, 11
	la a0, newline
	lb a0, 0(a0)
	ecall #newline
	li a7, 1
	mv a0, s7
	ecall#print player
	li a7, 11
	la a0, newline
	lb a0, 0(a0)
	ecall #newline
	addi sp, sp, -4 #move sp
	la t5, end_pointer
	lw t5, 0(t5)
	beq sp, t5, exit # if at end then exit
	j show_moves
	
exit:
    li a7, 10
    ecall
    
    
# --- HELPER FUNCTIONS ---
# Feel free to use, modify, or add to them however you see fit.
     
# Arguments: an integer MAX in a0
# Return: A number from 0 (inclusive) to MAX (exclusive)
notrand:
	# result stored in a0
    mv t0, a0
    li a7, 30
    ecall             # time syscall (returns milliseconds)
    remu a0, a0, t0   # modulus on bottom bits 
    li a7, 32
    ecall             # sleeping to try to generate a different number
    jr ra
