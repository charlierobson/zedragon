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
    nop
    nop
    nop
    call    _hittestc            ; doesn't return if we're hit
    jr      _loop1




_hittestc:
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

    ; become explosion
_dedded:

;    pop     hl                  ; sink return address as we're not returning

    ld      l,(iy+OUSER+3)
    ld      h,(iy+OUSER+4)
    ld      de,600
    add     hl,de
    push    hl
    call    getobject
    ld      bc,explosion
    call    initobject
    call    insertobject_afterhead
    ex      de,hl
    pop     de
    ld      (hl),e
    inc     hl
    ld      (hl),d
    ret