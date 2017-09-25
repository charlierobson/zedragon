    .emptyfill  0
    .org        $4009

#include "include\sysvars.asm"
#include "include\zxline0.asm"

; ------------------------------------------------------------
starthere:
    ; one off initialisations
    call    initmap
    call    setupudg
    call    setupDisplay
    call    initjoy

-:  call    cls
    call    drawtitle
    ld      hl,attractmain
    call    mainproc

    call    cls
    call    drawmap
    call    resetscore
    call    resetair
    call    resetscroll
    ld      hl,gamemain
    call    mainproc

    jr      {-}


attractmain:
    ld      a,(fire)
    cp      1
    ret


gamemain:
    call    scroll
    call    updateair
    ld      a,(fire)
    cp      1
    ret



mainproc:
    ld      (pj+1),hl

--:
    ; wait for new frame
    ld      hl,FRAMES
    ld      a,(hl)
-:  cp      (hl)
    jr      z,{-}

    ; do the stuff we always do
    call    animateEnemies
    call    animateWater
    call    readjoy

    ; call the active process - it returns with z set when complete
pj: call    0
    jr      nz,{--}

    ; process has completed
    ret



#include "readisplay.asm"
#include "input.asm"

#include "airfns.asm"
#include "scorefns.asm"
#include "displayfns.asm"
#include "mapfns.asm"

#include "data.asm"

    .align 512
charsets:
#include "charset.asm"

endshere:
; ------------------------------------------------------------

#include "include\zxline1.asm"

    .end
