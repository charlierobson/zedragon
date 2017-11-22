    .module FX

SFX_EXPLODE = 8-1

explosion:
    ld      a,(FRAMES)
    and     3
    add     a,SFX_EXPLODE
    call    AFXPLAY

    xor     a

-:  ld      (iy+OUSER+2),a
    ld      l,(iy+OUSER)
    ld      h,(iy+OUSER+1)

    sra     a
    sra     a
    add     a,CH_EXPLODEBASE
    ld      (hl),a

    YIELD

becomeexplosion:
    ld      a,(iy+OUSER+2)
    inc     a
    cp      28
    jr      nz,{-}

    ld      l,(iy+OUSER)        ; clear explosion from the screen
    ld      h,(iy+OUSER+1)
    push    hl
    set     7,h                 ; look into the mirror map to get replacement char
    res     6,h
    ld      a,(hl)
    pop     hl
    ld      (hl),a

    DIE




chaindrop:
    ld      (iy+OUSER+3),7

_chainloop:
    YIELD
    dec     (iy+OUSER+3)
    jr      nz,_chainloop

    ld      (iy+OUSER+3),7

    ld      e,(iy+OUSER)
    ld      d,(iy+OUSER+1)
    ld      hl,600
    add     hl,de
    set     7,h
    res     6,h
    ld      a,(hl)
    cp      CH_CHAIN
    jr      z,{+}

    DIE

+:  ld      (hl),0
    res     7,h
    set     6,h
    ld      (hl),0
    ld      (iy+OUSER),l
    ld      (iy+OUSER+1),h
    jr      _chainloop
