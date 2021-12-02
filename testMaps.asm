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

	; Initialise HP
	ldy work1
	lda InitHP, Y
	sta enemyHP, X
	ldy work3

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