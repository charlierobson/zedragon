    CH_DEPTHBASE    = $34
    CH_BOSSKEY      = $3F
    CH_MINEBASE     = $80
    CH_MINE         = $87
    CH_MINEBLANK    = $86
    CH_STALACBASE   = $88
    CH_SHOOTBASE    = $90
    CH_CHAIN        = $96
    CH_LASER        = $97
    CH_EXPLODEBASE  = $a0
    CH_BULLET       = $ae
    CH_WATER        = $af

titlecredidx:
    .byte   0

titletunelz:
    .incbin	"title.stclz"

sfx:
    .incbin	"zedragon.afb"

scrolltick:
	.byte	0
scrollpos:
    .word   0
finescroll:
    .byte   0
scrollflags:
    .byte   0

zxpandenabled:
    .byte   0

gameframe:
    .word   0

pauseposs:
    .byte   0

collision:
    .byte   0

gamemode:
    .byte   1           ; 0 = explorer, 1 = normal

subcharx:
    .word   0

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
ocountmax:
    .byte   0

airupdatecounter:
    .byte   0
airlevel:
    .byte   0

lives:
    .byte   0
score:
    .word   0
zone:
    .byte   0
bonus:
    .byte   0


; --- ordering here is for eeprom persistence, don't alter
hiscore:
    .word   $0175
maxzone:
    .byte   0       ; maximum zone the player is allowed to skip to
; --- ordering here is for eeprom persistence, don't alter


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
