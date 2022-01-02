.segment "STARTUP"
Reset:
    sei
    cld
    ldx #$40
    stx $4017
    ldx #$FF
    txs
    inx         ; Fast X = 0

    stx $2000
    stx $2001
    stx $4010
:
    bit $2002
    bpl :-

    txa

CLEARMEM:
    sta $0000, X 
    sta $0100, X 
    sta $0300, X
    sta $0400, X
    sta $0500, X
    sta $0600, X
    sta $0700, X
    lda #$FD
    sta $0200, X
    lda #$00
    inx
    bne CLEARMEM    
:
    bit $2002
    bpl :-

    lda #$02
    sta $4014

    nop

    ; Point PPUADDR to palette address
    lda #$3F
    sta $2006
    lda #$00
    sta $2006
    ldx #$00

LoadPalettes:
    lda PaletteData, X
    sta $2007
    inx
    cpx #$20
    bne LoadPalettes
    ldx #$00
LoadSprites:
    lda SpriteData, X
    sta $0200, X
    inx
    cpx #$0C
    bne LoadSprites   

    lda PLAYER_SPRITE_1Y
    sta playerY
    lda PLAYER_SPRITE_1X
    sta playerX
    lda #$00
    sta playerPalette

    ; Default seed
    ; Lol
    lda #$13
    sta seed0
    lda #$37
    sta seed1

    jsr LoadBackground
    jsr LoadLevelMap

    lda #%10110000
    sta $2000
    sta PPUCTRL
    lda #%00011110
    sta $2001

    cli