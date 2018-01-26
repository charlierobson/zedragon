    .exportmode Assembly
    .export

UDG = $2000
OSTORE = $2600

    .org    $2E00

    .align 256
enemydat:   .incbin "enemydat.bin"

    .align 256
subpix:     .incbin "prescrolledsubs.bin"

    .align 16
PUREMAP:    .incbin "map.binlz"

    .align 16
enemyidx:   .incbin "enemyidx.bin"

    .align 16
titlescrn:  .incbin  "titlescrn.binlz"

    .align 16
ttfont:     .incbin "hercules.binlz"

    .asciimap ' ', '_', {*}-' '

    .align 16
scoreline:
    .asc    "SCORE:00000  HI:00000  Z:1  ^_:4"
    ;        --------========--------========

    .align 16
airline:
    .asc    "AIR: -------------------------- "
    ;        --------========--------========

    .align 16
titlecreds
    ;        --------========--------========
    .asc    "  GAME PROGRAMMING: SIRMORRIS   "
    .asc    "DISPLAY ROUTINE: REA / KLOTBLIXT"
    .asc    " TITLE TUNE: REAR ADMIRER MOGGY "
    .asc    "   STC MUSIC PLAYER: ANDY REA   "
    .asc    "   AYFX DRIVER:  ALEX SEMENOV   "
    .asc    "MASSIVE THANKS TO:  RUSS WETMORE"
zxpdistxt:
    .asc    "        ZXPAND: DISABLED        "

    .align 16
pressfiretext:
    .asc    "      P R E S S    F I R E      "
    ;        --------========--------========

    .align 16
pausedtext:
    .asc    "             PAUSED             "
    ;        --------========--------========

    .asciimap 0, 255, {*}-'@'
    .asciimap ' ', ' ', 0
    .asciimap '.', '.', $1e
    .asciimap '!', '!', $3c

    .align 16
failedtext:
    .asc    "         MISSION FAILED}        "
    ;        --------========--------========

    .align 16
congrattext:
    ;        --------========--------========
    .asc    "    Congratulations Captain!~"
    .asc    "~"
    .asc    "The biggest threat to our planet~"
    .asc    "is defeated. We are safe again.~"
    .asc    "~"
    .asc    "You will receive the highest~"
    .asc    "honour our country can give...~"
    .asc    "~"
    .asc    "      ...ANOTHER MISSION!!~}"
    ;        --------========--------========

    .align 16
dofs:
    .word   $0000
	.byte	0,6

    .word   $004a
	.byte	72,6

    .word   $00b1
	.byte	40,6

    .word   $010b
	.byte	72,16

    .word   $0181
	.byte	56,6

    .word   $01d8
	.byte	56,8

    .word   $021a
	.byte	80,6

    .word   $ffff

    .align 16
mul600tab:  .word   0,600,1200,1800,2400,3000,3600,4200,4800,5400

    .align  64
considertable:

inputsid    = $8000
inputstates = $8004
FREELIST    = $8030
D_MIRROR    = $808a
CHARSETS    = $9800
DRAWLIST_0  = $9c00
DRAWLIST_1  = $9e00