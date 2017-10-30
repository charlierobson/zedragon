    .emptyfill  0
    .org        $4009

#include "include/sysvars.asm"
#include "include/zxline0.asm"

    .exportmode NO$GMB          ; xxxx:yyyy NAME
    .export

#include "readisplay.asm"
#include "yield.asm"

; ------------------------------------------------------------
starthere:
	out		($fd),a

    call    golow
	call	initostore
    call    inittables
    call    initmap

    call    setupudg
    call    setupdisplay

	out		($fe),a

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

    ; here's the main loop, the root

fnmain:
    call    animatecharacters
    call    readinput

    ld      hl,(scrollpos)
    ld      (BUFF_OFFSET),hl
    call    waitvsync

    YIELD

    jr      fnmain


#include "attract.asm"
#include "gamemain.asm"
#include "fx.asm"

#include "ostore.asm"
#include "input.asm"
#include "sub.asm"
#include "bullets.asm"
#include "enemies.asm"
#include "airfns.asm"
#include "scorefns.asm"
#include "datafns.asm"
#include "displayfns.asm"
#include "soundfns.asm"
#include "mapfns.asm"
#include "stcplay.asm"
#include "ayfxplay.asm"
#include "zxpand.asm"

#include "data.asm"

endhere:
; ------------------------------------------------------------

#include "include/zxline1.asm"

    .end
