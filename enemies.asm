    .module ENEMIES

BIT_MINE   = 7      ; 1 = mine, 0 = stalactite
BIT_STATIC = 6      ; chained mine, won't rise
BIT_SHOOT  = 5      ; shooter type
BIT_INACT  = 4      ; busy or dead

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
    call    findmine
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
    bit     BIT_INACT,(hl)
    jr      nz,_retnocarry
    
    bit     BIT_SHOOT,(hl)
    jr      z,_retnocarry

    scf                        ; start a shooter
     ret

    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    ;
considermine:
    bit     BIT_INACT,(hl)
    jr      nz,_retnocarry              ; bit set = mine unavailable

    bit     BIT_STATIC,(hl)
    jr      nz,_retnocarry              ; bit set = mine unavailable for rising

    bit     BIT_MINE,(hl)               ; bit set = mine
    jr      z,_retnocarry

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
    ld      a,(hl)
    and     %11110000
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
    ;
    ; possible shooter sequences
_sseq:
    .byte   1,0,0,0,0,0,0,0,0,0,0
    .byte   2,1,0,0,0,0,0,0,0,0,0
    .byte   3,2,1,0,0,0,0,0,0,0,0
    .byte   2,3,2,1,0,0,0,0,0,0,0
    .byte   3,2,3,2,1,0,0,0,0,0,0
    .byte   2,3,2,3,2,1,0,0,0,0,0
    .byte   3,2,3,2,3,2,1,0,0,0,0
    .byte   2,3,2,3,2,3,2,1,0,0,0
    .byte   3,2,3,2,3,2,3,2,1,0,0
    .byte   2,3,2,3,2,3,2,3,2,1,0
    .byte   3,2,3,2,3,2,3,2,3,2,1

    .byte   2,3,2,3,2,3,2,3,2,3,2
    .byte   3,2,3,2,3,2,3,2,3,2,3

    .byte   4,3,2,3,2,3,2,3,2,3,2
    .byte   5,4,3,2,3,2,3,2,3,2,3
    .byte   0,5,4,3,2,3,2,3,2,3,2
    .byte   0,0,5,4,3,2,3,2,3,2,3
    .byte   0,0,0,5,4,3,2,3,2,3,2
    .byte   0,0,0,0,5,4,3,2,3,2,3
    .byte   0,0,0,0,0,5,4,3,2,3,2
    .byte   0,0,0,0,0,0,5,4,3,2,3
    .byte   0,0,0,0,0,0,0,5,4,3,2
    .byte   0,0,0,0,0,0,0,0,5,4,3
    .byte   0,0,0,0,0,0,0,0,0,5,4
    .byte   0,0,0,0,0,0,0,0,0,0,5
    .byte   0,0,0,0,0,0,0,0,0,0,0

CH_SHOOTBASE = $33

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
    ld      (iy+OUSER+5),0
    ld      (iy+OUSER+6),10
    ld      (iy+OUSER+7),_sseq & 255
    ld      (iy+OUSER+8),_sseq / 256

    ; search the shooter space to find the required length
    ld      de,601

-:  ld      a,(hl)
    and     a
    jr      nz,_shootloop

    inc     (iy+OUSER+5)        ; shooter length
    add     hl,de
    jr      {-}

_shootloop:
    YIELD
    dec     (iy+OUSER+5)
    jr      nz,_shootloop

    ld      (iy+OUSER+5),10     ; reset delay counter

    ld      bc,601              ; offset to next shot posn on screen

    ld      a,(iy+OUSER+5)      ; shot stream length
    ld      (iy+OUSER+9),a

    ld      l,(iy+OUSER+3)      ; screen position
    ld      h,(iy+OUSER+4)
    ld      e,(iy+OUSER+7)      ; update table
    ld      d,(iy+OUSER+8)

-:  ld      a,(de)
    or      a
    jr      z,{+}

    add     a,CH_SHOOTBASE-1

+:  ld      (hl),a
    add     hl,bc
    inc     de
    dec     (iy+OUSER+9)
    jr      nz,{-}

    ld      l,(iy+OUSER+7)      ; next step in the table
    ld      h,(iy+OUSER+8)
    ld      de,10
    add     hl,de
    ld      (iy+OUSER+7),l
    ld      (iy+OUSER+8),h

    jr      _shootloop