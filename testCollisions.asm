.segment "CODE"


ShotLoopNextJump:
	jmp ShotLoopNext

Collisions:
; Increment Y first until end, then increment X by 1
; X - shot counter, Y - enemy counter, 0 - enemyY, 1 - enemyX, 2 to 4 - temp
	ldx #$00
	ldy #$00

ShotLoop:
	lda pweaponState, X
	beq ShotLoopNextJump	; If inactive (zero), skip detection and continue
EnemyLoop:
	lda enemyType, Y
	beq EnemyLoopNext		; If inactive (zero), skip detection and continue

; Detect collision
; Store centre Y coords
	lda enemyY, Y
	clc
	adc #$07
	sta work0
	lda pweaponY, X
	adc #$07			; A contains centre Y of shot

; Compare Y coords
	sec
	sbc work0
	jsr GetAbsolute
	sty work2
	sta work3
	ldy pweaponState, X
	dey
	lda ShotHitboxHeight, Y
	ldy work2
	sta work4
	lda work3
	cmp work4			; Distance between hitbox centers
	bcs	EnemyLoopNext	; Leave early if no collision vertically

; Store centre X coords
	lda enemyX, Y
	adc #$07
	sta work1
	lda pweaponX, X
	adc #$03			; A contains centre X of shot

; Compare X coords
	sec
	sbc work1
	jsr GetAbsolute
	sty work2
	sta work3
	ldy pweaponState, X
	dey
	lda ShotHitboxWidth, Y
	ldy work2
	sta work4
	lda work3
	cmp work4			; Distance between hitbox centers
	bcs	EnemyLoopNext	; Leave early if no collision horizontally

; Collision response!
	; Take damage
	lda enemyHP, Y
	stx work2
	ldx playerPower
	sec
	sbc PWeaponDamages, X
	sta enemyHP, Y
	bcs SkipKill
	; HP goes from 0, $FF is death
	lda #$00
	sta enemyType, Y
SkipKill:
	ldx work2
	lda pweaponState, X
	cmp #$03
	bne ClearSingleShot
	; Remove both halves of shot at once
	txa
	and #%00000001		; Will return 1 if A is odd, 0 if even
	beq RemoveOdd		; If an even (0, 2, ...) number ID, remove odd (next)
	; Remove even
	dex
	lda #$00
	sta pweaponState, X
	lda #$FF
	sta pweaponY, X
	inx

ClearSingleShot:
	lda #$00
	sta pweaponState, X
	lda #$FF
	sta pweaponY, X

EnemyLoopNext:
	iny
	cpy #$10
	bne ShotLoopJump
	ldy #$00

ShotLoopNext:
	inx
	cpx #$08
	bne ShotLoopJump
	; Has reached end
	rts

ShotLoopJump:
	jmp ShotLoop

GetAbsolute:
	bpl GetAbsoluteEnd
	eor #$FF
	clc
	adc #$01
GetAbsoluteEnd:
	rts

RemoveOdd:
	inx
	lda #$00
	sta pweaponState, X
	lda #$FF
	sta pweaponY, X
	dex
	jmp ClearSingleShot

ShotHitboxWidth:
	.byte $09, $09, $0C
ShotHitboxHeight:
	.byte $0E, $0E, $08
PWeaponDamages:
	.byte $01, $01, $04