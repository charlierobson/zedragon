;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module SPECIALDEPTH
;

specialdepthcharge:
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

    ld      (iy+OUSER+5),0

_loop0:  ; reset
    ld      (iy+OUSER+3),l      ; screen pos
    ld      (iy+OUSER+4),h

_loop1:
    ld      l,(iy+OUSER+3)
    ld      h,(iy+OUSER+4)    
    ld      a,CH_DEPTHBASE+0
    call    char2dlist
    set     7,h
    res     6,h
    ld      (hl),a
    YIELD

    call    _hittest            ; doesn't return if we're hit

    inc     (iy+OUSER+5)
    bit     3,(iy+OUSER+5)
    jr      z,_loop1

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

    ld      l,(iy+OUSER+3)
    ld      (iy+OUSER+0),l
    ld      h,(iy+OUSER+4)
    ld      (iy+OUSER+1),h

    ld      (hl),0              ; remove mine from screen & shadow map
    set     7,h
    res     6,h
    ld      (hl),0

    ld      (iy+OUSER+2),16     ; start later in sequence = short explosion
    jp      becomeexplosion
