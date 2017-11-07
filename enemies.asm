    .module ENEMIES

BIT_INACT    = 7      ; busy or dead

NME_STAL     = $00
NME_MINE     = $10
NME_STATMINE = $20
NME_DEPTH    = $30
NME_SHOOT    = $40

	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	;
    ; Shooter start.
    ;
    ; Scan the list of on-screen enemies and start any non-started
    ; shooters
    ;
shooterstart:
    ld      hl,considershooter
    ld      bc,shootemup
    jr      _considerator


	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	;
    ; Stalactite release.
    ;
    ; Scan the list of on-screen enemies and if a stalactite is
    ; found, and not busy, then it gets a chance of being released.
    ;
stalacrelease:
    ld      hl,considerstal
    ld      bc,stalfall
    jr      _considerator

	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	;
    ; Mine release.
    ;
    ; Scan the list of on-screen enemies and if a mine is found,
    ; and not busy or chained, then it gets a chance of being released.
    ;
minerelease:
    ld      hl,considermine
    ld      bc,minearise

    ;

_considerator:
    push    bc
    call    findenemy
    pop     bc
    ret     nc

    ; on return from findmine:
    ; hl -> enemytbl
    ; de -> enemyidx
    ; bc = exe function

    set     BIT_INACT,(hl)
    ld      a,(hl)
    and     $0f                         ; isolate Y - also clears carry for SBC below
    push    af

    ld      hl,ENEMYIDX                 ; calculate X
    ex      de,hl
    sbc     hl,de
    push    hl

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
    ;
considershooter:
    cp      NME_SHOOT
    jr      nz,_retnocarry

    scf                        ; start a shooter
    ret

    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    ;
considermine:
    cp      NME_MINE
    jr      nz,_retnocarry

    push    bc
    call    rng
    pop     bc
    cp      1
    ret                                 ; return with C set to choose this enemy

_retnocarry:
    xor     a
    ret

    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    ;
considerstal:
    cp      NME_STAL
    jr      nz,_retnocarry

    push    bc
    call    rng
    pop     bc
    cp      1
    ret                                 ; return with C set to choose this enemy


    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    .module stalactite
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
    add     a,$20+1             ; start of mine sequence in char set
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

    ld      l,(iy+OUSER+0)      ; restore screen pointer
    ld      h,(iy+OUSER+1)

    inc     (iy+OUSER+2)        ; only move when frame = 0
    ld      a,(iy+OUSER+2)
    and     7
    jr      nz,{-}

    ld      de,600
    add     hl,de

    ld      a,(hl)              ; are we about to hit some thing?
    and     a
    jr      z,{-}

    sbc     hl,de
    ld      (hl),0              ; yep - undraw & stop
    sbc     hl,de
    ld      (hl),0

    DIE




    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    .module mine
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
    add     a,$28+1             ; start of mine sequence in char set
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

    cp      $20                 ; some solid thing?
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
    .module shooter 

CH_SHOOTBASE = $33
SHOOTPERIOD = 3
SHOOTITERS = 10

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
    ld      (iy+OUSER+5),0              ; shooter length
    ld      (iy+OUSER+7),SHOOTITERS
    ld      (iy+OUSER+8),0
    ld      (iy+OUSER+12),0

    ; search the shooter space to find the required length
    ld      de,601
    jr      {+}

-:  inc     (iy+OUSER+5)        ; shooter length
    add     hl,de

+:  ld      a,(hl)
    and     a
    jr      z,{-}

    ; shooting on
_pewpew:
    ld      de,ontab
    ld      (iy+OUSER+10),e
    ld      (iy+OUSER+11),d
    ld      (iy+OUSER+7),SHOOTITERS

_shoot_on_main:
    call    shootahoopa
    inc     (iy+OUSER+8)

    call    shootahoopa
    dec     (iy+OUSER+8)

    call    nextframe

    dec     (iy+OUSER+7)                    ; number of positions in offtabs
    jr      nz,_shoot_on_main

    ; shooting off

    ld      de,offtab
    ld      (iy+OUSER+10),e
    ld      (iy+OUSER+11),d
    ld      (iy+OUSER+7),SHOOTITERS

_shoot_off_main:
    call    shootahoopa
    inc     (iy+OUSER+8)

    call    shootahoopa
    dec     (iy+OUSER+8)

    call    nextframe

    dec     (iy+OUSER+7)                    ; number of positions in offtabs
    jr      nz,_shoot_off_main

    ; shoot sequence finished, wait a couple of seconds

    ld      (iy+OUSER+6),50                 ; delay counter

-:  YIELD

    ld      a,(collision)                   ; die if sub died
    or      (iy+OUSER+12)
    jr      nz,_die
osc:
    ld      hl,(scrollpos)                  ; die when off screen
    ld      e,(iy+OUSER)                    ; x
    ld      d,(iy+OUSER+1)
    and     a
    sbc     hl,de
    jr      nc,_die

    dec     (iy+OUSER+6)
    jr      nz,{-}

    jp      _pewpew

_die:
    DIE


nextframe:
    ld      e,(iy+OUSER+10)
    ld      d,(iy+OUSER+11)
    dec     de
    ld      (iy+OUSER+10),e
    ld      (iy+OUSER+11),d
    ret


shootahoopa:
    ld      (iy+OUSER+6),SHOOTPERIOD

--: ld      l,(iy+OUSER+3)      ; screen position
    ld      h,(iy+OUSER+4)
    ld      bc,601              ; offset to next shot posn on screen

    ld      a,(iy+OUSER+5)      ; shot stream length
    ld      (iy+OUSER+9),a

    ld      e,(iy+OUSER+10)
    ld      d,(iy+OUSER+11)

-:  ld      a,(de)
    and     a
    jr      z,{+}
    add     a,(iy+OUSER+8)
+:  ld      (hl),a
    set     7,h
    res     6,h
    ld      (hl),a
    res     7,h
    set     6,h
    inc     de
    add     hl,bc
    dec     (iy+OUSER+9)
    jr      nz,{-}

    YIELD
    dec     (iy+OUSER+6)
    jr      nz,{--}

    ld      a,(collision)
    or      (iy+OUSER+12)
    ld      (iy+OUSER+12),a

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
