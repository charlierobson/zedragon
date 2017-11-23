    .module FX

_SCRPOS = OUSER
_SCRADDL = OUSER
_SCRADDH = OUSER+1
_COUNTER = OUSER+2

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
; explosion
;

SFX_EXPLODE = 7

explosion:
    ld      a,(FRAMES)
    and     3
    add     a,SFX_EXPLODE
    call    AFXPLAY

    xor     a

_exploop:
    ld      (iy+_COUNTER),a
    ld      l,(iy+_SCRADDL)
    ld      h,(iy+_SCRADDH)

    sra     a
    sra     a
    add     a,CH_EXPLODEBASE
    ld      (hl),a

    YIELD

becomeexplosion:                ; entry point for objects wishing to become explosions
    ld      a,(iy+_COUNTER)
    inc     a
    cp      28
    jr      nz,_exploop

    ld      l,(iy+_SCRADDL)     ; clear explosion from the screen
    ld      h,(iy+_SCRADDH)
    push    hl

    set     7,h                 ; look into the mirror map to get replacement char
    res     6,h
    ld      a,(hl)

    pop     hl
    ld      (hl),a              ; remove from display

    DIE


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
; chain dropper
;

chaindrop:
    set     7,(iy+_SCRADDH)
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

    ld      (hl),0              ; remove from mirror
    ld      (iy+OUSER),l
    ld      (iy+OUSER+1),h

    res     7,h
    set     6,h
    ld      (hl),0              ; remove from display
    jr      _loop
