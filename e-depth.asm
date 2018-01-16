;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module DEPTHGEN
;

DROPRATE = 3

depthchargeGenerator:
    ld      a,r
    and     15
    ld      (iy+OUSER+6),a

_loop:
    YIELD

    ld      a,(collision)                   ; die if sub died
    or      a
    DIENZ
    call    cIfIneffectiveHard
    DIEC
    call    cIfOffscreenLeft
    DIEC

    dec     (iy+OUSER+6)
    jr      nz,_loop

    ld      (iy+OUSER+6),$28

    ld      bc,depthcharge
    call    objectafterthis
    ldi
    ldi
    ldi

    jr      _loop


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module DEPTH
;


depthcharge:
    ld      l,(iy+OUSER+0)      ; x
    ld      h,(iy+OUSER+1)
    inc     (iy+OUSER+2)        ; y
    ld      a,(iy+OUSER+2)
    call    mulby600
    add     hl,de
    ld      de,D_BUFFER
    add     hl,de

    sla     (iy+OUSER+2)        ; y *= 8
    sla     (iy+OUSER+2)
    sla     (iy+OUSER+2)

    ld      (iy+OUSER+3),l      ; screen pos
    ld      (iy+OUSER+4),h
    ld      (iy+OUSER+5),DROPRATE

-:  ld      a,CH_DEPTHBASE+0
    call    nme2dlistandmirror

    YIELD
    call    _hittest            ; doesn't return if we're hit

    dec     (iy+OUSER+5)
    jr      nz,{-}

_loop0:
    inc     (iy+OUSER+2)      ; bump y
    inc     (iy+OUSER+2)
    ld      (iy+OUSER+5),DROPRATE

-:  ld      a,CH_DEPTHBASE+1
    call    nme2dlistandmirror

    YIELD
    call    _hittest            ; doesn't return if we're hit

    dec     (iy+OUSER+5)
    jr      nz,{-}

    inc     (iy+OUSER+2)      ; bump y
    inc     (iy+OUSER+2)
    ld      (iy+OUSER+5),DROPRATE

-:  ld      a,CH_DEPTHBASE+2
    call    nme2dlistandmirror

    YIELD
    call    _hittest            ; doesn't return if we're hit

    dec     (iy+OUSER+5)
    jr      nz,{-}

    ld      l,(iy+OUSER+3)
    ld      h,(iy+OUSER+4)
    set     7,h
    res     6,h
    ld      de,600
    add     hl,de
    ld      a,(hl)
    or      a
    jr      z,_notdeadyet

    sbc     hl,de
    ld      (hl),0
    DIE

_notdeadyet:
    inc     (iy+OUSER+2)      ; bump y
    inc     (iy+OUSER+2)
    ld      (iy+OUSER+5),DROPRATE

-:  ld      a,CH_DEPTHBASE+3
    call    nme2dlistandmirror

    ld      l,(iy+OUSER+3)
    ld      h,(iy+OUSER+4)
    ld      de,600
    add     hl,de
    ld      a,CH_DEPTHBASE+4
    call    char2dlist
    set     7,h
    res     6,h
    ld      (hl),a

    YIELD
    call    _hittest            ; doesn't return if we're hit

    dec     (iy+OUSER+5)
    jr      nz,{-}

    inc     (iy+OUSER+2)      ; bump y
    inc     (iy+OUSER+2)
    ld      (iy+OUSER+5),DROPRATE

    xor     a
    call    nme2dlistandmirror

    ld      l,(iy+OUSER+3)
    ld      h,(iy+OUSER+4)
    ld      de,600
    add     hl,de
    ld      (iy+OUSER+3),l
    ld      (iy+OUSER+4),h

-:  ld      a,CH_DEPTHBASE+0
    call    nme2dlistandmirror

    YIELD
    call    _hittest            ; doesn't return if we're hit

    dec     (iy+OUSER+5)
    jr      nz,{-}

    jp      _loop0


_hittest:
    ld      de,(bulletHitX)     ; early exit if no hit signalled
    ld      a,d
    or      e
    ret     z

    ld      l,(iy+OUSER+0)      ; exit if hit x != this x
    ld      h,(iy+OUSER+1)
    sbc     hl,de
    ret     nz

    ld      a,(bulletHitY)         ; check if bullet is either side of the charge
    ld      b,a

    ld      a,(iy+OUSER+2)
    dec     a
    cp      b
    ret     nc

    add     a,4+1
    cp      b
    ret     c

    pop     hl                  ; sink return address as we're not returning

    ; become explosion

    ld      bc,2
    call    addscore

    ld      l,(iy+OUSER+3)
    ld      (iy+OUSER+0),l
    ld      h,(iy+OUSER+4)
    ld      (iy+OUSER+1),h

    set     7,h                 ; remove from shadow map
    res     6,h
    ld      a,(hl)
    ld      (hl),0
    cp      CH_DEPTHBASE+3
    jr      nz,{+}

    ld      de,600
    add     hl,de
    ld      (hl),0

+:  call    explosound

    ld      (iy+OUSER+2),16     ; start later in sequence = short explosion
    jp      becomeexplosion
