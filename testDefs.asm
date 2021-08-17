controller = $00
controllerLast = $01
controllerPressed = $02

playerY = $03
playerX = $04
shotsActive = $05	; $05 to $0C, 8
shotsY = $0D		; $0D to $14, 8
shotsX = $15		; $15 to $1C, 8

playerPower = $1D		; 0 to 2

workAddress0 = $FF
workAddress1 = $FE
workAddress2 = $FD

hasCompletedGameLoop = $0300
tempA = $0301

BUTTON_A      = 1 << 7
BUTTON_B      = 1 << 6
BUTTON_SELECT = 1 << 5
BUTTON_START  = 1 << 4
BUTTON_UP     = 1 << 3
BUTTON_DOWN   = 1 << 2
BUTTON_LEFT   = 1 << 1
BUTTON_RIGHT  = 1 << 0
JOYPAD_1 = $4016

PLAYER_SPRITE_1Y = $0200
PLAYER_SPRITE_1X = $0203
PLAYER_SPRITE_2Y = $0204
PLAYER_SPRITE_2X = $0207
SHOT_START_Y = $02E0
SHOT_START_TILE = $02E1
SHOT_START_ATTR = $02E2
SHOT_START_X = $02E3