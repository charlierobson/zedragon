    .emptyfill  0
    .org        $4009

#include "include/sysvars.asm"
#include "include/zxline0.asm"

; ------------------------------------------------------------

#include "readisplay.asm"

starthere:
    ; one off initialisations

    call    golow
    call    inittables
    call    initmap
    call    setupudg
    call    setupdisplay

-:  ; --------------------- title screen
    call    cls
    call    drawtitle
    ;ld      hl,slkmain
    call    resetcredits
    call    enabletitlesound
    ld      hl,attractmain
    call    mainproc
    call    silencesound

    ; --------------------- game
    call    initsub
    call    cls
    call    resetscroll
    call    refreshmap
    call    drawmap
    call    resetscore
    call    resetair
    call    enablegamesound
    ld      hl,gamemain
    call    mainproc

    call    silencesound

    jr      {-}


attractmain:
    call    displaylastk

    ld      a,(FRAMES)
    and     127
    cp      1
    call    z,updatecredits

    ld      a,(fire)
    cp      1
    ret


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

    ld      a,(frames)
    and     127
    jr      nz,{+}

    ld      a,0
    call    AFXPLAY

+:  call    0                   ; call the active process - it returns with z set when complete
    jr      nz,{-}

    ret


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
