    .emptyfill  0
    .org        $4009

#include "include/sysvars.asm"
#include "include/zxline0.asm"

; ------------------------------------------------------------

#include "readisplay.asm"

starthere:
    ; one off initialisations

    call    golow
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
    call    drawmap
    call    resetscore
    call    resetair
    call    enablegamesound
    ld      hl,gamemain
    call    mainproc

    call    silencesound

    jr      {-}


slkmain:
    call    displaylastk
    xor     a
    cp      1
    ret


attractmain:
    ld      a,(FRAMES)
    and     127
    cp      1
    jr      nz,{+}

    call    updatecredits

    ld      a,(fire)
    cp      1
    ret


gamemain:
    call    scroll
    call    updateair
    call    movesub
    call    drawsub

+:  ld      a,(fire)
    cp      1
    ret



mainproc:
    ld      ({+}+1),hl

-:  call    waitvsync
    call    animatecharacters
    call    readjoy

+:  call    0                   ; call the active process - it returns with z set when complete
    jr      nz,{-}

    ret

#include "input.asm"
#include "sub.asm"
#include "airfns.asm"
#include "scorefns.asm"
#include "displayfns.asm"
#include "soundfns.asm"
#include "mapfns.asm"
#include "stcplay.asm"
#include "ayfxplay.asm"
#include "zxpand.asm"

#include "data.asm"

    .align 512
charsets:
    .incbin "charset.bin"

endshere:
; ------------------------------------------------------------

#include "include/zxline1.asm"

    .end
