    CH_CHAIN = $32
    CH_EXPLODEBASE = $39
    CH_STALAC = $27
    CH_MINE = $2F
    CH_BULLET = $be

    .asciimap ' ', '_', {*}-' '

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


titletune:
	.incbin	"title.stc"

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
up      = inputstates + 3
down    = inputstates + 7
left    = inputstates + 11
right   = inputstates + 15
fire    = inputstates + 19
advance = inputstates + 23
quit    = inputstates + 27

scrolltick:
	.byte	0
scrollpos:
    .word   0
scrollflags:
    .byte   0

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

lives:
    .byte   0

minebase:
    .word   0

collision:
    .byte   0
subrowoff:
    .byte   0
subcoloff:
    .byte   0
bulletX:
    .word   0
bulletHitX:
    .word   0

ocount:
    .byte   0

airupdatecounter:
    .byte   0
airlevel:
    .byte   0


restartPoint:
    .word   0

    ; Restart scroll and sub positions
dofs:
    .word   $0000
	.byte	0,6

    .word   $004a
	.byte	72,6

    .word   $00aa
	.byte	64,16

    .word   $010b
	.byte	72,16

    .word   $0181
	.byte	56,6

    .word   $01dd
	.byte	56,8

    .word   $021a
	.byte	80,6

    .word   $ffff


titlescreen:
    .incbin  "titlescrn.binlz"

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

ENEMYIDX:
    .incbin "enemyidx.bin"

    .align  256

; needs to start on a 256 byte page boundary and be contained wholly within it
;
ENEMYTBL:
    .incbin "enemytbl.bin"
NUMENEMY = $-ENEMYTBL

; this needs to be wholly within a 256 byte page too
;
mul600tab:
    .word   0,600,1200,1800,2400,3000,3600,4200,4800,5400
