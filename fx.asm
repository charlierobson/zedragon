    .module FX

_SCRPOS = OUSER
_SCRADDL = OUSER
_SCRADDH = OUSER+1
_COUNTER = OUSER+2

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
; explosion
;

explosound:
    ld      a,(FRAMES)
    and     3
    add     a,SFX_EXPLODE0
    jp      AFXPLAY


explosion:
    call    explosound
    xor     a

_exploop:
    ld      (iy+_COUNTER),a
    ld      l,(iy+_SCRADDL)
    ld      h,(iy+_SCRADDH)

    sra     a
    sra     a
    add     a,CH_EXPLODEBASE
    call    char2dlist

    YIELD

becomeexplosion:                ; entry point for objects wishing to become explosions
    ld      a,(iy+_COUNTER)
    inc     a
    cp      28
    jr      nz,_exploop

    DIE


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
; chain dropper
;

chaindrop:
    set     7,(iy+_SCRADDH)     ; work in mirror domain
    res     6,(iy+_SCRADDH)

_loop:
    ld      (iy+_COUNTER),7

_wait:
    YIELD
    dec     (iy+_COUNTER)
    jr      nz,_wait

    ld      l,(iy+_SCRADDL)
    ld      h,(iy+_SCRADDH)
    ld      de,600
    add     hl,de
    ld      a,(hl)              ; chain in the mirror?
    cp      CH_CHAIN
    DIENZ

    xor     a                   ; also used in call to char2dlist

    ld      (hl),a              ; remove from mirror
    ld      (iy+OUSER),l
    ld      (iy+OUSER+1),h

    res     7,h
    set     6,h
    call    char2dlist
    jr      _loop
