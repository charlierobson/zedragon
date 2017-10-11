    .emptyfill  0
    .org        $4009

#include "include/sysvars.asm"
#include "include/zxline0.asm"

    .exportmode NO$GMB          ; xxxx:yyyy NAME
    .export

; ------------------------------------------------------------

#include "readisplay.asm"
#include "yield.asm"

starthere:
	out		($fd),a				; disable NMIs

    call    golow

	call	initostore

    call    inittables
    call    initmap

    call    setupudg
    call    setupdisplay

	; create the head of the linked object list: the 'main' object.
	; this waits for vsync, then proceeds along to the next object in the chain,
	; eventually returning to itself ad nauseum
	;
	; the head object is a special case - it can't be inserted into the chain -
	; we must set up the next pointer manually
	;
	call	getobject
	ld		bc,_fnmain
	call	initobject
	ld		hl,OSTORE
	ld		(OSTORE+ONEXT),hl
	ld		(OSTORE+OPREV),hl

	out		($fe),a             ; enable NMIs

    call    getobject
    ld      bc,_attract
    call    initobject

; -:  ; --------------------- title screen
;     call    cls
;     call    drawtitle
;     ;ld      hl,slkmain
;     call    resetcredits
;     call    enabletitlesound
;     ld      hl,attractmain
;     call    mainproc
;     call    silencesound

;     ; --------------------- game
;     call    initsub
;     call    cls
;     call    resetscroll
;     call    refreshmap
;     call    drawmap
;     call    resetscore
;     call    resetair
;     call    enablegamesound
;     ld      hl,gamemain
;     call    mainproc

;     call    silencesound

;     jr      {-}


_fnmain
    call    waitvsync
    call    animatecharacters
    call    readjoy
    YIELD
    jr      _fnmain



_attract:
    call    cls
    call    drawtitle
    call    resetcredits
    call    enabletitlesound

attractloop:
-:  ld      a,(FRAMES)
    and     127
    call    z,updatecredits

    YIELD

    ld      a,(fire)
    cp      1
    jr      nz,{-}





gamemain:
    ld      a,(advance)
    cp      1
    ;ret     nz

    call    scroll
    call    updateair

    call    movesub

    call    showsubcoords

    call    drawsub
    call    updatebullets

    ld      a,(fire)
    cp      3
    call    z,startbullet

    ld      a,(quit)
    cp      3
    ret



mainproc:
    ld      ({+}+1),hl

-:  call    waitvsync
    call    animatecharacters
    call    readjoy

    ld      a,(FRAMES)
    and     127
    jr      nz,{+}

    ld      a,0
    call    AFXPLAY

+:  call    0                   ; call the active process - it returns with z set when complete
    jr      nz,{-}

    ret


#include "ostore.asm"
#include "input.asm"
#include "sub.asm"
#include "bullets.asm"
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

endshere:
; ------------------------------------------------------------

#include "include/zxline1.asm"

    .end
