.segment "CODE"


ReadController:
	lda controller
	sta controllerLast	; Set previous frame

	lda #$01
	sta JOYPAD_1		; Set strobe bit

	sta controller

	lsr A				; A = 0 quickly
	sta JOYPAD_1		; Turn off strobe

:
	lda JOYPAD_1
	lsr A
	rol controller
	bcc :-

	lda controller
	eor controllerLast
	and controller			; Only presses, not releases
	sta controllerPressed	; Difference in inputs

	rts


Movement:

; Flash when hit
	lda playerFlashTimer
	; Skip if timer has reached zero
	beq SkipPlayerFlash

	dec playerFlashTimer
	inc playerPalette
	lda playerPalette
	; Clamp to 0-3 range
	and #%00000011
	sta playerPalette
SkipPlayerFlash:

; Hold left
	lda controller
	and #BUTTON_LEFT
	beq EndLeft		; If left is false, branch
	lda playerX
	sec
	sbc #$03
	bcc EndLeft		; Clamp left side
	sta playerX
EndLeft:

; Hold right
	lda controller
	and #BUTTON_RIGHT
	beq EndRight	; If right is false, branch
	lda playerX
	clc
	adc #$03
	tax
	adc #$10		; X pos should not exceed $F0
	bcs EndRight	; Clamp right side
	stx playerX
EndRight:

; Press A
	lda controllerPressed
	and #BUTTON_A
	beq EndA		; If A is false

	; Debug
	ldx playerPower
	inx
	cpx #$03
	bne :+
	ldx #$00
:
	stx playerPower

	EndA:

; Press B
; X - Increments 0 to 7, A - Generic, Y - 4 times X, 0 and 1 - Reserved slots, 2 - Attributes bool
	lda controllerPressed
	and #BUTTON_B
	beq EndB		; If B is false

	ldx #$00
	stx work2
	lda #$FF
	; 0 to 7, with FF being default
	sta work0
	sta work1
	clc
:

	; Depending on powerup state, reserve 1 or 2 sprites
	lda playerPower
	cmp #$00
	bne Reserve2
	; Reserve1
	lda pweaponState, X		; Branch if pweaponState entry is zero (inactive)
	beq IncrementSingle		; Keep track of how many free slots, only 1 needed
	jmp ResumeLoop
Reserve2:
	lda pweaponState, X		; Branch if pweaponState entry is zero (inactive)
	beq IncrementDouble		; Keep track of how many free slots, at least 2 needed

ResumeLoop:
	inx
	cpx #$08
	bne :-

	; Depending on powerup state, shoot different weapons
	lda playerPower
	cmp #$00
	bne PowerState2

	; Make sure a slot is available from the 1st half
	lda work0
	cmp #$FF
	beq EndB	; If slot is empty, skip
	; Fire one shot
	ldy #$04
	ldx work0
	jsr InitShot

	rts
PowerState2:

	; Make sure two new slots are available
	lda work0
	cmp #$FF
	beq EndB	; If slot 1 is empty, skip
	lda work1
	cmp #$FF
	beq EndB	; If slot 2 is empty, skip

	; Fire both at once
	ldy #$00
	ldx work0
	jsr InitShot
	ldy #$08
	inc work2
	ldx work1
	jsr InitShot

EndB:
	rts

IncrementSingle:
	sec
	txa
	sbc #$04
	bcs EndIncrementSingle		; If carry unchanged (X is larger than 4) then skip
	stx work0
EndIncrementSingle:
	jmp ResumeLoop

IncrementDouble:
	lda work0
	cmp #$FF
	bne EndIncrementDouble1		; If slot 1 is not empty, skip
	stx work0
	jmp ResumeLoop
EndIncrementDouble1:
	lda work1
	cmp #$FF
	bne EndIncrementDouble2		; If slot 2 is not empty, skip
	stx work1
EndIncrementDouble2:
	jmp ResumeLoop

InitShot:
	sec
	lda playerY		; Y pos
	sbc #$0C
	sta pweaponY, X	; At this point, Y is the offset
	tya
	clc
	adc playerX		; X pos
	sta pweaponX, X
	; Y = 4 * X
	txa
	asl
	asl
	tay
	lda playerPower
	adc #$01
	sta pweaponState, X	; No longer zero, so it is active
	; Use wave effect if type 3 shot
	cmp #$03
	beq InitShotType3
	; Type 1-2 shot
	lda #$04
	sta PWEAPON_START_TILE, Y
	lda #$00
	sta PWEAPON_START_ATTR, Y
	rts
InitShotType3:
	lda #$1C
	sta PWEAPON_START_TILE, Y
	lda work2
	beq InitShotType3_Left
	; Right
	lda #%01000011
	sta PWEAPON_START_ATTR, Y
	rts
InitShotType3_Left:
	lda #%00000011
	sta PWEAPON_START_ATTR, Y
	rts