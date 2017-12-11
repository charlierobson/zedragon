    .emptyfill  0
    .org        $4009

#include "include/sysvars.asm"
#include "include/zxline0.asm"

.define ADD_DE_A add a,e \ ld e,a \ adc a,d \ sub e \ ld d,a
.define ADD_HL_A add a,l \ ld l,a \ adc a,h \ sub l \ ld h,a

    .exportmode NO$GMB          ; xxxx:yyyy NAME
    .export

D_BUFFER = $

UDG         = $2000
PUREMAP     = $2600
OSTORE      = $2e00
enemydat    = $3600
subpix      = $3700
enemyidx    = $37c0
titlescreen = $3a18
mul600tab   = $3c00
txtres      = $3c14
ttfont      = $3d34
;0x14bL (331) bytes remaining

FREELIST    = $8000
D_MIRROR    = $808a
CHARSETS    = $9800
DRAWLIST_0  = $9c00
DRAWLIST_1  = $9e00

maplz:       .incbin "map.binlz"
maplzsz  =    $-maplz

charsetx:    .incbin "charset.binlz"
charsetxsz  = $ - charsetx

enemydatx:   .incbin "enemydat.bin"
enemydatxsz = $ - enemydatx

enemyidxx:   .incbin "enemyidx.bin"
enemyidxxsz = $ - enemyidxx

pssubs:      .incbin "prescrolledsubs.bin"
pssubssz    = $ - pssubs

tsx:         .incbin  "titlescrn.binlz"
tsxsz:      = $ - tsx

txtresx:     .incbin "txtres.bin"
txtresxsz:     = $ - txtresx

hercfontx:   .incbin "hercules.binlz"
hercfontxsz:   = $ - hercfontx

m600tabx:    .word   0,600,1200,1800,2400,3000,3600,4200,4800,5400
m600tabxsz =  $ - m600tabx

    ; here lies D_BUFFER
    .fill 6000-($-D_BUFFER)
    RET

TOP_LINE:
	.fill 32,0
	RET

	.align	32	; to assist in air display calculations
BOTTOM_LINE:
	.fill 32,0
	RET

#include "readisplay.asm"
#include "yield.asm"

; ------------------------------------------------------------
starthere:
    out     ($fd),a

    call    detectzxp
    call    z,enablezxpandfeatures

    call    initmap
    call    initmovedata
    call    initostore
    call    initcharset

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
    call    getobject
    ld      bc,attract
    call    initobject
	call	insertobject_afterhead

    xor     a
    ld      (ocount),a

    ; here's the main loop, the root

fnmain:
    call    animatecharacters
    call    readinput

    ld      hl,(scrollpos)
    ld      (BUFF_OFFSET),hl
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


#include "ostore.asm"
#include "input.asm"
#include "attract.asm"
#include "gamemain.asm"
#include "testmain.asm"
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
