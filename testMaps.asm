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
	.byte	$01, $00, $01,		$00, $01, $00, $00,		$00, $00, $01, $00,		$00, $00, $00
	.byte	$00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00
	.byte	$00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00
	.byte	$00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00
	.byte	$00, $00, $00,		$00, $00, $00, $00,		$00, $00, $01, $00,		$00, $00, $00
	.byte	$00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00
	.byte	$00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00
	.byte	$00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00
	.byte	$00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00, $00,		$00, $00, $00


; Y - iterate from start byte to last
; A - enemy type
; 0 and 1 - jump address
; 2 - number of enemies that have been processed so far
; 3 - Temp for transfers
; 4 - Row counter
LoadLevelMap:
	LDY #$00
	STY work2
	STY work4
LoadLevelLoop:
	LDA MapTest, Y
	BEQ LoadLevelIterate	; Skip if byte is $00

	LDX work2
	STA enemyType, X

	LDA work2
	TAX
	TYA
	SEC
PosLoop:
	INC work4
	SBC #$0E
	BCS PosLoop				; Subtract row until at top
	INC work4
	ADC #$0F				; Re-add the last 0E, then add 1
	ASL
	ASL
	ASL
	ASL						; * 16 starting from 2nd position
	ADC #$08
	STA enemyX, X			; X can safely be overwritten since it is written every loop anyway, and its use for this loop is over

	LDA work4
	ASL
	ASL
	ASL
	ASL
	STA enemyY, X

	LDA #$00
	STA work4

	INC work2
	LDA work2
	CMP #$10				; 16 sprites
	BEQ LoadLevelEnd		; If it has reached max capacity, end

LoadLevelIterate:
	INY
	CPY #$7E				; $E * $9
	BNE LoadLevelLoop		; If has not reached end of data, restart loop
LoadLevelEnd:
	RTS