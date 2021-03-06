.section .text
.globl drawbox



// subroutine for drawing a pixel
// r0 = frame buffer pointer
// r1 = x coord
// r2 = y coord
// r3 = colour code in hex
// r4 = counter
.global drawPixel
drawPixel:
	push	{r4}
	add 	r4, r1, r2, lsl #10	// calculate the pixel offset
	lsl 	r4, #1 			// shift offset by 1 (multiply by 2)
	strh 	r3, [r0, r4]		// store results into r3
	pop 	{r4}
	bx	lr
// this subroutine is to draw a line along x axis
// r5 total pixels x (width)
// r6 total pixels y (length)
// r7 total number of pixels drawn for drawLine routine
// r8 counter for total y pixels
.global drawHoLine
drawHoLine:
	push 	{lr}
lineHoTop:			// drawing horizontal line loop
	cmp 	r7, r5		// compare number of pixels drawn for drawline routine
	bge 	doneHoLine	// branch to done drawing the horizontal line
	bl	drawPixel	// branch to drawpixel subroutine
	add 	r7, #1		// add 1 to number of pixels drawn 
	add 	r1, #1		// add 1 to x coord
	b 	lineHoTop	// branch to the horizontal line routine
doneHoLine:
	pop 	{lr}
	bx	lr

.global drawVeLine
drawVeLine:
	push 	{lr}	
lineVeTop:			// draw vertical line loop
	cmp 	r8, r6		// compare number of pixels drawn to number of pixels wanted
	bge 	doneVeLine	// branch out of loop when equal or greater to the amount
	bl	drawPixel	// branch drawpixel 
	add 	r8, #1		// add 1 to number of pixels drawn for y
	add 	r2, #1		// add 1 to y coord 
	b 	lineVeTop	// branch back to the top of loop
doneVeLine:
	pop 	{lr}
	bx	lr

// this subroutine is to draw lines down y axis and to fill in a square
.global drawObject
drawObject:	
	push 	{lr}
	mov 	r9, r1		// move x coord into r9
objectTop:
	cmp 	r8, r6		// compare number of pixels drawn on y coord to total amount wanted
	bge 	doneObject	// finish when equal
	bl 	drawHoLine	// branch to drawing a horizontal line to fill in the square
	mov 	r7, #0		// move 0 into r7
	mov 	r1, r9		// move x coordinate into r1
	add 	r2, #1		// add 1 to y coord
	add	r8, #1		// add 1 to number of y pixels drawn
	b 	objectTop	// branch back to top of loop
doneObject:			// finished drawing object
	pop 	{lr}
	bx	lr
.global drawBorder
drawBorder:			// draws an outline around the entire playing area
	push 	{lr}
	mov 	r1, #0		// move 0 into x coord
	mov 	r2, #0		// move 0 into y coord
	ldr 	r3, =0xFF33FF	// load a colour (blue) into r3
	mov 	r5, #1000	// move 1000 into r5
	add 	r5, #24		// add 24 to 1000 to make the complete x coordinate border
	mov 	r6, #700	// move 700 into r6
	add 	r6, #67		// add 67 into r6 to complete the y coordinate border
	mov 	r7, #0		// move 0 into x pixel counter
	mov 	r8, #0		// move 0 into y pixel counter
	bl 	drawHoLine	// draw horizontal line
	mov 	r1, #0		// move  0 into x coord
	mov 	r7, #0		// move 0 into x pixel counter
	bl 	drawVeLine	// draw vertical line down
	mov 	r8, #0		// move 0 into y pixel counter
	bl 	drawHoLine	// draw horizontal line
	mov 	r1, #1000	// move 1000 into x coord
	add 	r1, #23		// finish moving 1023 into x coord
	mov 	r2, #0		// mov 0 into y coord
	bl 	drawVeLine	// draw vertical line
	mov	r1, #0		// move 0 into x coord
	mov	r2, #700	// move 700 into y coord
	add	r2, #25		// finish moving 725 into y coord
	mov	r7, #0		// move x counter to 0
	bl	drawHoLine	// draw horizontal line
	pop	{lr}

	bx 	lr





.global DrawChar
DrawChar:
	push	{r1, r4, r7, r8, lr}

	chAdr	.req	r4
	px		.req	r9
	py		.req	r6
	row		.req	r7
	mask	.req	r8

	ldr		chAdr,	=font		//  load the address of the font map
	add		chAdr,	r3, lsl #4		//  char address = font base + (char * 16)
	add		r5, #10

charLoop$:
	mov 	px, r5			//  init the X coordinate

	mov		mask,	#0x01		//  set the bitmask to 1 in the LSB
	
	ldrb	row,	[chAdr], #1	//  load the row byte, post increment chAdr

rowLoop$:
	tst		row,	mask		//  test row byte against the bitmask
	beq		noPixel$

	mov		r1,		px
	mov		r2,		py
	mov		r3,		#0xF800		//  red
	bl		drawPixel			//  draw red pixel at (px, py)

noPixel$:
	add		px,		#1			//  increment x coordinate by 1
	lsl		mask,	#1			//  shift bitmask left by 1

	tst		mask,	#0x100		//  test if the bitmask has shifted 8 times (test 9th bit)
	beq		rowLoop$

	add		py,		#1			//  increment y coordinate by 1

	tst		chAdr,	#0xF
	bne		charLoop$			//  loop back to charLoop$, unless address evenly divisibly by 16 (ie: at the next char)
	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask
	
	pop		{r1, r4, r7, r8, pc}




.global namesAndTitle
namesAndTitle:			// method to print out the names of creators and title of game
	push	{lr}
	mov 	r1, #700
	add 	r1, #40
	mov	r10, #0
	mov 	r5, #5
	mov 	r10, #0 	// Counter
draw:	
	ldr 	r8, =text	// load the text to write into r8
	ldrb	r3, [r8, r10]	// load one of the characters into r3
	add 	r10, #1		// add 1 to offset of characters
	mov 	r6, r1		// move character to draw into r6
	bl 	DrawChar	// draws the character
	cmp 	r10, #94	// compare offset of characters to spaces need to write
	bne	draw		// when not equal keep drawing characters
	pop	{lr}
	bx	lr

.global printLose
printLose:			// print the lose message
	push	{lr}
	mov 	r10, #0 	// Counter
drawL:	
	ldr 	r8, =loseMSG	// load what we want to write into r8
	ldrb	r3, [r8, r10]	// load offset of the text to print into r3 
	add 	r10, #1		// add 1 to the offset
	mov 	r6, r1		// move character to draw into r6
	bl 	DrawChar	// draw the character
	cmp 	r10, #6		// compare offset to number of characters need to be drawn
	bne	drawL		// when offset not equal to characters to draw branch back to top
	pop	{lr}
	bx	lr
	
.global printWin
printWin:			// print win message
	push	{lr}
	mov 	r10, #0 	// Counter
drawW:	
	ldr 	r8, =winMSG	// load win text into r8
	ldrb	r3, [r8, r10]	// load offset of the text to print into r3
	add 	r10, #1		// add one to offset of text
	mov 	r6, r1		// move character to draw into r6
	bl 	DrawChar	// draw character
	cmp 	r10, #7		// compare offset to total characters to draw
	bne	drawW		// when not equal branch to top of loop
	pop	{lr}
	bx	lr
	
.global drawResume
drawResume:			// draw resume text in pause menu
	push	{r7, lr}
	mov 	r10, #0 	// Counter
drawR:	
	ldr 	r8, =resume	// load resume message
	ldrb	r3, [r8, r10]	// load message offset
	add 	r10, #1		// add 1 to the offset
	mov 	r6, r1		// move letter to draw into r6
	bl 	DrawChar	// draw the character
	cmp 	r10, #6		// compare offset to number of characters drawn
	bne	drawR		// when not equal branch to top of draw loop
	pop	{r7, lr}
	bx	lr
	
.global drawRestart
drawRestart:			// draw restart message in pause menu
	push	{r7, lr}
	mov 	r10, #0 	// Counter
drawRe:	
	ldr 	r8, =restart	// load text to write
	ldrb	r3, [r8, r10]	// load offset
	add 	r10, #1		// add 1 to the offset
	mov 	r6, r1		// move character to draw into r6
	bl 	DrawChar	// draw charactger
	cmp 	r10, #7		// compare offset to total characters to draw
	bne	drawRe		// branch to top when not equal
	pop	{r7, lr}
	bx	lr
	
.global drawQuit	
drawQuit:			// draw quit message in pause screen
	push	{r7, lr}
	mov 	r10, #0 	// Counter
drawQ:	
	ldr 	r8, =quit	// load message to write
	ldrb	r3, [r8, r10]	// load offset
	add 	r10, #1		// add 1 to offset
	mov 	r6, r1		// mov character to draw into r6
	bl 	DrawChar	// draw character
	cmp 	r10, #4		// compare offset to total characters drawn
	bne	drawQ		// branch to top when not equal
	pop	{r7, lr}
	bx	lr
	
.global drawMessageBox
drawMessageBox:			// draw the pause menu box
	push 	{r7, lr}	
	mov 	r1, #400	// x coord to 400
	mov 	r2, #300	// y coord to 300
	ldr 	r3, =0x000F00	// load a colour into r3
	mov 	r5, #300	// move 300 into x count
	add 	r5, #-20	// move 280 into x count
	mov 	r6, #160	// move 160 into y count
	mov 	r7, #0		// x pixel counter 
	mov 	r8, #0		// y pixel counter
	bl 	drawObject	// draw the message box border
	mov 	r1, #400	// x coord to 400
	mov 	r2, #300	// y coord to 300
	mov 	r5, #300	// x counter 300
	add 	r5, #-20	// x counter finally put to 280
	mov 	r6, #160	// y counter to 160
	add 	r1, #5		// add 5 to x counter
	add 	r2, #5		// add 5 to y counter
	ldr 	r3, =0x00000C	// put colour into r3
	add 	r5, #-10	// subtract x counter by 10
	add 	r6, #-10	// subtract y counter by 10
	mov 	r7, #0		// move 0 into total x pixels drawn
	mov 	r8, #0		// move 0 into total y pixels drawn
	bl 	drawObject	// draw the message box
	pop 	{r7, lr}
	bx 	lr

.global clsmsgbx
clsmsgbx:			// clears the message box
	push 	{r1-r10, lr}
	mov 	r1, #400	// x coord
	mov 	r2, #300	// y coord
	ldr 	r3, =0x000000	// black colour to clear the screen
	mov 	r5, #300	// total amount of x pixels
	add 	r5, #-20	// complete the total amount of x pixels to draw
	mov 	r6, #160	// amount of y pixels to draw
	mov 	r7, #0		// x pixel counter
	mov 	r8, #0		// y pixel counter
	bl 	drawObject	// clear the box (draw the box black)
	mov 	r1, #400	// x coord
	mov 	r2, #300	// y coord
	mov 	r5, #300	// total amount of x pixels to draw
	add 	r5, #-20	// total amount of x pixels to draw
	mov 	r6, #160	// total amount of y pixels
	add 	r1, #5		// add 5 to x coord
	add 	r2, #5		// add 5 to y coord
	ldr 	r3, =0x000000	// colour it black
	add 	r5, #-10	// subtract 10 from x counter
	add 	r6, #-10	// subtract 10 from y counter
	mov 	r7, #0		// x pixel counter
	mov 	r8, #0		// y pixel counter
	bl 	drawObject	// clear the box (draw the box black)
	pop 	{r1-r10, lr}
	bx 	lr
	
	
.global drawArrow
drawArrow:			// draw arrow as selector
	push 	{r7, lr}
	mov 	r10, #0 	// Counter
drawA:	
	ldr 	r8, =arrow	// load text (the arrow)  into r8
	ldrb	r3, [r8, r10]	// text offset
	add 	r10, #1		// add one to offset
	mov 	r6, r1		// character to draw
	bl 	DrawChar	// draw the character
	cmp 	r10, #2		// compare offset to number of characters to draw
	bne	drawA		// when not equal branch to loop top
	pop	{r7, lr}
	bx	lr
	
	
.global drawscore
drawscore:			// draw the score and its update
	push 	{r7, lr}
	mov 	r1, #700		
	add 	r1, #40
	mov 	r5, #900
	add 	r5, #55	
	ldr 	r10, =Player	// load address of score (player heatlh)
	ldr 	r7, [r10, #32]	// load score into r7
	mov 	r8, #0		// move 0 into the counter
	b 	test1		// branch to test1
draws:				// draw 100 digit score
	sub 	r7, #100	// subtract 100 from score 
	add 	r8, #1		// add 1 to the counter
test1:
	cmp 	r7, #100	// compare score to 100
	bge 	draws		// if its greater or equal go to draws
	add 	r3, r8, #48	// add 48 to the counter to write correct ascii value digit
	mov 	r6, r1		// put character to write into r6
	bl 	DrawChar	// draw character
	mov 	r8, #0		// move 0 into counter
	b 	test2		// branch to test2
drawss:				// draw 10 digit score
	sub 	r7, #10		// sub 10 from score
	add 	r8, #1		// add 1 to counter
test2:
	cmp 	r7, #10		// compare score to 10
	bge 	drawss		// when greater then or equal branch to drawss
	add 	r3, r8, #48	// add 48 to r8 to print right number of digit
	mov 	r6, r1		// move character to draw into r6
	bl 	DrawChar	// draw character
	add 	r3, r7, #48	// add 48 to r8 to draw the right digit
	mov 	r6, r1		// move character to draw into r6
	bl 	DrawChar	// draw character
	pop	{r7, lr}
	bx	lr	
	
	
.global	clearscore
clearscore:			// clear the score 
	push 	{lr}
	mov 	r1, #900	// x coord
	add	r1, #50		// x coord
	mov	r2, #700	// y coord
	add	r2, #35		// y coord
	ldr	r3, =0x000000	// colour score black
	mov 	r5, #50		// move x pixels to draw to 50
	mov 	r6, #30		// move y pixels to draw to 30
	mov 	r7, #0		// x pixels counter
	mov 	r8, #0		// y pixels counter
	bl	drawObject	// branch to draw object
	pop	{lr}
	bx	lr
	

.section .data
.align 4
font:		.incbin	"font.bin"
text:		.asciz "By: Lukas Van Dyke, Sumeet Patel, Jeremy Lau      Name: Barriers Are USELESS            Score:"
loseMSG:	.asciz "DEFEAT"
winMSG:	.asciz "VICTORY"
resume: .asciz "Resume"
restart: .asciz "Restart"
quit: .asciz "Quit"
arrow: .asciz "->"
