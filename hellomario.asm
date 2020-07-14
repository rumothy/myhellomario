.segment "HEADER"
.byte "NES"
.byte $1a
.byte $02    
.byte $01
.byte %00000000
.byte $00
.byte $00
.byte $00
.byte $00
.byte $00, $00, $00, $00, $00
.segment "ZEROPAGE" ; lsb 00 - ff
.segment "STARTUP"   
Reset:
    sei
    cld

    ldx #$40
    stx $4017

    ; Initialize the stack register
    ldx #$ff
    txs

    inx ; ff + 1 = 0

    ; set ppu registers to 0
    stx $2000
    stx $2001

    stx $4010

:    
    bit $2002
    bpl :-  ; branch to previous anonymous label

    txa 

ClearMem:
    sta $0000, x ; set addresses $0000 - $00ff to a:0 
    sta $0100, x ; clears $0100 - $01ff
    sta $0300, x
    sta $0400, x
    sta $0500, x
    sta $0600, x
    sta $0700, x
    lda #$ff
    sta $0200, x
    lda #$00
    inx
    bne ClearMem

; wait for vblank
:
    bit $2002
    bpl :-

    lda #$02
    sta $4014
    nop

    ; write to address $3f00
    lda #$3f
    sta $2006
    lda #$00
    sta $2006

    ldx #$00

LoadPalettes: 
    lda PaletteData, x
    sta $2007 ; ppu increments its address - $3f00, $3f01, $3f02, ..., $3f1f
    inx
    cpx #$20
    bne LoadPalettes

    ldx #$00
LoadSprites:
    lda SpriteData, x
    sta $0200, x
    inx
    cpx #$20
    bne LoadSprites    

; Enable interrupts
    cli

    
    ; setup ppu
    lda #%10010000 
    sta $2000
    lda #%00011110 
    sta $2001

Loop:
    jmp Loop
NMI:
    lda #$02
    sta $4014   ; copy sprite data from $0200 for ppu mem to display
    rti

PaletteData:
    .byte $22, $29, $1a, $0f, $22, $36, $17, $0f, $22, $30, $21, $0f, $22, $27, $17, $0f ; background palette data. indexes 00 - 0f
    .byte $22, $16, $27, $18, $22, $1a, $30, $27, $22, $16, $30, $27, $22, $0f, $36, $17 ; sprite palette data. indexes 10 - ff


 SpriteData:
    .byte $08, $00, $00, $08 ; offset in y axis by 8 pixels, tile number 00, offset in x axis by 8 pixels
    .byte $08, $01, $00, $10 
    .byte $10, $02, $00, $08 
    .byte $10, $03, $00, $10 
    .byte $18, $04, $00, $08 
    .byte $18, $05, $00, $10 
    .byte $20, $06, $00, $08 
    .byte $20, $07, $00, $10
    

.segment "VECTORS"
    .word NMI
    .word Reset
    ; 
.segment "CHARS"
    .incbin "hellomario.chr"