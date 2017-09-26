    .asciimap ' ', '_', {*}+(128-' ')

scoreline:
	.asc    "SCORE: 000000  HI: 000000  ^_: 4"
        	;--------========--------========

airline:
	.asc    "AIR: ---------------------------"
    		;--------========--------========

titlecredidx:
    .byte   0
titlecreds:
    ;        --------========--------========
    .asc    "          PRESS   FIRE          "
    .asc    "       S E A  D R A G O N       "
    .asc    "   ZX81 VERSION BY: SIRMORRIS   "
    .asc    "DISPLAY AND STC PLAYER: ANDY REA"
    .asc    " TITLE TUNE: REAR ADMIRAL MOGGY "
    .asc    "          PRESS   FIRE          "
    .asc    "       S E A  D R A G O N       "
    .asc    "ORIGINAL CODE/GFX:  RUSS WETMORE"


;;	.asciimap 'A','Z', {*}-'A'+$26
;;	.asciimap '0','9', {*}-'0'+$1c
;;	.asciimap '.', $1b
;;	.asciimap ';', $19


titletune:
	.incbin	"title.stc"

sfx:
	.incbin	"zedrag.afb"

lastjoy:
	.byte	0
fire:
	.byte	0

scrolltick:
	.byte	0
scrollpos:
    .word   0

airupdatecounter:
    .byte   0

airlevel:
    .byte   0

titlescreen:
	.byte		$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$3b,$1e,$1f,$3b,$0a,$11,$01,$01,$01,$01
	.byte		$00,$00,$00,$07,$01,$01,$07,$01,$09,$0f,$01,$15,$00,$00,$00,$00,$00,$00,$0f,$01,$01,$01,$01,$01
	.byte		$00,$00,$00,$01,$1a,$00,$01,$18,$01,$01,$18,$01,$00,$00,$00,$00,$00,$00,$1d,$20,$0d,$01,$01,$01
	.byte		$00,$00,$00,$12,$1b,$09,$01,$19,$10,$01,$19,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$01,$01
	.byte		$00,$00,$00,$01,$01,$0b,$0d,$01,$01,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$1b
	.byte		$00,$00,$00,$01,$01,$09,$01,$01,$09,$0f,$01,$15,$07,$01,$01,$07,$01,$09,$01,$1c,$01,$00,$00,$00
	.byte		$00,$00,$00,$01,$08,$01,$01,$18,$01,$01,$18,$01,$01,$06,$00,$01,$06,$01,$01,$15,$01,$00,$00,$00
	.byte		$00,$00,$00,$01,$0a,$01,$01,$01,$19,$01,$19,$01,$01,$0c,$01,$01,$0a,$01,$01,$1d,$01,$00,$00,$03
	.byte		$11,$13,$1a,$01,$01,$0b,$01,$05,$09,$01,$00,$01,$0d,$01,$0b,$0d,$01,$0b,$01,$14,$01,$18,$11,$01

map = $2400

shooterframe:
	.byte		0
shooteranimation:
	.byte		$5a,$4e,$46,$42,$62,$72

waterframe:
	.byte		0
wateranimation:
	.byte		%11101110,%11001100,%01101111,%11001111,%11101110,%11010011,%11101011,%11001100

flagframe:
	.byte		0
flaganimation:
	.byte		$1e,$de, $1e,$dc, $1c,$dc, $1c,$de
