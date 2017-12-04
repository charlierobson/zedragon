;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module BOSSKEY
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
    ld      (iy+OUSER+2),16         ; resdy for copying to explosion, short one please

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

_reset:
    ld      (iy+_HEALTH),3

_loop:
    YIELD

    ld      a,(collision)
    and     a
    DIENZ

    ld      a,(bda)                 ; don't trigger the boss door if there's already one active
    and     a
    jr      nz,_reset

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

    call    startexplosion
    ldi
    ldi
    ldi

    call    getobject
    ld      bc,bossdoor
    call    initobject
    call    insertobject_afterthis

    jr      _reset



;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module BOSSDOOR
;

bda:
    .byte   0

bossdoor:
    ; 595,5
    ld      hl,bda
    inc     (hl)

    ld      (iy+OUSER+0),12

_loop00:
    YIELD
    dec     (iy+OUSER+0)
    jr      nz,_loop00

    ld      a,$1f
    call    _setchr

_loop01:
    YIELD
    dec     (iy+OUSER+0)
    jr      nz,_loop01

    ld      a,$29
    call    _setchr

    ld      (iy+OUSER+0),100

_loop02:
    YIELD
    dec     (iy+OUSER+0)
    jr      nz,_loop02

    ld      a,$1f
    call    _setchr

_loop03:
    YIELD
    dec     (iy+OUSER+0)
    jr      nz,_loop03

    ld      a,$01
    call    _setchr

    ld      hl,bda
    dec     (hl)

    DIE



_setchr:
    ld      (iy+OUSER+0),12
    ld      hl,595+(600*5)+D_BUFFER
    ld      de,595+(600*5)+D_BUFFER+$4000
    ld      (hl),a
    ld      (de),a
    ret



;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module BOSS
;

boss:
    ld      hl,597+(600*5)+D_BUFFER
    ld      (iy+OUSER+0),l
    ld      (iy+OUSER+1),h
    ld      (iy+OUSER+2),0

    ld      (iy+OUSER+3),3

_loop:
    YIELD

    ld      a,(collision)
    and     a
    DIENZ

    ld      hl,(bulletHitX)
    ld      a,l
    or      h
    jr      z,_loop                 ; skip column check if no x position reported

    ld      de,597
    and     a
    sbc     hl,de
    jr      nz,_loop

    call    startexplosion
    ldi
    ldi
    ldi

    dec     (iy+OUSER+3)
    jr      nz,_loop

    ld      (iy+OUSER+3),4

_bigbangreset:
    ld      (iy+OUSER+2),22
    ld      hl,_explosequence

_bigbangloop:
    ld      (iy+OUSER+4),l
    ld      (iy+OUSER+5),h

    ld      a,(hl)
    ld      b,a
    and     $0f
    call    mulby600
    ld      hl,D_BUFFER+590
    add     hl,de
    ld      a,b
    and     $f0
    rrca
    rrca
    rrca
    rrca
    ld      d,0
    ld      e,a
    add     hl,de
    ld      (iy+OUSER+0),l
    ld      (iy+OUSER+1),h

    ld      de,$4000
    add     hl,de
    ld      (hl),0

    call    startexplosion
    ldi
    ldi
    ldi

    ld      a,r
    and     7
    add     a,3
    ld      (iy+OUSER+6),a

-:  YIELD
    dec     (iy+OUSER+6)
    jr      nz,{-}

    ld      l,(iy+OUSER+4)
    ld      h,(iy+OUSER+5)
    inc     hl
    dec     (iy+OUSER+2)
    jr      nz,_bigbangloop

    dec     (iy+OUSER+3)
    jr      nz,_bigbangreset

    DIE

_explosequence:
    .byte   $97,$73,$83,$55,$56,$94,$93,$81,
    .byte   $77,$66,$96,$64,$67,$87,$63,$88,
    .byte   $98,$78,$92,$82,$72,$54
