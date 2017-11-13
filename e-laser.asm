;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module LASER 
;

laseremup:
    ld      l,(iy+OUSER)        ; x
    ld      h,(iy+OUSER+1)
    ld      a,(iy+OUSER+2)      ; y
    call    mulby600
    add     hl,de

    ld      de,D_BUFFER+600
    add     hl,de

    ld      e,l
    ld      d,h
    set     7,d
    res     6,d

    ld      bc,600
-:  ld      a,CH_LASER
    ld      (hl),a
    ld      (de),a
    add     hl,bc
    ld      a,(hl)
    ex      de,hl
    add     hl,bc
    or      a
    jr      z,{-}

    DIE
