.segment "CODE"


; The range that something is visible on screen - #$08 to #$D8
; So that gives us 14 rows, 224 pixels tall
; Except nothing will be close to player, so bottom 3 not needed
; Also nothing will be around the edges, so remove one from top and one from each side
; Remove 1 from top due to HUD
; Therefore 14 * 9 bytes, 16x16 pixels each

;	XXXX XXXX XXXX XXXX
;	XXXX XXXX XXXX XXXX
;	XOOO OOOO OOOO OOOX
;	XOOO OOOO OOOO OOOX
;	XOOO OOOO OOOO OOOX
;	XOOO OOOO OOOO OOOX
;	XOOO OOOO OOOO OOOX
;	XOOO OOOO OOOO OOOX
;	XOOO OOOO OOOO OOOX
;	XOOO OOOO OOOO OOOX
;	XOOO OOOO OOOO OOOX
;	XXXX XXXX XXXX XXXX
;	XXXX XXXX XXXX XXXX
;	XXXX XXXX XXXX XXXX


MapTest:
	.byte	$00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00
	.byte	$00, $00, $00,		$01, $00, $00, $00,		$00, $00, $00, $01,		$00, $00, $00
	.byte	$00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00
	.byte	$00, $00, $00,		$01, $00, $00, $00,		$00, $00, $00, $01,		$00, $00, $00
	.byte	$00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00
	.byte	$00, $00, $00,		$01, $00, $00, $00,		$00, $00, $00, $01,		$00, $00, $00
	.byte	$00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00
	.byte	$00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00
	.byte	$00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00


; Y - iterate from start byte to last
; A - enemy type
; 2 - number of enemies that have been processed so far, 16
; 3 - Temp for transfers
; 4 - Row counter
LoadLevelMap:
	ldy #$00
	sty work2
	sty work4
LoadLevelLoop:
	lda MapTest, Y
	beq LoadLevelIterate	; Skip if byte is $00

	ldx work2
	sta enemyType, X
	; Initialise timer
	stx work3
	tax
	lda InitTimers, X
	stx work1
	ldx work3
	sty work3
	jsr PRNG
	lda seed0
	and #%00000001
	; Skip additional time if = 0
	beq SkipRandom
	clc
	adc #$40
SkipRandom:
	sta enemyTimer, X

	; Initialise HP/Palette
	ldy work1
	lda InitHP, Y
	sta enemyHP, X
	lda InitPalettes, Y
	sta enemyPalette, X
	ldy work3

	; Initialise FlashTimer
	lda #$00
	sta enemyFlashTimer, X

	lda work2
	tax
	tya
	sec
PosLoop:
	inc work4
	sbc #$0E
	bcs PosLoop				; Subtract row until at top
	inc work4
	adc #$0F				; Re-add the last 0E, then add 1
	asl
	asl
	asl
	asl						; * 16 starting from 2nd position
	sta enemyX, X			; X can safely be overwritten since it is written every loop anyway, and its use for this loop is over

	lda work4
	asl
	asl
	asl
	asl
	sta enemyY, X

	lda #$00
	sta work4

	inc work2
	lda work2
	cmp #$10				; 16 sprites
	beq LoadLevelEnd		; If it has reached max capacity, end

LoadLevelIterate:
	iny
	cpy #$7E				; $E * $9
	bne LoadLevelLoop		; If has not reached end of data, restart loop
LoadLevelEnd:
	rts

InitTimers:
	.byte $00, $1F, $00, $00, $00, $00, $00, $00
InitHP:
	.byte $00, $07, $00, $00, $00, $00, $00, $00
InitPalettes:
	.byte $00, $00


LoadBackground:
	; Point PPUADDR to nametable 0
	; 0 - Random counter, 1 - Temp Y, 2 - 16 bit counter, 3 - jank, 4 - Do 2nd nametable?
	lda #$20
	sta $2006
	lda #$00
	sta $2006

	sta work4
RestartBackground:
	ldy #$00
	ldx #$00
	sty work2
	sty work3
BackgroundLoop:
	sty work1
	jsr PRNG
	and #%01111000
	beq BackgroundLoop
	sta work0
	ldy work1
BackgroundLoop2:
	lda #$00
	sta $2007

	jsr BackgroundLoopIncrement
	lda work3
	bne BackgroundLoopFinish

	inx
	cpx work0
	bne BackgroundLoop2

	; Place star
	lda #$25
	sta $2007

	jsr BackgroundLoopIncrement
	lda work3
	bne BackgroundLoopFinish

	ldx #$00
	jmp BackgroundLoop

BackgroundLoopIncrement:
	; Total number of tiles placed
	iny
	cpy #$40
	beq BackgroundLoopIncrement2

	rts
	
BackgroundLoopIncrement2:
	ldy #$00
	inc work2
	lda work2
	cmp #$0D
	bne BackgroundLoopIncrement3
	inc work3
BackgroundLoopIncrement3:
	rts

BackgroundLoopFinish:
	inc work4
	lda work4
	cmp #$02
	beq LoadAttributes

	; 2nd nametable
	lda #$24
	sta $2006
	lda #$00
	sta $2006

	jmp RestartBackground

LoadAttributes:
	; Point PPUADDR to attribute table 0
	lda #$23
	sta $2006
	lda #$C0
	sta $2006

	lda #$00
	sta work4
RestartAttr:
	ldx #$00
AttributeLoop:
	lda #%01010101		; Background palette 1 in all 4 quadrants
	sta $2007
	inx
	cpx #$40
	bne AttributeLoop

	; 2nd attr table
	inc work4
	lda work4
	cmp #$02
	beq FinishAttr
	; Loop attr once
	lda #$27
	sta $2006
	lda #$C0
	sta $2006
	jmp RestartAttr
FinishAttr:
	rts