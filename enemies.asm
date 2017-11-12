    .module ENEMIES

BIT_INACT    = 7      ; busy or dead

NME_STAL     = $00
NME_MINE     = $10
NME_STATMINE = $20
NME_DEPTH    = $30
NME_SHOOT    = $40
NME_LASER    = $50

    .align  32
_considertable:
    .word   considerstal, stalfall
    .word   considermine, minearise
    .word   considernull, 0     ; never consider static mines
    .word   considerdepth, depthchargeGenerator
    .word   considershooter, shootemup
    .word   considerlaser, laseremup


enemyinitiator:
    ld      de,(scrollpos)      ; find the first enemy on screen
    ld      hl,enemyidx
    add     hl,de
    ex      de,hl
    ld      b,32                ; and check up to 32 screen x positions from there

_search:
    ld      a,(de)              ; get enemy table index, or ff if no enemy at this x pos
    cp      $ff
    jr      z,_nope

    push    bc
    push    de

    ld      h,enemydat / 256    ; make pointer into enemy data table
    ld      l,a
    ld      a,(hl)              ; get enemy type
    bit     BIT_INACT,a
    call    z,_possibly

    pop     de
    pop     bc

_nope:
    inc     de
    djnz    _search

    ret


_possibly:
    and     $f0                 ; isolate type
    rrca
    rrca

    push    hl

    ld      hl,_considertable   ; index into consideration table
    or      l
    ld      l,a

    push    de
    ld      de,_considerator+1
    ldi
    ldi
    ld      de,_starterator+1
    ldi
    ldi
    pop     de

    pop     hl

_considerator:
    call    0
    ret     nc

_yep:
    set     BIT_INACT,(hl)              ; setting the inactive bit will change the enemy id
    ld      a,(hl)
    and     $0f                         ; isolate Y - also clears carry for SBC below
    push    af

    ld      hl,enemyidx                 ; calculate X
    ex      de,hl
    sbc     hl,de
    push    hl

_starterator:
    ld      bc,0

    call    getobject
    call    initobject
    call    insertobject_beforehead     ; exits with hl-> data area

    pop     de                          ; retrieve X
    ld      (hl),e
    inc     hl
    ld      (hl),d
    inc     hl
    pop     af                          ; retrieve Y
    ld      (hl),a

    ret


    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    ; consideration functions - return with carry set to go with
    ; this object.
    ;
considerdepth:          ; always starts
considershooter:
considerlaser:
    scf
considernull:           ; never starts
    ret

considermine:
    push    bc
    call    rng
    pop     bc
    cp      1
    ret                 ; return with C set to choose this enemy

considerstal:
    push    bc
    call    rng
    pop     bc
    cp      1
    ret


    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    ; Return with carry set if x is off screen left
    ;
cIfOffscreenLeft:
    ld      l,(iy+OUSER+0)
    ld      h,(iy+OUSER+1)
    ld      de,(scrollpos)
    and     a
    sbc     hl,de
    ret


    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    .module STALAC
    ;
stalfall:
    ld      a,5
    call    AFXPLAY

    ld      l,(iy+OUSER)        ; hl = x
    ld      h,(iy+OUSER+1)
    ld      a,(iy+OUSER+2)      ; = y
    inc     a

    ld      (iy+OUSER+3),a      ; keep X & Y around for various comparisons
    ld      (iy+OUSER+4),l
    ld      (iy+OUSER+5),h

    call    mulby600
    add     hl,de               ; hl = x + 600 * (y-1)
    ld      de,D_BUFFER
    add     hl,de

    xor     a

-:  ld      (iy+OUSER),l        ; screen pointer
    ld      (iy+OUSER+1),h
    ld      (iy+OUSER+2),a      ; counter
    ld      d,h
    ld      e,l
    set     7,d
    res     6,d

    and     %00000110
    add     a,CH_STALACBASE+1
    ld      (hl),a
    ld      (de),a
    dec     a
    ld      bc,600
    sbc     hl,bc
    ex      de,hl
    sbc     hl,bc
    ld      (hl),a
    ld      (de),a

    YIELD

    ld      l,(iy+OUSER+0)      ; restore screen pointers
    ld      h,(iy+OUSER+1)

    inc     (iy+OUSER+2)        ; only move when frame = 0
    ld      a,(iy+OUSER+2)
    and     7
    jr      nz,{-}

    ld      d,h
    ld      e,l
    set     7,d
    res     6,d

    ld      bc,600
    add     hl,bc

    ld      a,(hl)              ; are we about to hit some thing?
    and     a
    jr      z,{-}

    ; yep, done
    xor     a
    sbc     hl,bc
    ld      (hl),a              ; yep - undraw & stop
    ld      (de),a              ; yep - undraw & stop

    DIE




    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    .module MINE
    ;
minearise:
    ld      a,5
    call    AFXPLAY

    ld      l,(iy+OUSER)        ; hl = x
    ld      h,(iy+OUSER+1)
    ld      a,(iy+OUSER+2)      ; = y
    dec     a

    ld      (iy+OUSER+3),a      ; keep X & (adjusted) Y around for various comparisons
    ld      (iy+OUSER+4),l
    ld      (iy+OUSER+5),h

    call    mulby600
    add     hl,de               ; hl = x + 600 * (y-1)
    ld      de,D_BUFFER
    add     hl,de

    xor     a

-:  ld      (iy+OUSER),l        ; screen pointer
    ld      (iy+OUSER+1),h
    ld      (iy+OUSER+2),a      ; counter
    ld      d,h
    ld      e,l
    set     7,d
    res     6,d

    and     %00001100
    rrca
    add     a,CH_MINEBASE+1             ; start of mine sequence in char set
    ld      (hl),a
    ld      (de),a
    dec     a
    ld      bc,600
    add     hl,bc
    ex      de,hl
    add     hl,bc
    ld      (hl),a
    ld      (de),a

    YIELD

    ; is the bullet reporting a collision, and is it in our column?
    ld      hl,(bulletHitX)
    ld      a,l
    or      h
    jr      z,_scc              ; skip column check if no x position reported

    ld      e,(iy+OUSER+4)      ; column check
    ld      d,(iy+OUSER+5)
    and     a
    sbc     hl,de
    jr      z,_gobang

_scc:
    ld      l,(iy+OUSER+0)      ; restore screen pointer
    ld      h,(iy+OUSER+1)

    inc     (iy+OUSER+2)        ; only move mine up when frame = 0
    ld      a,(iy+OUSER+2)
    and     15
    jr      nz,{-}

    dec     (iy+OUSER+3)        ; explode when mine hits the top
    jr      z,_gobang

    ld      de,600              ; move mine up
    and     a
    sbc     hl,de

    ld      a,(hl)              ; are we about to hit some thing?
    and     a
    jr      z,{-}

    cp      $30                 ; some solid thing?
    jr      nc,{-}

    ; all done - become an explosion

_gobang:
    ld      l,(iy+OUSER)        ; remove characters from the screen
    ld      h,(iy+OUSER+1)
    ld      d,h
    ld      e,l
    set     7,d
    res     6,d
    xor     a
    ld      (hl),a
    ld      (de),a
    ld      bc,600
    add     hl,bc
    ex      de,hl
    add     hl,bc
    ld      (hl),a
    ld      (de),a

    ld      (iy+OUSER+2),a      ; swap to explosion coroutine
    jp      becomeexplosion


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
    call    _shootahoopa
    inc     (iy+OUSER+FFLOP)

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

    dec     (iy+OUSER+ITERS)                    ; number of positions in offtabs
    jr      nz,_shoot_off_main

    ; shoot sequence finished, wait a couple of seconds

    ld      (iy+OUSER+DLAY),50                 ; delay counter

_soy2:
-:  YIELD

    ld      a,(collision)                   ; die if sub died
    or      (iy+OUSER+COLL)
    DIENZ
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
    pop     hl
    ld      (iy+OUSER+16),l
    ld      (iy+OUSER+17),h

    ld      (iy+OUSER+DLAY),SHOOTPERIOD

_shmain:
    ld      l,(iy+OUSER+3)      ; screen position
    ld      h,(iy+OUSER+4)
    ld      bc,601              ; offset to next shot posn on screen

    ld      a,(iy+OUSER+OLEN)      ; shot stream length
    ld      (iy+OUSER+CLEN),a

    ld      e,(iy+OUSER+10)
    ld      d,(iy+OUSER+11)

_shrender:
    ld      a,(de)
    and     a
    jr      z,_skipadd

    add     a,(iy+OUSER+FFLOP)

_skipadd:
    ld      (hl),a
    set     7,h
    res     6,h
    ld      (hl),a
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

    ld      l,(iy+OUSER+16)
    ld      h,(iy+OUSER+17)
    push    hl
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


    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    .module DEPTH
    ;
depthchargeGenerator:
    YIELD
    inc     (iy+OUSER+5)
    ld      a,(iy+OUSER+5)
    and     31
    jr      nz,depthchargeGenerator

    ld      bc,depthcharge
    call    getobject
    call    initobject
    call    insertobject_afterthis

    ld      a,(iy+OUSER+0)
    ld      (hl),a
    inc     hl
    ld      a,(iy+OUSER+1)
    ld      (hl),a
    inc     hl
    ld      a,(iy+OUSER+2)
    ld      (hl),a

    ld      a,(collision)
    and     a
    jr      z,depthchargeGenerator

    DIE



; TODO - make x,y to screenpos function to share amongst objects
;        make function that creates & initialises object

depthcharge:
    ld      l,(iy+OUSER+0)      ; x
    ld      h,(iy+OUSER+1)
    inc     (iy+OUSER+2)
    ld      a,(iy+OUSER+2)
    sla     (iy+OUSER+2)
    sla     (iy+OUSER+2)
    sla     (iy+OUSER+2)
    call    mulby600
    add     hl,de
    ld      de,D_BUFFER
    add     hl,de

    ld      (iy+OUSER+5),0

_loop0:
    ld      (iy+OUSER+3),l      ; screen pos
    ld      (iy+OUSER+4),h

_loop1:
    ld      l,(iy+OUSER+3)
    ld      h,(iy+OUSER+4)    
    ld      (hl),CH_DEPTHBASE
    set     7,h
    res     6,h
    ld      (hl),CH_DEPTHBASE
    YIELD
    call    _hittest
    inc     (iy+OUSER+5)
    bit     3,(iy+OUSER+5)
    jr      z,_loop1

    ld      a,(iy+OUSER+2) 
    add     a,4
    ld      (iy+OUSER+2),a

_loop2:
    ld      l,(iy+OUSER+3)
    ld      h,(iy+OUSER+4)
    ld      (hl),CH_DEPTHBASE+1
    set     7,h
    res     6,h
    ld      (hl),CH_DEPTHBASE+1
    YIELD
    call    _hittest
    inc     (iy+OUSER+5)
    bit     3,(iy+OUSER+5)
    jr      nz,_loop2

    ld      a,(iy+OUSER+2)
    add     a,4
    ld      (iy+OUSER+2),a

    ld      l,(iy+OUSER+3)
    ld      h,(iy+OUSER+4)

    ld      (hl),0
    set     7,h
    res     6,h
    ld      (hl),0

    ld      bc,600
    add     hl,bc
    ld      a,(hl)
    res     7,h
    set     6,h
    or      a
    jp      z,_loop0

    DIE

_hittest:
    ld      de,(bulletHitX)
    ld      a,d
    or      e
    ret     z

    ld      l,(iy+OUSER+0)
    ld      h,(iy+OUSER+1)
    sbc     hl,de
    ret     nz

    ld      a,(bulletY)
    ld      b,a
    ld      a,(iy+OUSER+2)
    dec     a
    cp      b
    ret     nc

    add     a,4+1
    cp      b
    ret     c

    pop     hl

    ; become explosion

    ld      l,(iy+OUSER+3)
    ld      (iy+OUSER+0),l
    ld      h,(iy+OUSER+4)
    ld      (iy+OUSER+1),h
    ld      (hl),0
    set     7,h
    res     6,h
    ld      (hl),0
    ld      (iy+OUSER+2),16     ; short explosion
    jp      becomeexplosion


    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    .module LASER 

laseremup:
    ld      l,(iy+OUSER)        ; x
    ld      h,(iy+OUSER+1)
    ld      a,(iy+OUSER+2)      ; y
    call    mulby600
    add     hl,de

    ld      de,D_BUFFER+600
    add     hl,de

    ld      bc,600
-:  ld      (hl),CH_LASER
    add     hl,bc
    ld      a,(hl)
    or      a
    jr      z,{-}

    DIE
