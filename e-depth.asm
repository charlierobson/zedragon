;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module DEPTHGEN
;

depthchargeGenerator:
    ld      a,r
    and     15
    ld      (iy+OUSER+6),a

_loop:
    YIELD

    ld      a,(collision)
    and     a
    DIENZ

    dec     (iy+OUSER+6)
    jr      nz,_loop

    ld      (iy+OUSER+6),39

    ld      bc,depthcharge
    call    getobject
    call    initobject
    call    insertobject_afterthis

    ld      a,(iy+OUSER+0)
    ld      (hl),a
    inc     hl
    ld      a,(iy+OUSER+1)
    ld      (hl),a
    inc     hl
    ld      a,(iy+OUSER+2)
    ld      (hl),a

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

    ld      (iy+OUSER+5),0

_loop0:  ; reset
    ld      (iy+OUSER+3),l      ; screen pos
    ld      (iy+OUSER+4),h

_loop1:
    ld      l,(iy+OUSER+3)
    ld      h,(iy+OUSER+4)    
    ld      (hl),CH_DEPTHBASE
    set     7,h
    res     6,h
    ld      (hl),CH_DEPTHBASE
    YIELD

    call    _hittest            ; doesn't return if we're hit

    inc     (iy+OUSER+5)
    bit     3,(iy+OUSER+5)
    jr      z,_loop1

    ld      a,(iy+OUSER+2)      ; bump y
    add     a,4
    ld      (iy+OUSER+2),a

_loop2:
    ld      l,(iy+OUSER+3)
    ld      h,(iy+OUSER+4)
    ld      (hl),CH_DEPTHBASE+1
    set     7,h
    res     6,h
    ld      (hl),CH_DEPTHBASE+1
    YIELD

    call    _hittest

    inc     (iy+OUSER+5)
    bit     3,(iy+OUSER+5)
    jr      nz,_loop2

    ld      a,(iy+OUSER+2)      ; bump y
    add     a,4
    ld      (iy+OUSER+2),a

    ld      l,(iy+OUSER+3)      ; clear old mine from screen
    ld      h,(iy+OUSER+4)
    ld      (hl),0
    set     7,h
    res     6,h
    ld      (hl),0              ; write to shadow

    ld      bc,600              ; next line
    add     hl,bc
    ld      a,(hl)              ; reading from shadow map
    res     7,h
    set     6,h
    or      a
    jp      z,_loop0

    DIE


_hittest:
    ld      de,(bulletHitX)     ; early exit if no hit signalled
    ld      a,d
    or      e
    ret     z

    ld      l,(iy+OUSER+0)      ; exit if hit x != this x
    ld      h,(iy+OUSER+1)
    sbc     hl,de
    ret     nz

    ld      a,(bulletY)         ; check if bullet is either side of the charge
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
