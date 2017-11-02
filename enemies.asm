    .module ENEMIES

BIT_MINE   = 7      ; 1 = mine, 0 = stalactite
BIT_STATIC = 6      ; chained mine, won't rise
BIT_INACT  = 4      ; busy or dead

	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	;
    ; Stalactite release.
    ;
    ; Scan the list of on-screen enemies and if a stalactite is
    ; found, and not busy, then it gets a chance of being released.
    ;
stalacrelease:
    ld      hl,considerstal
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

_considerator:
    call    findmine
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


    ; return with carry set when result is affirmative
    ;
    ; release this mine at random
    ;
considermine:
    bit     BIT_INACT,(hl)
    jr      nz,_retnocarry              ; bit set = mine unavailable

    bit     BIT_STATIC,(hl)
    jr      nz,_retnocarry              ; bit set = mine unavailable

    bit     BIT_MINE,(hl)               ; bit set = mine
    jr      z,_retnocarry

    call    rng
    cp      1
    ld      bc,minearise
    ret                                 ; return with C set to choose this enemy

_retnocarry:
    xor     a
    ret

considerstal:
    bit     BIT_INACT,(hl)
    jr      nz,_retnocarry              ; bit set = mine unavailable

    bit     BIT_MINE,(hl)               ; bit set = mine
    jr      nz,_retnocarry

    push    bc
    call    rng
    pop     bc
    cp      8
    ld      bc,stalfall
    ret                                 ; return with C set to choose this enemy



stalfall:
    DIE




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
