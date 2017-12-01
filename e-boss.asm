;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module BOSS
;

_XPL = OUSER+3
_XPH = OUSER+4
_HEALTH = OUSER+5
_COUNT = OUSER+6
_DOORL = OUSER+7
_DOORH = OUSER+8

bosskey:
    ld      l,(iy+OUSER+0)          ; hl = x
    ld      h,(iy+OUSER+1)
    ld      (iy+_XPL),l
    ld      (iy+_XPH),h
    ld      a,(iy+OUSER+2)          ; = y
    call    mulby600
    add     hl,de                   ; hl = x + 600 * (y-1)
    ld      de,D_BUFFER
    add     hl,de
    ld      (iy+OUSER+0),l          ; hl = x
    ld      (iy+OUSER+1),h

    ld      (iy+_HEALTH),10

    ld      hl,579+D_BUFFER+600

_close0:
    ld      (iy+_COUNT),11
    ld      (iy+_DOORL),l
    ld      (iy+_DOORH),h

_close1:
    YIELD
    dec     (iy+_COUNT)
    jr      nz,_close1

    ld      l,(iy+_DOORL)
    ld      h,(iy+_DOORH)
    ld      a,1
    call    char2dlist
    set     7,h
    res     6,h
    ld      (hl),1
    ld      de,600
    add     hl,de
    ld      a,(hl)
    res     7,h
    set     6,h
    and     a
    jr      z,_close0

_loop:
    YIELD

    ld      hl,(bulletHitX)
    ld      a,l
    or      h
    jr      z,_loop                 ; skip column check if no x position reported

    ld      e,(iy+_XPL)             ; column check
    ld      d,(iy+_XPH)
    and     a
    sbc     hl,de
    jr      nz,_loop

    dec     (iy+_HEALTH)
    jr      nz,_loop

    ld      l,(iy+OUSER+0)          ; replace boss key with wreckage
    ld      h,(iy+OUSER+1)
    set     7,h
    res     6,h
    ld      (hl),$8b

    jp      explosion


bossdoor:
    DIE
