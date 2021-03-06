
.global BarrierCollision 
BarrierCollision:
	push	{r6-r10, lr}
	mov	r10, r1			// Save address of wall struct for future use
	ldr	r6, [r10]			// r1 should have address of wall, get x value
	add	r6, #-1			// Subtract 1 from x for true x
	cmp	r4, r6			// Compare hit location to x location
	blo	miss				// Hit location < x(initial) so branch to miss
	ldr	r7, [r10, #8]		// Load width into r6
	add	r6, r7			// Add width to x value
	cmp	r4, r6			// Compare hit location to end of wall
	bhi	miss				// Hit location > x(final) so branch to miss
	ldr 	r6, [r10, #4]		// Load y value into r5
	cmp	r5, r6			// Compare hit location to y(initial)
	blo	miss				// Hit location < y(initial) so branch to miss
	ldr	r7, [r10, #12]		// Load height of wall
	add	r6, r7			// Add y location and height to calculate bottom of wall
	cmp	r5, r6			// Compare hit location to y(final)
	bhi	miss				// Hit location > y(final) so branch to miss
	mov	r2, #0			// Place 0 into r3 so that barrier can be cleared
	bl	drawBarrier		// Clear barrier
	mov	r1, r10			// Recover address of wall struct
	ldr	r6, [r10, #16]		// Load barrier hp
	add	r6, #-1			// Decrement barrier hp
	cmp	r6, #0			// See if barrier is dead
	beq	remove			// Remove barrier from game
	str	r6, [r10, #16]		// Store barrier hp
	ldr 	r7, [r10, #8]		// Load barrier width
	lsr	r7, #1			// Half barrier width
	str	r7, [r10, #8]		// Store barrier width
	ldr	r6, [r10]			// Load barrier x(initial)
	lsr 	r7, #1			// Quarter of initial barrier width
	add	r6, r7			// Push the barrier to the right by a quarter of its original width
	str	r6, [r10]			// Store x
	mov	r2, #1			// Place 1 into r3 so that barrier can be drawn
	bl	drawBarrier		// Draw a new barrier half the size of the old one
	mov	r1, #1			// Move 1 to r1 to return a hit, since all miss conditions failed
	pop	{r6-r10, pc}			
miss:
	mov	r1, #0			// Move 0 to r1 to return a miss, since a miss condition passed.
	pop	{r6-r10, pc}
remove:
	mov	r10, r1			// Recover address of wall struct
	mov	r6, #4			// Move 0 into r4 so we can make variables 0
	str 	r6, [r1]		// Set X to 0
	str	r6, [r1, #4]		// Set Y to 0
	str	r6, [r1, #8]		// Set width to 0
	str	r6, [r1, #12]		// Set Height to 0
	mov	r1, #1			// Move 1 to r1 to return a hit, since all miss conditions failed
	pop	{r6-r10, pc}	

.global drawBarrier	
drawBarrier:
	push	{r4-r10, lr}
	mov	r4, r1			// r1 should have address of wall
	cmp	r2, #0			// r2 contains clear (0) or draw (1)
	ldreq	r3, =0x000000		// clear
	ldrne	r3, =0x888888		// draw
	ldr	r1, [r4]		// load x
	ldr	r2, [r4, #4]		// load y
	ldr	r5, [r4, #8]		// load width
	ldr	r6, [r4, #12]		// load height
	mov	r7, #0			// initialize counter
	mov	r8, #0			// initialize counter
	bl	drawObject
	pop	{r4-r10, pc}
	
.global resetWalls
resetWalls:
	push	{r4-r10, lr}
	ldr	r4, =EndOfReset		// Load labels for reset loop
	ldr	r5, =Wall1
	ldr	r6, =Reset
rLoop:
	ldr	r7, [r6], #4		// Load r6 into r7, increment by 4 after
	str	r7, [r5], #4		// Store r7 into r5, increment by 4 after	
	cmp	r6, r4
	bne	rLoop			// Break when address at r5 = EndOfReset
	pop	{r4-r10, pc}


.section .data
.align 4

//****************************************************************//
//	 Unit positions on the upper half of the screen:	//
//			     <---------QA---------->			//
//			     <---------QB---------->			//
//			___<---------K------------>			//
// 				  B1	 B2	B3				//
//			___<---------P------------>			//
// 				  B4	        B5 				//
//					 B6					//
//****************************************************************//

.global Wall1
.global Wall2
.global Wall3
.global Wall4
.global Wall5
.global Wall6

Wall1:
	.int	14			// X Position
	.int	240			// Y Position
	.int	350			// Width
	.int	5			// Height
	.int	4			// HP
Wall2:
	.int	412			// X Position
	.int	240			// Y Position
	.int	200			// Width
	.int	5			// Height
	.int	4			// HP
Wall3:
	.int	660			// X Position
	.int	240			// Y Position
	.int	350			// Width
	.int	5			// Height
	.int	4			// HP
Wall4:
	.int	89			// X Position
	.int	325			// Y Position
	.int	400			// Width
	.int	5			// Height
	.int	4			// HP
Wall5:
	.int	535			// X Position
	.int	325			// Y Position
	.int	400			// Width
	.int	5			// Height
	.int	4			// HP
Wall6:
	.int	14			// X Position
	.int	345			// Y Position
	.int	1000			// Width
	.int	5			// Height
	.int	6			// HP

Reset:
	.int	14			// X Position
	.int	240			// Y Position
	.int	350			// Width
	.int	5			// Height
	.int	4			// HP
	.int	412			// X Position
	.int	240			// Y Position
	.int	200			// Width
	.int	5			// Height
	.int	4			// HP
	.int	660			// X Position
	.int	240			// Y Position
	.int	350			// Width
	.int	5			// Height
	.int	4			// HP
	.int	89			// X Position
	.int	325			// Y Position
	.int	400			// Width
	.int	5			// Height
	.int	4			// HP
	.int	535			// X Position
	.int	325			// Y Position
	.int	400			// Width
	.int	5			// Height
	.int	4			// HP
	.int	14			// X Position
	.int	345			// Y Position
	.int	1000			// Width
	.int	5			// Height
	.int	6			// HP
EndOfReset:			// Dummy Label
	

