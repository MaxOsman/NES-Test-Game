controller = $00
controllerLast = $01
controllerPressed = $02

playerY = $03
playerX = $04
pweaponState = $05			; $05 to $0C, 8
							; 0 means inactive, 1 to 3 is type
pweaponY = $0D				; $0D to $14, 8
pweaponX = $15				; $15 to $1C, 8

playerPower = $1D			; 0 to 2

seed0 = $1E
seed1 = $1F

enemyY = $20				; $20 to $30, 16
enemyX = $30				; $30 to $40, 16
enemyType = $40				; $40 to $50, 16 
							; 0 means dead
							; 1 means red
							; 2 means green
							; 3 means orange
							; 4 means big top-left
							; 5 means big top-right
							; 6 means big bottom-left
							; 7 means big bottom-right
							; 8 means explosion 1
							; 9 means explosion 2
enemyHP = $50				; $50 to $60, 16
enemyTimer = $60			; $60 to $70, 16
enemyShotCooldown = $70		; $70 to $80, 16
enemyFlashTimer = $80		; $80 to $90, 16
enemyPalette = $90			; $90 to $A0, 16

eweaponState = $A0			; $A0 to $B0, 16
							; 0 means inactive, 1 means active
eweaponY = $B0				; $B0 to $C0, 16
eweaponX = $C0				; $C0 to $D0, 16

playerPalette = $D0
playerFlashTimer = $D1

work0 = $F0
work1 = $F1
work2 = $F2
work3 = $F3
work4 = $F4

hasCompletedGameLoop = $0400
tempA = $0401

BUTTON_A      = 1 << 7
BUTTON_B      = 1 << 6
BUTTON_SELECT = 1 << 5
BUTTON_START  = 1 << 4
BUTTON_UP     = 1 << 3
BUTTON_DOWN   = 1 << 2
BUTTON_LEFT   = 1 << 1
BUTTON_RIGHT  = 1 << 0
JOYPAD_1 = $4016

PLAYER_SPRITE_1Y = $0204
PLAYER_SPRITE_1ATTR = $0206
PLAYER_SPRITE_1X = $0207
PLAYER_SPRITE_2Y = $0208
PLAYER_SPRITE_2ATTR = $020A
PLAYER_SPRITE_2X = $020B

PWEAPON_START_Y = $020C
PWEAPON_START_TILE = $020D
PWEAPON_START_ATTR = $020E
PWEAPON_START_X = $020F

ENEMY_SPRITE_1Y = $022C
ENEMY_SPRITE_1TILE = $022D
ENEMY_SPRITE_1ATTR = $022E
ENEMY_SPRITE_1X = $022F
ENEMY_SPRITE_2Y = $0230
ENEMY_SPRITE_2TILE = $0231
ENEMY_SPRITE_2ATTR = $0232
ENEMY_SPRITE_2X = $0233

EWEAPON_START_Y = $02B0
EWEAPON_START_TILE = $02B1
EWEAPON_START_ATTR = $02B2
EWEAPON_START_X = $02B3