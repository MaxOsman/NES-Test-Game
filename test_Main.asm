.segment "HEADER"
.byte "NES"
.byte $1A
.byte $02           ; 2 * 16KB PRG ROM
.byte $01           ; 1 * 8KB CHR ROM
.byte %00000001
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
    stx tempX

    ; Shadow OAM
    lda #$02    
    sta $4014

    ; Cycle palette
    inc paletteCycleTimer
    lda paletteCycleTimer
    cmp #$40
    bne SkipPaletteCycle
    ; Use next palette
    lda #$00
    sta paletteCycleTimer
    inc paletteCycleIndex
    lda paletteCycleIndex
    and #%00000011
    sta paletteCycleIndex
    asl
    asl
    tax
    ; Point PPUADDR to palette address
    lda #$3F
    sta $2006
    lda #$04
    sta $2006
LoadCyclePalettes:
    lda PaletteCycle, X
    sta $2007
    inx
    txa
    and #%00000011
    bne LoadCyclePalettes
    lda PPUCTRL
    sta $2000
SkipPaletteCycle:

    ; Scroll background
    bit $2002
    lda backgroundScroll
    clc
    adc #$01
    sta backgroundScroll
    bcc ChangePageSkip
    ; Change page
    lda PPUCTRL
    eor #%00000001
    and #%11111101
    sta PPUCTRL
    sta $2000
    lda backgroundScroll
ChangePageSkip:
    sta $2005
    lda #$00
    sta $2005

    ; Set up next game loop
    lda #$00
    sta hasCompletedGameLoop
    lda tempA
    ldx tempX

    rti


PaletteData:
    .byte     $0F, $00, $10, $20,     $0F, $1C, $2C, $20,     $0F, $0F, $0F, $0F,    $0F, $0F, $0F, $0F   ; Backgrounds
    .byte     $0F, $16, $27, $20,     $0F, $12, $21, $20,     $0F, $09, $29, $20,    $0F, $14, $25, $34   ; Sprites

SpriteData:
    .byte $00, $FD, $FD, $00
    .byte $C8, $00, $00, $78
    .byte $C8, $00, $40, $80

PaletteCycle:
    .byte $0F, $1C, $2C, $20
    .byte $0F, $0F, $1C, $2C
    .byte $0F, $0F, $0F, $1C
    .byte $0F, $0F, $1C, $2C

.segment "VECTORS"
    .word NMI
    .word Reset
    .word 0

.segment "CHARS"
    .incbin "test.chr"