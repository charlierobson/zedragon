BIT_MINE   = 7
BIT_STATIC = 6
BIT_INACT  = 4
s
minerelease:
    ld      hl,considermine
    call    findmine
    ret     nc

    ; hl -> enemytbl
    ; de -> enemyidx

    set     BIT_INACT,(hl)
    ld      a,(hl)
    and     $0f                     ; also clears carry
    push    af

    ld      hl,ENEMYIDX             ; calc x pos
    ex      de,hl
    sbc     hl,de
    push    hl

	call	getobject
	ld		bc,minearise
	call	initobject
	call	insertobject_beforehead     ; eit with hl-> data area

    pop     de
    ld      (hl),e
    inc     hl
    ld      (hl),d
    inc     hl
    pop     af
    ld      (hl),a

    ret


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
    jr      z,{+}               ; skip column check if no x position reported

    ld      e,(iy+OUSER+4)      ; column check
    ld      d,(iy+OUSER+5)
    and     a
    sbc     hl,de
    jr      z,gobang

+:  ld      l,(iy+OUSER+0)      ; restore screen pointer
    ld      h,(iy+OUSER+1)

    inc     (iy+OUSER+2)        ; only move mine up when frame = 0
    ld      a,(iy+OUSER+2)
    and     15
    jr      nz,{-}

    dec     (iy+OUSER+3)        ; explode when mine hits the top
    jr      z,gobang

    ld      de,600              ; move mine up
    and     a
    sbc     hl,de

    ld      a,(hl)              ; are we about to hit some thing?
    and     a
    jr      z,{-}

    cp      $20                 ; some solid thing?
    jr      nc,{-}

    ; all done - become an explosion

gobang:
    ; remove characters from screen

    ld      l,(iy+OUSER)
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

    ld      (iy+OUSER+2),a
    jp      becomeexplosion


    ; return with carry set when result is affirmative
    ;
    ; release this mine at random
    ;
considermine:
    bit     BIT_INACT,(hl)
    jr      nz,retnocarry       ; bit set = mine unavailable

    bit     BIT_STATIC,(hl)
    jr      nz,retnocarry       ; bit set = mine unavailable

    bit     BIT_MINE,(hl)       ; bit set = mine
    jr      z,retnocarry

    push    bc
    call    rng
    pop     bc
    cp      1
    ret                         ; return with C set if mine should be chosen

retnocarry:
    xor     a
    ret
