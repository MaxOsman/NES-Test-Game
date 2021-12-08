.segment "HEADER"
.byte "NES"
.byte $1A
.byte $02           ; 2 * 16KB PRG ROM
.byte $01           ; 1 * 8KB CHR ROM
.byte %00000000
.byte $00
.byte $00
.byte $00
.byte $00
.byte $00, $00, $00, $00, $00

.include "testDefs.asm"
.include "testGameLoop.asm"
.include "testMaps.asm"
.include "testReset.asm"
.include "testRNG.asm"
.include "testController.asm"
.include "testCollisions.asm"

.segment "STARTUP"

GameLoop:

    jsr Movement            ; Player character actions
    jsr NPCMovement         ; Shots
    jsr AssembleSprites     ; Put 2nd sprite next to the 1st one
    jsr ReadController      ; $4016 stuff
    jsr EnemyCollisions     ; Shots on enemies
    jsr PlayerCollisions    ; Shots on player

    lda #$01
    sta hasCompletedGameLoop
WaitForNMI:
    ; Wait until value = 0
    lda hasCompletedGameLoop
    beq BeginNewLoop
    jmp WaitForNMI
BeginNewLoop:
    jmp GameLoop

NMI:
    sta tempA

    lda #$02    ; Shadow OAM
    sta $4014

    ; Set up next game loop
    lda #$00
    sta hasCompletedGameLoop
    lda tempA

    rti

PaletteData:
    .byte     $0F, $00, $10, $20,     $0F, $0F, $0F, $0F,     $0F, $0F, $0F, $0F,    $0F, $0F, $0F, $0F   ; Backgrounds
    .byte     $0F, $16, $27, $20,     $0F, $12, $21, $20,     $0F, $09, $29, $20,    $0F, $14, $25, $34   ; Sprites

SpriteData:
    .byte $00, $FD, $FD, $00
    .byte $C8, $00, $00, $78
    .byte $C8, $00, $40, $80 

.segment "VECTORS"
    .word NMI
    .word Reset
    .word 0

.segment "CHARS"
    .incbin "test.chr"