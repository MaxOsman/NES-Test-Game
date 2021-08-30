controller = $00
controllerLast = $01
controllerPressed = $02

playerY = $03
playerX = $04
shotsActive = $05	; $05 to $0C, 8
shotsY = $0D		; $0D to $14, 8
shotsX = $15		; $15 to $1C, 8

playerPower = $1D	; 0 to 2

enemyY = $1E		; $1E to $2D, 16
enemyX = $2E		; $2E to $3D, 16
enemyType = $3E		; $3E to $4D, 16 
					; #$00 means dead
					; #$01 means red
					; #$02 means green
					; #$03 means orange
					; #$04 means big top-left
					; #$05 means big top-right
					; #$06 means big bottom-left
					; #$07 means big bottom-right

work0 = $FB
work1 = $FC
work2 = $FD
work3 = $FE
work4 = $FF

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
PLAYER_SPRITE_1X = $0207
PLAYER_SPRITE_2Y = $0208
PLAYER_SPRITE_2X = $020B

SHOT_START_Y = $020C
SHOT_START_TILE = $020D
SHOT_START_ATTR = $020E
SHOT_START_X = $020F

ENEMY_SPRITE_1Y = $022C
ENEMY_SPRITE_1TILE = $022D
ENEMY_SPRITE_1ATTR = $022E
ENEMY_SPRITE_1X = $022F
ENEMY_SPRITE_2Y = $0230
ENEMY_SPRITE_2TILE = $0231
ENEMY_SPRITE_2ATTR = $0232
ENEMY_SPRITE_2X = $0233