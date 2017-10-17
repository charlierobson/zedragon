    .asciimap ' ', '_', {*}-' '

CH_CHAIN = $32
CH_EXPLODEBASE = $39

scoreline:
	.asc    "SCORE: 000000  HI: 000000  ^_: 4"
        	;--------========--------========

airline:
	.asc    "AIR: -------------------------- "
    		;--------========--------========

titlecredidx:
    .byte   0
titlecreds:
    ;        --------========--------========
    .asc    "     PROGRAMMING: SIRMORRIS     "
    .asc    "CUSTOM DISPLAY ROUTINE: ANDY REA"
    .asc    " TITLE TUNE: REAR ADMIRAL MOGGY "
    .asc    "   STC MUSIC PLAYER: ANDY REA   "
    .asc    "   AYFX DRIVER:  ALEX SEMENOV   "
    .asc    "ORIGINAL CODE/GFX:  RUSS WETMORE"
    .asc    "      P R E S S    F I R E      "


;;	.asciimap 'A','Z', {*}-'A'+$26
;;	.asciimap '0','9', {*}-'0'+$1c
;;	.asciimap '.', $1b
;;	.asciimap ';', $19


;titletune:
;	.incbin	"title.stc"

sfx:
	.incbin	"zedragon.afb"

LAST_J:
	.byte	0

; btb = bit test byte = 2nd byte of bit N,a instruction
btb0 = %01000111
btb1 = %01001111
btb2 = %01010111
btb3 = %01011111
btb4 = %01100111
btb5 = %01101111
btb6 = %01110111
btb7 = %01111111

; -----  4  3  2  1  0
;                       
; $FE -  V, C, X, Z, SH   0
; $FD -  G, F, D, S, A    1
; $FB -  T, R, E, W, Q    2
; $F7 -  5, 4, 3, 2, 1    3
; $EF -  6, 7, 8, 9, 0    4
; $DF -  Y, U, I, O, P    5
; $BF -  H, J, K, L, NL   6
; $7F -  B, N, M, ., SP   7
;
; joystick bit test opcode fragment,
; key row offset 0-7,
; key mask,
; input impulse

inputstates:
    .byte	btb7,2,%00000001,0        ; up      (Q)
    .byte	btb6,1,%00000001,0        ; down    (A)
    .byte	btb5,7,%00001000,0        ; left    (N)
    .byte	btb4,7,%00000100,0        ; right   (M)
    .byte	btb3,7,%00000001,0        ; fire    (SP)
    .byte	btb0,3,%00000001,0        ; advance (1)
    .byte	btb0,0,$00000101,0        ; quit    (SH-X)

; calculate actual input impulse addresses
up    = inputstates + 3
down  = inputstates + 7
left  = inputstates + 11
right = inputstates + 15
fire  = inputstates + 19
advance = inputstates + 23
quit  = inputstates + 27

scrolltick:
	.byte	0
scrollpos:
    .word   0

gameframe:
    .word   0

subx:
    .byte   0
suby:
    .byte   0
subaddress:
    .word   0
oldsubaddress:
    .word   0
bgchardata:
	.byte	0,0,0,0,0,0
basecharptr:
    .word   0

minebase:
    .word   0

mul600:
    .word   0,600,1200,1800,2400,3000,3600,4200,4800,5400

collision:
    .byte   0
subrowoff:
    .byte   0
subcoloff:
    .byte   0

airupdatecounter:
    .byte   0
airlevel:
    .byte   0

titlescreen:
	.byte		$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$1e,$1f,$bf,$0a,$11,$01,$01,$01,$01
	.byte		$00,$00,$00,$07,$01,$01,$07,$01,$09,$0f,$01,$15,$00,$00,$00,$00,$00,$00,$0f,$01,$01,$01,$01,$01
	.byte		$00,$00,$00,$01,$1a,$00,$01,$18,$01,$01,$18,$01,$00,$00,$00,$00,$00,$00,$1d,$30,$0d,$01,$01,$01
	.byte		$00,$00,$00,$12,$1b,$09,$01,$19,$10,$01,$19,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$01,$01
	.byte		$00,$00,$00,$01,$01,$0b,$0d,$01,$01,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$1b
	.byte		$00,$00,$00,$01,$01,$09,$01,$01,$09,$0f,$01,$15,$07,$01,$01,$07,$01,$09,$01,$1c,$01,$00,$00,$00
	.byte		$00,$00,$00,$01,$08,$01,$01,$18,$01,$01,$18,$01,$01,$06,$00,$01,$06,$01,$01,$15,$01,$00,$00,$00
	.byte		$00,$00,$00,$01,$0a,$01,$01,$01,$19,$01,$19,$01,$01,$0c,$01,$01,$0a,$01,$01,$1d,$01,$00,$00,$03
	.byte		$11,$13,$1a,$01,$01,$0b,$01,$05,$09,$01,$00,$01,$0d,$01,$0b,$0d,$01,$0b,$01,$14,$01,$18,$11,$01

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

    .align 512
charsets:
    .incbin "charset.bin"

