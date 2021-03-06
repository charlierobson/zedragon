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

BOSSHITS = 3

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

    ld      bc,bossmine
    call    objectafterthis

    ld      hl,579+D_BUFFER+600

_close0:
    ld      (iy+_COUNT),11
    ld      (iy+_DOORL),l
    ld      (iy+_DOORH),h

    ld      a,SFX_WALL
    call    AFXPLAY

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
    ld      (iy+_HEALTH),BOSSHITS

_loop:
    YIELD

    ld      a,(collision)
    cp      $ff
    jr      nz,_subddeathtest

    call    startexplosion
    ldi
    ldi
    ldi

    ld      l,(iy+OUSER+0)
    ld      h,(iy+OUSER+1)
    ld      de,$4000
    add     hl,de
    ld      (hl),$8b ; $8d

_subddeathtest:
    and     a
    DIENZ

    ld      a,(bda)                 ; don't trigger the boss door if it's active
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

    ld      bc,bossdoor
    call    objectafterthis

    jr      _reset


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module BOSSMINER
;

_CXL = OUSER+0
_CXH = OUSER+1
_CY = OUSER+2
_TIMER = OUSER+3

bossmine:
    ld      (iy+_CXL),582 & 255
    ld      (iy+_CXH),582 / 256
    ld      (iy+_CY), 9

    ld      (iy+_TIMER),250

_waitloop:
    YIELD
    YIELD
    YIELD
    ld      a,(collision)
    and     a
    DIENZ
    dec     (iy+_TIMER)
    jr      nz,_waitloop

_appearloop:
    YIELD
    ld      a,(collision)
    and     a
    DIENZ
    ld      a,(iy+_TIMER)
    sra     a
    sra     a
    sra     a
    and     $fe
    add     a,$81
    ld      (D_BUFFER+582+(9*600)),a

    inc     (iy+_TIMER)
    ld      a,(iy+_TIMER)
    cp      64
    jr      nz,_appearloop

    ld      bc,minearise
    call    objectafterthis
    ldi
    ldi
    ldi

    YIELD

    jr      bossmine


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module BOSSDOOR
;

bda:
    .byte   0

bossdoor:
    ld      hl,bda              ; lock
    inc     (hl)

    ld      a,$1f
    call    _setchr
    ld      (iy+OUSER+0),20

_loop00:
    YIELD
    ld      a,(bosshitted)
    and     a
    jr      nz,_closenow

    dec     (iy+OUSER+0)
    jr      nz,_loop00

    ld      a,$29
    call    _setchr
    ld      (iy+OUSER+0),75

_loop01:
    YIELD
    ld      a,(bosshitted)
    and     a
    jr      nz,_closenow

    dec     (iy+OUSER+0)
    jr      nz,_loop01

_closenow:
    ld      a,$1f
    call    _setchr
    ld      (iy+OUSER+0),20

_loop02:
    YIELD
    dec     (iy+OUSER+0)
    jr      nz,_loop02

_close2:
    ld      a,$01
    call    _setchr

    ld      hl,bda
    dec     (hl)

    xor     a
    ld      (bosshitted),a

    DIE



_setchr:
    ld      hl,595+(600*5)+D_BUFFER
    ld      de,595+(600*5)+D_BUFFER+$4000
    ld      (hl),a
    ld      (de),a
    ret

bosshitted:
    .byte   0

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module BOSS
;

boss:
    ld      hl,597+(600*5)+D_BUFFER
    ld      (iy+OUSER+0),l
    ld      (iy+OUSER+1),h
    ld      (iy+OUSER+2),0

    ld      (iy+OUSER+3),BOSSHITS          ; boss hit count

    xor     a
    ld      (bosshitted),a

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

    ld      bc,5
    call    addscore
    call    displayscore

    call    startexplosion
    ldi
    ldi
    ldi

    ld      hl,bosshitted
    inc     (hl)

    dec     (iy+OUSER+3)
    jr      nz,_loop

    ld      a,$ff
    ld      (collision),a                   ; turn off shooters, quit gameloop

    ld      (iy+OUSER+3),3

_bigbangreset:
    ld      (iy+OUSER+2),30
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

    ld      hl,bossexit                 ; install the sub remote controller
    ld      (submvfunc),hl

    dec     (iy+OUSER+3)
    jr      nz,_bigbangreset

    ; 2 second delay

    ld      (iy+OUSER+3),100

-:  YIELD
    ld      bc,1
    call    addscore
    call    displayscore

    dec     (iy+OUSER+3)
    jr      nz,{-}

    ; congratulate player

    ld      bc,teletypercongrat
    call    objectafterthis

    DIE


_explosequence:
    .byte   $94,$56,$54,$98,$97,$81,$74,$93
    .byte   $86,$77,$65,$76,$85,$63,$64,$82
    .byte   $96,$78,$55,$73,$88,$84,$95,$72
    .byte   $66,$75,$92,$67,$83,$87




