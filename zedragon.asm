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

    call    INIT_STC

    xor     a
    ld      (titlecredidx),a
    ld      (FRAMES),a
    call    updatecredits

    ld      hl,GO_PLAYER
    inc     (hl)

    ld      hl,attractmain
    call    mainproc

    ld      hl,GO_PLAYER
    dec     (hl)
    call    MUTE_AY

    ; --------------------- game
    call    cls
    call    resetscroll
    call    resetscore
    call    resetair
    call    drawmap

    ld      hl,sfx
    call    INIT_AFX
    ld      hl,GO_PLAYER
    set     1,(hl)

    ld      hl,gamemain
    call    mainproc

    ld      hl,GO_PLAYER
    res     1,(hl)
    call    MUTE_AY

    jr      {-}


attractmain:
    ;;;call    displaylastk
    ld      a,(FRAMES)
    cp      1
    jr      nz,{+}

    call    updatecredits

+:  ld      a,(fire)
    cp      1
    ret

updatecredits:
    ld      a,(titlecredidx)
    add     a,32
    ld      (titlecredidx),a

    ld      hl,titlecreds
    add     a,l
    ld      l,a
    adc     a,h
    sub     l
    ld      h,a

    ld      de,BOTTOM_LINE
    ld      bc,32
    ldir
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
