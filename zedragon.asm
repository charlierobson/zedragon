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
    call    initjoy

-:  ; --------------------- title screen
    call    cls
    call    drawtitle
    call    resetcredits
    call    enabletitlesound
    ld      hl,attractmain
    call    mainproc
    call    silencesound

    ; --------------------- game
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


attractmain:
    ;;;;call    displaylastk
    ld      a,(FRAMES)
    cp      1
    jr      nz,{+}

    call    updatecredits

+:  ld      a,(fire)
    cp      1
    ret


gamemain:
    call    scroll
    call    updateair

    ld      a,(frames)
    and     127
    cp      35
    jr      nz,{+}

    ld      a,(sfxnum)
    inc     a
    and     3
    ld      (sfxnum),a
    call    AFXPLAY

+:  ld      a,(fire)
    cp      1
    ret

;tempora
sfxnum: .byte -0


mainproc:
    ld      ({+}+1),hl

-:  call    waitvsync
    call    animatecharacters
    call    readjoy

+:  call    0                   ; call the active process - it returns with z set when complete
    jr      nz,{-}

    ret



#include "input.asm"

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
#include "charset.asm"

endshere:
; ------------------------------------------------------------

#include "include/zxline1.asm"

    .end
