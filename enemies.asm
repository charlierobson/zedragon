minerelease:
    ld      hl,considermine
    call    findmine
    ret     nc

    push    hl

	call	getobject
	ld		bc,minearise
	call	initobject
	call	insertobject_afterthis

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
    ld      a,(iy+OUSER+2)
    call    mulby600
    add     hl,de               ; hl += 600 y
    ld      de,D_BUFFER
    add     hl,de
    ld      a,2
    ld      (iy+OUSER+2),a      ; counter

-:  ld      (iy+OUSER),l        ; store screen pointer
    ld      (iy+OUSER+1),h

    ld      a,(iy+OUSER+2)
    and     %00001100
    rrca
    add     a,mine
    ld      (hl),a
    inc     a
    ld      de,600
    add     hl,de
    ld      (hl),a

    YIELD

    ld      l,(iy+OUSER+0)
    ld      h,(iy+OUSER+1)

    inc     (iy+OUSER+2)
    ld      a,(iy+OUSER+2)
    and     15
    cp      4
    jr      nz,{-}

    push    hl
    ld      de,600
    and     a
    sbc     hl,de
    pop     de
    ld      a,(hl)
    and     a
    jr      z,{-}

    ; all done - become an explosion

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
    cp      mine
    jr      nz,retnocarry

    pop     hl
    call    rng
    cp      1
    ret                     ; return with C set if random number < 50

retnocarry:
    pop     hl
    xor     a
    ret
