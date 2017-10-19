minerelease:
    ld      hl,considermine
    call    findmine
    ret     nc

    push    hl

	call	getobject
	ld		bc,minearise
	call	initobject
	call	insertobject_beforehead

    pop     de
    ex      de,hl
    ldi
    ldi
    ldi
    set     7,(hl)

    ret


minearise:
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
    ld      (hl),a
    ld      (de),a

    YIELD

    ld      hl,(bulletHitX)
    ld      a,l
    or      h
    jr      z,{+}

aaaa:
    ld      e,(iy+OUSER+4)
    ld      d,(iy+OUSER+5)
    and     a
    sbc     hl,de
    jr      z,gobang

+:  ld      l,(iy+OUSER+0)
    ld      h,(iy+OUSER+1)

    inc     (iy+OUSER+2)
    ld      a,(iy+OUSER+2)
    and     15
    jr      nz,{-}

    dec     (iy+OUSER+3)
    jr      z,gobang

    ld      de,600
    and     a
    sbc     hl,de
    ld      a,(hl)
    and     a
    jr      z,{-}
    cp      $20
    jr      nc,{-}

    ; all done - become an explosion
gobang:
    xor     a
    ld      (iy+OUSER+2),a
    jp      becomeexplosion


    ; return with carry set when result is affirmative
    ;
    ; release this mine if random number < 50
    ;
considermine:
    push    hl
    inc     hl
    inc     hl
    inc     hl
    bit     7,(hl)
    jr      nz,retnocarry   ; bit 7 set = active already

    ld      a,(hl)          ; is it actually a mine?
    cp      CH_MINE
    jr      nz,retnocarry

    pop     hl
    call    rng
    cp      1
    ret                     ; return with C set if random number < 50

retnocarry:
    pop     hl
    xor     a
    ret
