    .emptyfill  0
    .org        $4009

#include "include/sysvars.asm"
#include "include/zxline0.asm"

; ------------------------------------------------------------
starthere:
    ; one off initialisations

    call    golow
    call    initmap
    call    setupudg
    call    setupdisplay
    call    initjoy

-:  ; title screen
    call    cls
    call    drawtitle
    call    INIT_STC
    ld      hl,GO_PLAYER
    inc     (hl)
    ld      hl,attractmain
    call    mainproc
    ld      hl,GO_PLAYER
    dec     (hl)
    call    MUTE_STC

    ; game
    call    cls
    call    drawmap
    call    resetscore
    call    resetair
    call    resetscroll
    ld      hl,sfx
    call    INIT_AFX
    ld      hl,GO_PLAYER
    set     1,(hl)
    ld      hl,gamemain
    call    mainproc
    ld      hl,GO_PLAYER
    res     1,(hl)
    ld      hl,sfx
    call    INIT_AFX

    jr      {-}


attractmain:
    ld      a,(fire)
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

sfxnum: .byte -0

mainproc:
    ld      (pj+1),hl

-:  call    waitvsync
    call    animatecharacters
    call    readjoy
pj: call    0                   ; call the active process - it returns with z set when complete
    jr      nz,{-}

    ret



#include "readisplay.asm"
#include "input.asm"

#include "airfns.asm"
#include "scorefns.asm"
#include "displayfns.asm"
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
