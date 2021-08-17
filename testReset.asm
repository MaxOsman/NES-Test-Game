.segment "STARTUP"
Reset:
    SEI
    CLD
    LDX #$40
    STX $4017
    LDX #$FF
    TXS
    INX ; Fast X = 0

    STX $2000
    STX $2001
    STX $4010
:
    BIT $2002
    BPL :-

    TXA

CLEARMEM:
    STA $0000, X 
    STA $0100, X 
    STA $0300, X
    STA $0400, X
    STA $0500, X
    STA $0600, X
    STA $0700, X
    LDA #$FD
    STA $0200, X
    LDA #$00
    INX
    BNE CLEARMEM    
:
    BIT $2002
    BPL :-

    LDA #$02
    STA $4014

    NOP

    LDA #$3F
    STA $2006
    LDA #$00
    STA $2006
    LDX #$00

LoadPalettes:
    LDA PaletteData, X
    STA $2007
    INX
    CPX #$20
    BNE LoadPalettes
    LDX #$00

LoadSprites:
    LDA SpriteData, X
    STA $0200, X
    INX
    CPX #$08
    BNE LoadSprites   

    LDA $0200
    STA playerY
    LDA $0203
    STA playerX

    CLI

    LDA #%10110000
    STA $2000
    LDA #%00011110
    STA $2001