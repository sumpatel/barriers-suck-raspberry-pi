.global drawObj	
drawObj:
	push	{r4-r10, lr}
	mov	r4, r1			// r1 should have address of Object to draw
	ldr	r5, [r4, #20]		// Load color of object to draw
	cmp	r5, #2			// r5 contains type queen(1), knight(2), pawn(3)
	ldrlt	r3, =0xEEEEEE		// Color for queen
	ldreq	r3, =0x000f0f		// Color for knight
	ldrgt	r3, =0x000FFF		// Color for pawn
	cmp	r2, #0			// r2 contains clear (0)
	ldreq	r3, =0x000000		// clear
	ldr	r1, [r4, #12]		// load x
	ldr	r2, [r4, #16]		// load y
	ldr	r5, [r4]		// load width
	ldr	r6, [r4, #4]		// load height
	mov	r7, #0			// initialize counter
	mov	r8, #0			// initialize counter
	bl	drawObject
	pop	{r4-r10, pc}


.global UnitVsWorld
UnitVsWorld:
	push	{r4-r10, lr}
	mov	r10, r1			// r1 = Unit address, make local copy of unit address for future use
	ldr	r4, [r10, #36]		// Load Bullet x position
	ldr	r5, [r10, #40]		// Load Bullet y position
	add	r4, #-5			// Account for bullet size in collusion
	ldr	r1, =Wall1		// Load address of Wall1 for checking
	bl	BarrierCollision	// Check for collision at Wall1
	cmp	r1, #1			// Compare return value, 0 = miss, 1 = hit
	beq	hit			// Delete the bullet if a hit is found
	ldr	r1, =Wall2		// Load address of Wall1 for checking
	bl	BarrierCollision	// Check for collision at Wall2
	cmp	r1, #1			// Compare return value, 0 = miss, 1 = hit
	beq	hit			// Delete the bullet if a hit is found
	ldr	r1, =Wall3		// Load address of Wall1 for checking
	bl	BarrierCollision	// Check for collision at Wall3
	cmp	r1, #1			// Compare return value, 0 = miss, 1 = hit
	beq	hit			// Delete the bullet if a hit is found
	ldr	r1, =Wall4		// Load address of Wall1 for checking
	bl	BarrierCollision	// Check for collision at Wall4
	cmp	r1, #1			// Compare return value, 0 = miss, 1 = hit
	beq	hit			// Delete the bullet if a hit is found
	ldr	r1, =Wall5		// Load address of Wall1 for checking
	bl	BarrierCollision	// Check for collision at Wall5
	cmp	r1, #1			// Compare return value, 0 = miss, 1 = hit
	beq	hit			// Delete the bullet if a hit is found
	ldr	r1, =Wall6		// Load address of Wall1 for checking
	bl	BarrierCollision	// Check for collision at Wall6
	cmp	r1, #1			// Compare return value, 0 = miss, 1 = hit
	beq	hit			// Delete the bullet if a hit is found
	add 	r5, #7			// Add 12 to Y position to account for player size
	bl	PlayerHit		// Check if player was hit
	cmp	r1, #1			// Compare return value, 0 = miss, 1 = hit
	beq	hit			// Delete the bullet if a hit is found
	b	miss			// Nothing was hit, branch to miss
hit:	add	r10, r10, #24 		// Move address of bullet (Unit + Bullet) to r1
	b	deleteBullet
miss:	pop	{r4-r10, pc}

.global moveEBullet
moveEBullet:
	push	{r4-r10, lr}
	mov	r10, r1			// Make copy of bullet address for local use
	ldr	r4, [r10, #4]		// Load height
	cmp 	r4, #0			// Compare with 0
	beq 	else			// Branch to else if bullet DNE
 	mov	r1, r10			// Move address of bullet to r1
	mov	r2, #0			// Move 0 to r2
	bl	drawObj			// Clear the bullet
	ldr	r5, [r10, #16]		// Load y position
	add	r5, #3			// Add 3 to bullet Y location (bullet speed)
	cmp 	r5, #724		// Check if bullet is at screen edge or past it
	bge 	deleteBullet		// Delete the bullet if it is
	str	r5, [r10, #16]		// Store new Y for bullet
	mov	r1, r10			// Move address of bullet to r1
	mov	r2, #1			// Move 1 to r2
	bl	drawObj			// Draw the bullet
	b 	else
deleteBullet:
 	mov	r1, r10			// Move address of bullet to r1
	mov	r2, #0			// Move 0 to r2
	bl	drawObj			// Clear the bullet
	mov 	r4, #0
	str 	r4, [r10, #4]		// Store 0 in height
	str 	r3, [r10]		// Store 0 in width
	mov 	r5, #1000		// Move 1000 to r5
	str 	r5, [r10, #12]		// Put bullet at x= 1000
	mov	r5, #800		// Move 800 to r5
	str 	r5, [r10, #16]		// Put bullet at y= 800
	mov 	r1, #1			// Put 1 back into r1 so calling code works properly
else:
	pop	{r4-r10, pc}

.global	moveUnit
moveUnit:
	push	{r4-r10, lr}
	mov	r10, r1			// Make copy of address for local use
	mov	r2, #0			// Clear Unit
	bl	drawObj
	ldr	r4, [r10, #12]		// Load unit X
	ldr	r5, [r10, #32]		// Load unit direction
	cmp	r5, #0			// Check if unit is moving left
	bne	right			// Branch to right loop
left:	add	r4, #-1			// Move unit left 1px
	cmp	r4, #100		// Check if unit is at desired boundry
	blo	switch			// Switch direction
	b	go			// Carry on
right:	add	r4, #1			// Move unit right 1px
	cmp	r4, #924		// Check if unit is at desired boundry
	bhi	switch			// Flip the direction
	b	go			// Carry on
switch: cmp	r5, #0			// Check direction
	moveq	r5, #1			// flip if equal
	movne	r5, #0			// flip if not equal
	str	r5, [r10, #32]		// store new direction
go:	str	r4, [r10, #12]		// store new x value
	mov	r1, r10			// address for drawing
	mov	r2, #1			// make sure it draws
	bl	drawObj			// Draw it
	pop	{r4-r10, pc}

.global checkWin
checkWin:
	push	{r4-r10, lr}
	ldr 	r4, =Pawn		// Load Pawn
	ldr	r5, =Knight		// Load Knight
	ldr	r6, =QueenA		// Load QueenA
	ldr	r7, =QueenB		// Load QueenB
	ldr	r8, [r4, #48]		// Load Pawn(s) remaining
	ldr	r4, [r5, #48]		// Load Knight(s) remaining
	ldr	r5, [r6, #48]		// Load QueenA remaining
	ldr	r7, [r7, #48]		// Load QueenB remaining
	add	r9, r8, r5		// Add QueenA's HP and Knight amount to Pawn amount
	add	r9, r7			// Add QueenB's HP to the above
	add	r9, r4
	cmp 	r9, #0			// Compare total to 0 (no enemies remaining)
	ldreq	r10, =gameState		// Loads the game state
	moveq	r9, #2			// Change to win state
	streq	r9, [r10]		// Stores new game state
	pop	{r4-r10, pc}

.global EShootBullet
EShootBullet:
	push	{r4-r10, lr}
	mov	r10, r1			// Make copy of address for local use
	ldr	r4, [r10, #48]		// Load HP of unit
	cmp	r4, #0
	beq 	cancel
	ldr	r4, [r10, #28]		// Load Height
	cmp	r4, #0
	bne 	cancel
	mov	r5, #5
	str	r5, [r10, #24] 		// Store Width
	str	r5, [r10, #28]		// Store Height
	ldr	r5, [r10, #12]		// Load x pos
	ldr 	r6, [r10] 
	lsr 	r6, #1
	add	r5, r6			// Add 1 to unit x position
	str	r5, [r10, #36]		// Store bullet x as unit x +1
	ldr	r6, [r10, #16]		// Load y pos
	ldr	r8, [r10, #4]		// Load unit Height
	add	r6, r8			// Add Unit height to Unit Y
	str	r6, [r10, #40]		// Store bullet y as unit Y + unit 
	add	r1, r10, #24
	mov	r2, #1			// Move 1 to r2
	bl	drawObj			// Draw the bullet
cancel:	pop	{r4-r10, pc}
	

.global UnitHit
UnitHit:
	push	{r6-r10, lr}
	mov	r10, r1			// Make copy of unit address for local use
	ldr	r6, [r10, #12]		// Load unit xpos
	ldr	r7, [r10]		// Load unit width
	add	r6, #-1			// Add -1 to unit x pos (bullets are fat)
	cmp	r4, r6			// Compare player bullet xpos to unit xpos
	blo	lucky			// Branch on LO to lucky
	add	r6, r7			// Add unit width to xpos
	cmp	r4, r6			// Compare player bullet xpos+w to unit xpos
	bhi	lucky			// Branch on HI to lucky
	ldr	r6, [r10, #16]		// Load unit ypos
	cmp	r5, r6			// Compare bullet y pos to unit ypos
	blo	lucky			// Branch on LO to lucky
	ldr	r7, [r10, #4]		// Load unit height
	add	r6, r7			// Add unit height to ypos
	cmp	r5, r6			// compare bullet y pos to above
	bhi	lucky			// Branch on HI to lucky
	ldr	r6, [r10, #8]		// Load unit HP
	add	r6, #-10		// Decrement by 10
	str	r6, [r10, #8]		// Store Unit HP
	cmp	r6, #0			// Compare unit HP to 0
	beq	unitKilled		// Branch to unitKilled if eq
	mov	r1, #1			// Move 1 to r1 to return hit
	pop	{r6-r10, pc}
lucky:	mov	r1, #0				
	pop	{r6-r10, pc}
unitKilled:
	mov	r1, r10			// Move address of unit to r1
	mov	r2, #0			// Move 0 to clear unit
	bl	drawObj			// Delete unit
	ldr	r6, [r10, #48]		// Load unit kill count
	add	r6, #-1			// Decrement kc
	str 	r6, [r10, #48]
	ldr	r7, [r10, #20]		// Load unit type
	cmp	r7, #2			// Compare unit type
	moveq	r1, #10			// if type is =2 put 10 in r1
	movlt	r1, #100		// if type is <2 put 100 in r1
	movgt	r1, #5			// if type is >2 put 5 in r1
	bl	changeHealth		// Call changeHealth to update score
	cmp	r6, #0			// Compare kill count to 0
	beq	unitDead		// Branch to unitDead if eq
	mov	r9, #1
	str	r9, [r10, #12]		// Store 0 to unit x (respawn)
	cmp	r7, #2			// Compare unit type
	moveq	r9, #30			// If type is 2, store 30 in unit hp
	movne	r9, #10			// If not, store 10 in unit hp
	str	r9, [r10, #8]				
	mov	r1, r10			// Move address of unit to r1
	mov	r2, #1			// Move 1 to not clear unit
	bl	drawObj			// Draw unit
	mov	r1, #1			// Move 1 to r1 (hit)
	pop	{r6-r10, pc}
unitDead:
	mov	r6, #0			// Move 0 into r6
	str	r6, [r10]		// Store 0 in unit width
	str	r6, [r10, #4]		// Store 0 in unit height
	str	r6, [r10, #12]		// Store 0 in unit xpos
	str	r6, [r10, #16]		// Store 0 in unit ypos
	mov	r1, #1			// Move 1 to r1 (hit)
	pop	{r6-r10, pc}	
	
	
.global resetEnemy
resetEnemy:
	push	{r4-r10, lr}
	ldr	r4, =EndOfReset		// Load labels for reset loop
	ldr	r5, =Pawn
	ldr	r6, =Reset
rLoop:
	ldr	r7, [r6], #4		// Load r6 into r7, increment by 4 after
	str	r7, [r5], #4		// Store r7 into r5, increment by 4 after	
	cmp	r6, r4			// Check if end of reset
	bne	rLoop			// Break when address at r5 = EndOfReset
	pop	{r4-r10, pc}


.section .data
.align 4

.global Pawn
.global Knight
.global QueenA
.global QueenB
Pawn:
	.int	50			// Unit X Resolution (width)	0
	.int	2			// Unit Y Resolution (height)	1
	.int	10			// Pawn hp			2
	.int	0			// Unit x position		3
	.int	288			// Unit y position		4
	.int	3			// UnitType			5
 	.int 	0			// Bullet width			6
 	.int 	0			// Bullet height		7
  	.int 	1			// Direction			8
	.int 	475			// Bullet x position		9
  	.int 	675			// Bullet y position		10
	.int	3			// UnitType			11
	.int	10			// Kill count			12
Knight:
	.int	30			// Unit X Resolution (width)
	.int	30			// Unit Y Resolution (height)
	.int	30			// Knight hp
	.int	0			// Unit x position
	.int	150			// Unit y position
	.int	2			// UnitType
 	.int 	0			// Bullet width
 	.int 	0			// Bullet height
	.int 	1			// Direction
 	.int 	475			// Bullet x position
  	.int 	675			// Bullet y position
	.int	2			// UnitType
	.int	5			// Kill count
QueenA:			// Upper queen
	.int	21			// Unit X Resolution (width)
	.int	21			// Unit Y Resolution (height)
	.int	100			// QueenA hp
	.int	524			// Unit x position
	.int	60			// Unit y position
  	.int	1			// UnitType
 	.int 	0			// Bullet width
 	.int 	0			// Bullet height
	.int 	0			// Direction
 	.int 	475			// Bullet x position
  	.int 	675			// Bullet y position
  	.int	1			// UnitType
  	.int	1			// Kill count
QueenB:			// Lower queen
	.int	21			// Unit X Resolution (width)
	.int	21			// Unit Y Resolution (height)
	.int	100			// QueenB hp
	.int	524			// Unit x position
	.int	105			// Unit y position
  	.int	1			// UnitType
 	.int 	0			// Bullet width
 	.int 	0			// Bullet height
	.int 	1			// Direction
 	.int 	475			// Bullet x position
  	.int 	675			// Bullet y position
  	.int	1			// UnitType
  	.int	1			// Kill count


Reset:
	.int	50			// Unit X Resolution (width)
	.int	2			// Unit Y Resolution (height)
	.int	10			// Pawn hp
	.int	0			// Unit x position
	.int	288			// Unit y position
  	.int	3			// UnitType
 	.int 	0			// Bullet width
 	.int 	0			// Bullet height
	.int 	1			// Direction
 	.int 	0			// Bullet x position
  	.int 	0			// Bullet y position
  	.int	3			// UnitType
	.int	10			// Kill count
	.int	30			// Unit X Resolution (width)
	.int	30			// Unit Y Resolution (height)
	.int	30			// Knight hp
	.int	0			// Unit x position
	.int	150			// Unit y position
  	.int	2			// UnitType
 	.int 	0			// Bullet width
 	.int 	0			// Bullet height
	.int 	1			// Direction
 	.int 	0			// Bullet x position
  	.int 	0			// Bullet y position
  	.int	2			// UnitType
	.int	5			// Kill count
	.int	21			// Unit X Resolution (width)
	.int	21			// Unit Y Resolution (height)
	.int	100			// QueenA hp
	.int	524			// Unit x position
	.int	60			// Unit y position
  	.int	1			// UnitType
 	.int 	0			// Bullet width
 	.int 	0			// Bullet height
	.int 	0			// Direction
 	.int 	0			// Bullet x position
  	.int 	0			// Bullet y position
  	.int	1			// UnitType
  	.int	1			// Kill count
	.int	21			// Unit X Resolution (width)
	.int	21			// Unit Y Resolution (height)
	.int	100			// QueenB hp
	.int	524			// Unit x position
	.int	105			// Unit y position
  	.int	1			// UnitType
 	.int 	0			// Bullet width
 	.int 	0			// Bullet height
	.int 	1			// Direction
 	.int 	0			// Bullet x position
  	.int 	0			// Bullet y position
  	.int	1			// UnitType
  	.int	1			// Kill count
EndOfReset:				// Dummy Label
