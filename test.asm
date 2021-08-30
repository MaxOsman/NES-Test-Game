.segment "HEADER"
.byte "NES"
.byte $1a
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

.segment "STARTUP"

JSR LoadLevelMap

GameLoop:

    JSR Movement        ; Player character actions
    JSR NPCMovement     ; Shots
    JSR AssembleSprites ; Put 2nd sprite next to the 1st one
    JSR ReadController  ; $4016 stuff

    LDA #$01
    STA hasCompletedGameLoop
WaitForNMI:
    ; Wait until value = 0
    LDA hasCompletedGameLoop
    BEQ BeginNewLoop
    JMP WaitForNMI
BeginNewLoop:
    JMP GameLoop

NMI:
    STA tempA

    LDA #$02    ; Shadow OAM
    STA $4014

    ; Set up next game loop
    LDA #$00
    STA hasCompletedGameLoop

    LDA tempA

    RTI

PaletteData:
    .byte     $0F, $00, $10, $20,     $0F, $0F, $0F, $0F,     $0F, $0F, $0F, $0F,    $0F, $0F, $0F, $0F   ; Backgrounds
    .byte     $0F, $27, $16, $20,     $0F, $16, $26, $20,     $0F, $16, $19, $20,    $0F, $14, $25, $34   ; Sprites

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