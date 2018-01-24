    .emptyfill  0
    .org        $4009

;    .inclabels  "datawad.bin.lbl"

#include "datawad.bin.inc"

#include "include/sysvars.asm"
#include "include/zxline0.asm"

BUFFER_WIDTH    .equ 600
NUMBER_OF_ROWS  .equ 10

.define ADD_DE_A add a,e \ ld e,a \ adc a,d \ sub e \ ld d,a
.define ADD_HL_A add a,l \ ld l,a \ adc a,h \ sub l \ ld h,a

    .exportmode NO$GMB          ; xxxx:yyyy NAME
    .export


D_BUFFER = $

charsetx:    .incbin "charset.binlz"
charsetxsz  = $ - charsetx

    .align  256
datax:      .incbin "datawad.bin"

    .align  64
considertablex:
    .word   considerstal, stalfall
    .word   considermine, minearise
    .word   considernever, 0                         ; never consider static mines
    .word   considerifeffective, depthchargeGenerator
    .word   considerifeffective, shootemup
    .word   considerifeffective, laseremup
    .word   consideralways, bosskey
    .word   consideralways, boss

inputstatesx:
    .byte   $1d,$de,$fa,0                     ; INUTDATA tag = defa(ult)
    .byte	%10000000,2,%00000001,0        ; up      (Q)
    .byte	%01000000,1,%00000001,0        ; down    (A)
    .byte	%00100000,7,%00001000,0        ; left    (N)
    .byte	%00010000,7,%00000100,0        ; right   (M)
    .byte	%00001000,7,%00000001,0        ; fire    (SP)
    .byte	%11111111,3,%00000001,0        ; advance (1)
    .byte	%11111111,4,%00000001,0        ; feature (0)
    .byte	%11111111,5,%00000001,0        ; pause   (P)
inputstatesxsz = $ - inputstatesx

    .fill 6000-($-D_BUFFER)
    RET

TOP_LINE:
	.fill 32,0
	RET

	.align	32	; to assist in air display calculations
BOTTOM_LINE:
	.fill 32,0
	RET

;#include "readisplay.asm"
#include "trolldisplay.asm"
#include "vsynctask.asm"
#include "yield.asm"

; ------------------------------------------------------------
starthere:
    out     ($fd),a

    call    initmovedata

    call    detectzxp
    call    z,enablezxpandfeatures

    call    initostore
    call    initcharset

    call	cls
    call    setupdisplay

	out     ($fe),a

	; create the head of the linked object list: the 'main' object.
	; this waits for vsync, then proceeds along to the next object in the chain,
	; eventually returning to itself ad nauseum
	;
	; the head object is a special case - it can't be inserted into the chain -
	; we must set up the next pointer manually
	;
	call	getobject
	ld		bc,fnmain
	call	initobject
	ld		hl,OSTORE
	ld		(OSTORE+ONEXT),hl
	ld		(OSTORE+OPREV),hl

    ; seed the whole shebanga with the attract mode process
    ;
    ld      bc,attract
    call    objectafterhead

    xor     a
    ld      (ocount),a

    ; here's the main loop, the root

fnmain:
    call    readinput
    ld      a,(pauseposs)
    ld      b,a
    ld      a,(pause)
    and     b
    cp      1
    call    z,_pause

    ld      hl,(scrollpos)
    ld      de,D_BUFFER
    add     hl,de
    ld      (MapStart),hl
    ld      a,(finescroll)
    ld      (ScrollXFine),a
    call    waitvsync

    call    updatescreen

    ; copy sub into charset
    ld      hl,charcache
    ld      de,$2380
    ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi       ; 2380-238f
    ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi 
    ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi       ; 2390-239f
    ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi 
    ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi       ; 23a0-23af
    ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi 

    ld      hl,bchar
    ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi       ; 23b0-23bf
    ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi \ ldi 

    YIELD

    jp      fnmain


_pause:
    ld      hl,BOTTOM_LINE
    push    hl
    ld      de,PRTBUF
    ld      bc,32
    ldir
    ld      hl,pausedtext
    pop     de
    ld      bc,32
    ldir

_ploop:
    call    waitvsync
    call    readinput
    ld      a,(pause)
    cp      1
    jr      nz,_ploop

    ld      hl,PRTBUF
    ld      de,BOTTOM_LINE
    ld      bc,32
    ldir

    ret


#include "ostore.asm"
#include "input.asm"
#include "attract.asm"
#include "gamemain.asm"
#include "fx.asm"
#include "sub.asm"
#include "bullets.asm"
#include "enemies.asm"
#include "airfns.asm"
#include "scorefns.asm"
#include "datafns.asm"
#include "displayfns.asm"
#include "teletyper.asm"
#include "soundfns.asm"
#include "mapfns.asm"
#include "stcplay.asm"
#include "ayfxplay.asm"
#include "zxpand.asm"
#include "decrunch.asm"
#include "data.asm"

endhere:
; ------------------------------------------------------------

#include "include/zxline1.asm"

    .end
