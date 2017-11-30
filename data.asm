    CH_DEPTHBASE    = $34
    CH_MINEBASE     = $80
    CH_MINE         = $87
    CH_STALACBASE   = $88
    CH_SHOOTBASE    = $90
    CH_CHAIN        = $96
    CH_LASER        = $97
    CH_EXPLODEBASE  = $a0
    CH_BULLET       = $ae
    CH_WATER        = $af

    .asciimap ' ', '_', {*}-' '

scoreline:
	.asc    "SCORE:00000  HI:00000  Z:0  ^_:4"
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
; joystick bit, or $ff/%11111111 for no joy
; key row offset 0-7,
; key mask, or $ff/%11111111 for no key
; trigger impulse

inputstates:
    .byte	%10000000,2,%00000001,0        ; up      (Q)
    .byte	%01000000,1,%00000001,0        ; down    (A)
    .byte	%00100000,7,%00001000,0        ; left    (N)
    .byte	%00010000,7,%00000100,0        ; right   (M)
    .byte	%00001000,7,%00000001,0        ; fire    (SP)
    .byte	%11111111,3,%00000001,0        ; advance (1)
    .byte	%11111111,4,%00000001,0        ; feature (0)

; calculate actual input impulse addresses
up      = inputstates + 3
down    = inputstates + 7
left    = inputstates + 11
right   = inputstates + 15
fire    = inputstates + 19
advance = inputstates + 23
feature = inputstates + 27

scrolltick:
	.byte	0
scrollpos:
    .word   0
scrollflags:
    .byte   0

gameframe:
    .word   0

collision:
    .byte   0

bulletHitX:
    .word   0
bulletHitY:
    .byte   0

    .align  8
obdata:
    .byte   %11111111
    .byte   %01111111
    .byte   %00111111
    .byte   %00011111
    .byte   %00001111
    .byte   %00000111
    .byte   %00000011
    .byte   %00000001

bulletCount:
    .byte   0

ocount:
    .byte   0

airupdatecounter:
    .byte   0
airlevel:
    .byte   0


zone:
    .byte   0

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

    .align 256

; this needs to be wholly within a 256 byte page too
;
mul600tab:
    .word   0,600,1200,1800,2400,3000,3600,4200,4800,5400
; MOVE THIS TO $8000