.segment "CODE"


ReadController:
	LDA controller
	STA controllerLast	; Set previous frame

	LDA #$01
	STA JOYPAD_1		; Set strobe bit

	STA controller

	LSR A				; A = 0 quickly
	STA JOYPAD_1		; Turn off strobe

:
	LDA JOYPAD_1
	LSR A
	ROL controller
	BCC :-

	LDA controller
	EOR controllerLast
	AND controller			; Only presses, not releases
	STA controllerPressed	; Difference in inputs

	RTS


Movement:

; Hold left
	LDA controller
	AND #BUTTON_LEFT
	BEQ EndLeft		; If left is false, branch
	LDA playerX
	SEC
	SBC #$03
	BCC EndLeft		; Clamp left side
	STA playerX
EndLeft:

; Hold right
	LDA controller
	AND #BUTTON_RIGHT
	BEQ EndRight	; If right is false, branch
	LDA playerX
	CLC
	ADC #$03
	TAX
	ADC #$10		; X pos should not exceed $F0
	BCS EndRight	; Clamp right side
	STX playerX
EndRight:

; Press A
	LDA controllerPressed
	AND #BUTTON_A
	BEQ EndA		; If A is false

	; Debug
	LDX playerPower
	INX
	CPX #$03
	BNE :+
	LDX #$00
:
	STX playerPower

	EndA:

; Press B
; X - Increments 0 to 7, A - Generic, Y - 4 times X, 0 and 1 - Reserved slots, 2 - Attributes bool
	LDA controllerPressed
	AND #BUTTON_B
	BEQ EndB		; If B is false

	LDX #$00
	STX workAddress2
	LDA #$FF
	; 0 to 7, with FF being default
	STA workAddress0
	STA workAddress1
	CLC
:

	; Depending on powerup state, reserve 1 or 2 sprites
	LDA playerPower
	CMP #$00
	BNE Reserve2
	; Reserve1
	LDA shotsActive, X		; Branch if shotActive entry is zero (inactive)
	BEQ IncrementSingle		; Keep track of how many free slots, only 1 needed
	JMP ResumeLoop
Reserve2:
	LDA shotsActive, X		; Branch if shotActive entry is zero (inactive)
	BEQ IncrementDouble		; Keep track of how many free slots, at least 2 needed

ResumeLoop:
	INX
	CPX #$08
	BNE :-

	; Depending on powerup state, shoot different weapons
	LDA playerPower
	CMP #$00
	BNE PowerState2

	; Make sure a slot is available from the 1st half
	LDA workAddress0
	CMP #$FF
	BEQ EndB	; If slot is empty, skip
	; Fire one shot
	LDY #$04
	LDX workAddress0
	JSR InitShot

	RTS
PowerState2:

	; Make sure two new slots are available
	LDA workAddress0
	CMP #$FF
	BEQ EndB	; If slot 1 is empty, skip
	LDA workAddress1
	CMP #$FF
	BEQ EndB	; If slot 2 is empty, skip

	; Fire both at once
	LDY #$00
	LDX workAddress0
	JSR InitShot
	LDY #$08
	INC workAddress2
	LDX workAddress1
	JSR InitShot

EndB:
	RTS

IncrementSingle:
	SEC
	TXA
	SBC #$04
	BCS EndIncrementSingle		; If carry unchanged (X is larger than 4) then skip
	STX workAddress0
EndIncrementSingle:
	JMP ResumeLoop

IncrementDouble:
	LDA workAddress0
	CMP #$FF
	BNE EndIncrementDouble1		; If slot 1 is not empty, skip
	STX workAddress0
	JMP ResumeLoop
EndIncrementDouble1:
	LDA workAddress1
	CMP #$FF
	BNE EndIncrementDouble2		; If slot 2 is not empty, skip
	STX workAddress1
EndIncrementDouble2:
	JMP ResumeLoop

InitShot:
	SEC
	LDA playerY		; Y pos
	SBC #$0C
	STA shotsY, X	; At this point, Y is the offset
	TYA
	CLC
	ADC playerX		; X pos
	STA shotsX, X
	INC shotsActive, X
	TXA
	CLC
	ROL
	ROL
	TAY
	; Use wave effect if type 3 shot
	LDA playerPower
	CMP #$02
	BEQ InitShotType3
	; Type 1-2 shot
	LDA #$04
	STA SHOT_START_TILE, Y
	LDA #$00
	STA SHOT_START_ATTR, Y
	RTS
InitShotType3:
	LDA #$1C
	STA SHOT_START_TILE, Y
	LDA workAddress2
	BEQ InitShotType3_Left
	; Right
	LDA #%01000011
	STA SHOT_START_ATTR, Y
	RTS
InitShotType3_Left:
	LDA #%00000011
	STA SHOT_START_ATTR, Y
	RTS


NPCMovement:
	
	LDX #$00		; Look for a clear bit
	CLC
:
	LDA shotsActive, X
	BNE MoveShot	; Branch if byte is one (shot in use)
ReturnToLoop:
	INX
	CPX #$08
	BNE :-

	RTS


MoveShot:
	SEC
	LDA shotsY, X
	SBC #$04
	STA shotsY, X
	BCC RemoveShot
	JMP ReturnToLoop

RemoveShot:
	DEC shotsActive, X
	JMP ReturnToLoop


AssembleSprites:

; Player sprite
	LDA playerX
	STA PLAYER_SPRITE_1X
	CLC
	ADC #$08
	STA PLAYER_SPRITE_2X
	LDA playerY
	STA PLAYER_SPRITE_1Y
	STA PLAYER_SPRITE_2Y

; Shot sprites
	LDY #$00
	LDX #$00
:
	LDA shotsY, Y
	STA SHOT_START_Y, X
	LDA shotsX, Y
	STA SHOT_START_X, X
	INY
	INX
	INX
	INX
	INX
	CPY #$08
	BNE :-

	RTS