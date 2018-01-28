;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module SHOOTER 
;

SHOOTPERIOD = 3
SHOOTITERS = 10

OLEN = 5
CLEN = 6
DLAY = 7
ITERS = 8
FFLOP = 9
;10/11
COLL = 12

shootemup:
    ld      l,(iy+OUSER)        ; x
    ld      h,(iy+OUSER+1)
    ld      a,(iy+OUSER+2)      ; y
    call    mulby600
    add     hl,de
    ld      de,D_BUFFER+601
    add     hl,de
    ld      (iy+OUSER+3),l
    ld      (iy+OUSER+4),h

    ld      (iy+OUSER+OLEN),0              ; shooter length
    ld      (iy+OUSER+COLL),0             ; collision cache
    ld      (iy+OUSER+FFLOP),0

    ; search the shooter space to find the required length
    ld      de,601
    set     7,h
    res     6,h
    jr      {+}

-:  inc     (iy+OUSER+OLEN)        ; shooter length
    add     hl,de

+:  ld      a,(hl)
    and     a
    jr      z,{-}

    ; shooting on
_pewpew:
    ld      de,ontab
    ld      (iy+OUSER+10),e
    ld      (iy+OUSER+11),d
    ld      (iy+OUSER+ITERS),SHOOTITERS

_shoot_on_main:
    ld      a,SFX_SHOOTERSHOT
    call    z,AFXPLAY

    call    _shootahoopa
    inc     (iy+OUSER+FFLOP)

    ld      a,SFX_SHOOTERSHOT
    call    nz,AFXPLAY

    call    _shootahoopa
    dec     (iy+OUSER+FFLOP)

    call    nextframe

    dec     (iy+OUSER+ITERS)                ; number of positions in offtabs
    jr      nz,_shoot_on_main

    ; shooting off

    ld      de,offtab
    ld      (iy+OUSER+10),e
    ld      (iy+OUSER+11),d
    ld      (iy+OUSER+ITERS),SHOOTITERS

_shoot_off_main:
    call    _shootahoopa
    inc     (iy+OUSER+FFLOP)

    call    _shootahoopa
    dec     (iy+OUSER+FFLOP)

    call    nextframe

    dec     (iy+OUSER+ITERS)            ; number of positions in offtabs
    jr      nz,_shoot_off_main

    ; shoot sequence finished, wait a couple of seconds

    ld      (iy+OUSER+DLAY),50          ; delay counter

_soy2:
-:  YIELD

    ld      a,(collision)               ; die if sub died
    or      (iy+OUSER+COLL)
    DIENZ
    call    cIfIneffectiveHard
    DIEC
    call    cIfOffscreenLeft
    DIEC

    dec     (iy+OUSER+DLAY)
    jr      nz,{-}

    jp      _pewpew


nextframe:
    ld      e,(iy+OUSER+10)
    ld      d,(iy+OUSER+11)
    dec     de
    ld      (iy+OUSER+10),e
    ld      (iy+OUSER+11),d
    ret


_shootahoopa:
    pop     hl                      ; because we're a subroutine and we will YIELD,
    ld      (iy+OUSER+16),l         ; remove the return address and stash it locally
    ld      (iy+OUSER+17),h

    ld      (iy+OUSER+DLAY),SHOOTPERIOD

_shmain:
    ld      l,(iy+OUSER+3)          ; screen position
    ld      h,(iy+OUSER+4)
    ld      bc,601                  ; offset to next shot posn on screen

    ld      a,(iy+OUSER+OLEN)       ; shot stream length
    ld      (iy+OUSER+CLEN),a

    ld      e,(iy+OUSER+10)
    ld      d,(iy+OUSER+11)

_shrender:
    ld      a,(de)
    and     a
    jr      z,_skipadd

    add     a,(iy+OUSER+FFLOP)

_skipadd:
    call    char2dlist
    set     7,h
    res     6,h
    ld      (hl),a                  ; mirror, for sub killing
    res     7,h
    set     6,h
    inc     de
    add     hl,bc
    dec     (iy+OUSER+CLEN)
    jr      nz,_shrender

_soy1:
    YIELD
    dec     (iy+OUSER+DLAY)
    jr      nz,_shmain

    ld      a,(collision)           ; collision cache
    or      (iy+OUSER+COLL)
    ld      (iy+OUSER+COLL),a

    ld      l,(iy+OUSER+16)         ; recover return address,
    ld      h,(iy+OUSER+17)
    push    hl                      ; and return!
    ret


    .byte   CH_SHOOTBASE+2,CH_SHOOTBASE+2,CH_SHOOTBASE+2,CH_SHOOTBASE+2,CH_SHOOTBASE+2
    .byte   CH_SHOOTBASE+2,CH_SHOOTBASE+2,CH_SHOOTBASE+2,CH_SHOOTBASE+2,CH_SHOOTBASE+2
    .byte   CH_SHOOTBASE
ontab:
    .byte   0,0,0,0,0
    .byte   0,0,0,0,0

    .byte   0,0,0,0,0
    .byte   0,0,0,0,0
    .byte   CH_SHOOTBASE+4
offtab:
    .byte   CH_SHOOTBASE+2,CH_SHOOTBASE+2,CH_SHOOTBASE+2,CH_SHOOTBASE+2,CH_SHOOTBASE+2
    .byte   CH_SHOOTBASE+2,CH_SHOOTBASE+2,CH_SHOOTBASE+2,CH_SHOOTBASE+2,CH_SHOOTBASE+2
