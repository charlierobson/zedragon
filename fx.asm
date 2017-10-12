explosion:
    xor     a

-:  ld      (iy+OUSER+2),a
    ld      l,(iy+OUSER)
    ld      h,(iy+OUSER+1)

    sra     a
    sra     a
    add     a,CH_EXPLODEBASE
    ld      (hl),a

    YIELD

    ld      a,(iy+OUSER+2)
    inc     a
    cp      24
    jr      nz,{-}

    ld      l,(iy+OUSER)
    ld      h,(iy+OUSER+1)
    ld      (hl),0

    DIE




chaindrop:
    YIELD
    YIELD
    YIELD
    YIELD

    ld      e,(iy+OUSER)
    ld      d,(iy+OUSER+1)
    ld      hl,600
    add     hl,de

    ld      a,(hl)
    cp      CH_CHAIN
    jr      z,{+}

    DIE

+:  ld      (iy+OUSER),l
    ld      (iy+OUSER+1),h
    xor     a
    ld      (hl),a
    set     7,h
    res     6,h
    ld      (hl),a
    jr      chaindrop
