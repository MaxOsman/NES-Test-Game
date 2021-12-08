.segment "CODE"


NPCMovement:
	
; Update shots
	ldx #$00			; Look for a clear bit
:
	lda pweaponState, X
	bne MoveShot		; Branch if byte is not zero (shot in use)
ReturnToShotLoop:
	inx
	cpx #$08
	bne :-

; Update enemies
	ldx #$00
:
	lda enemyType, X
	; Temp, go to enemy 1 if not type 0
	bne MoveEnemy1
ReturnToEnemyLoop:
	inx
	cpx #$10
	; 16 enemies on screen total
	bne :-

; Update EWeapons
	ldx #$00
:
	lda eweaponState, X
	bne MoveEWeapon
ReturnToEWeaponLoop:
	inx
	cpx #$10
	bne :-

	rts

MoveShot:
	sec
	lda pweaponY, X
	sbc #$04
	sta pweaponY, X
	bcc RemoveShot
	jmp ReturnToShotLoop

RemoveShot:
	lda #$00
	sta pweaponState, X
	jmp ReturnToShotLoop

MoveEWeapon:
	clc
	lda eweaponY, X
	adc #$02
	sta eweaponY, X
	bcs RemoveEWeapon
	jmp ReturnToEWeaponLoop

RemoveEWeapon:
	dec eweaponState, X
	jmp ReturnToEWeaponLoop

MoveEnemy1:

; Flash enemy if it has been hit
	lda enemyFlashTimer, X
	; Skip if timer has reached zero
	beq SkipFlash

	dec enemyFlashTimer, X
	inc enemyPalette, X
	lda enemyPalette, X
	; Clamp to 0-3 range
	and #%00000011
	sta enemyPalette, X
SkipFlash:
; Go to next enemy if wrong type
	lda enemyType, X
	cmp #$01
	bne MoveEnemy2

; Roll RNG, all enemies will need to do this so put it here
	jsr PRNG

	stx work0
	lda seed0
	and #%00000011
	clc
	adc enemyShotCooldown, X
	sta work1
	sta enemyShotCooldown, X
	ldy enemyType, X
	tya
	tax
	lda work1
	sec 
	sbc AttackTimes, X
	ldx work0
	; Skip attack if timer not met
	; Subtracting the maximum time from the existing time should produce an underflow, but if it doesn't then the time has been met
	bcc SkipEWeapon
	; Fire EWeapon
	lda #$00
	sta enemyShotCooldown, X
	; Search for empty EWeapon slot
	ldy #$00
:
	lda eweaponState, Y
	; Create if state = 0
	beq CreateEWeapon
	iny
	cpy #$10
	; 16 EWeapons on screen total
	bne :-

	jmp SkipEWeapon

CreateEWeapon:
	; X = enemy index, Y = eweapon index
	lda enemyX, X
	clc
	adc #$03
	sta eweaponX, Y
	lda enemyY, X
	adc #$0B
	sta eweaponY, Y
	; Swap X and Y because 6502 is dumb!
	tya
	tax
	inc eweaponState, X
	ldx work0

SkipEWeapon:

; Move E1
	inc enemyTimer, X
	lda enemyTimer, X
	; Reset timer at 128 ticks
	and #$80
	bne MoveE1Reset
	lda enemyTimer, X
	; Reverse direction halfway through loop
	and #$40
	bne MoveE1Right

; Move E1 Left
	lda enemyTimer, X
	and #%00000001
	beq ReturnToEnemyLoopJump
	dec enemyX, X
ReturnToEnemyLoopJump:
	jmp ReturnToEnemyLoop

MoveE1Right:
	lda enemyTimer, X
	and #%00000001
	beq ReturnToEnemyLoopJump
	inc enemyX, X
	jmp ReturnToEnemyLoop

MoveE1Reset:
	lda #$FF
	sta enemyTimer, X
	jmp ReturnToEnemyLoop

MoveEnemy2:
	; Temp, no enemy 2 or beyond yet
	lda enemyType, X
	cmp #$02
	bne AnimateExplosion

	jmp ReturnToEnemyLoop

AnimateExplosion:
	lda enemyType, X
	cmp #$09
	beq AnimateExplosion2

	lda enemyFlashTimer, X
	cmp #$08
	beq AnimateExplosionChange
	jmp ReturnToEnemyLoop

AnimateExplosionChange:
	lda #$09
	sta enemyType, X
	jmp ReturnToEnemyLoop

AnimateExplosion2:
	lda enemyFlashTimer, X
	cmp #$00
	bne ReturnToEnemyLoopJump
	; Erase enemy
	lda #$00
	sta enemyType, X
	jmp ReturnToEnemyLoop

AttackTimes:
    .byte $00, $F0, $00, $00, $00, $00, $00, $00


AssembleSprites:

; Player sprite
	lda playerX
	sta PLAYER_SPRITE_1X
	clc
	adc #$08
	sta PLAYER_SPRITE_2X
	lda playerY
	sta PLAYER_SPRITE_1Y
	sta PLAYER_SPRITE_2Y
	lda playerPalette
	sta PLAYER_SPRITE_1ATTR
	adc #$40
	sta PLAYER_SPRITE_2ATTR

; PWeapon sprites
	ldy #$00
	ldx #$00
	clc
:
	lda pweaponY, Y
	sta PWEAPON_START_Y, X
	lda pweaponX, Y
	sta PWEAPON_START_X, X
	iny
	txa
	adc #$04
	tax
	cpy #$08
	bne :-

; Enemy sprites
	ldy #$00
	ldx #$00
	clc
:
	stx work0
	ldx enemyType, Y
ContinueEnemyLoop:
	stx work2
	lda EnemyTiles, X
	asl work2
	ldx work0
	sta ENEMY_SPRITE_1TILE, X
	sta ENEMY_SPRITE_2TILE, X
	ldx work2
	lda EnemyAttr, X
	adc enemyPalette, Y
	sta work3
	inx
	lda EnemyAttr, X
	adc enemyPalette, Y
	ldx work0
	sta ENEMY_SPRITE_2ATTR, X
	lda work3
	sta ENEMY_SPRITE_1ATTR, X

	lda enemyY, Y
	sta ENEMY_SPRITE_1Y, X
	sta ENEMY_SPRITE_2Y, X
	lda enemyX, Y
	sta ENEMY_SPRITE_1X, X
	adc #$08
	sta ENEMY_SPRITE_2X, X
EndEnemyLoop:
	txa			; Add 8 to X (4 bytes per sprite * 2)
	clc
	adc #$08
	tax

	iny
	cpy #$10
	bne :-

; EWeapon sprites
	ldy #$00
	ldx #$00
	clc
:
	lda eweaponY, Y
	sta EWEAPON_START_Y, X
	lda eweaponX, Y
	sta EWEAPON_START_X, X
	lda #$18
	sta EWEAPON_START_TILE, X
	lda #$00
	sta EWEAPON_START_ATTR, X
	txa
	adc #$04
	tax

	iny
	cpy #$10
	bne :-

	rts

; %00000010, %01000010
; %00000001, %01000001

EnemyTiles:
	.byte $FE, $02, $0E, $1A, $00, $00, $00, $00, $20, $1E
EnemyAttr:
	.byte %00000000, %00000000
	.byte %00000000, %01000000
	.byte %00000000, %01000000
	.byte %00000000, %01000000
	.byte %00000000, %00000000
	.byte %00000000, %00000000
	.byte %00000000, %00000000
	.byte %00000000, %00000000
	.byte %00000000, %01000000
	.byte %00000000, %01000000