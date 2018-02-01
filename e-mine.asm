;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module MINE
;

_SCRPOS = OUSER
_COUNTER = OUSER+2
_YPOS = OUSER+3
_XPOS = OUSER+4

minearise:
    ld      a,SFX_MINERELEASE
    call    AFXPLAY

    ld      l,(iy+_SCRPOS+0)        ; hl = x
    ld      h,(iy+_SCRPOS+1)
    ld      a,(iy+_COUNTER)         ; = y
    dec     a

    ld      (iy+_YPOS),a            ; keep X & (adjusted) Y around for various comparisons
    ld      (iy+_XPOS+0),l
    ld      (iy+_XPOS+1),h

    call    mulby600
    add     hl,de                   ; hl = x + 600 * (y-1)
    ld      de,D_BUFFER
    add     hl,de

    xor     a

_loop:
    ld      (iy+_COUNTER),a         ; counter

    ; always draw before the yield
    ; check collisions / update position after

    ld      (iy+_SCRPOS+0),l        ; screen pointer
    ld      (iy+_SCRPOS+1),h

    ld      d,h
    ld      e,l
    set     7,d
    res     6,d

    and     %00001100
    rrca
    add     a,CH_MINEBASE+1
    ld      (de),a
    call    char2dlist
    dec     a
    ld      bc,600
    add     hl,bc
    call    char2dlist
    ex      de,hl
    add     hl,bc
    ld      (hl),a

    YIELD

    ; is the bullet reporting a collision, and is it in our column?

    ld      hl,(bulletHitX)
    ld      a,l
    or      h
    jr      z,_update           ; skip column check if no x position reported

    ld      e,(iy+_XPOS+0)      ; column check
    ld      d,(iy+_XPOS+1)
    and     a
    sbc     hl,de
    jr      nz,_update

    ld      bc,1
    call    addscore
    call    explosound
    jr      _gobang

_update:
    ld      l,(iy+_SCRPOS+0)    ; restore screen pointer
    ld      h,(iy+_SCRPOS+1)

    inc     (iy+_COUNTER)       ; only move mine up when frame = 0
    ld      a,(iy+_COUNTER)
    and     15
    jr      nz,_loop

    dec     (iy+_YPOS)          ; explode when mine hits the top
    jr      z,_breach

    ld      de,600              ; move mine up
    and     a
    sbc     hl,de

    push    hl
    set     7,h
    res     6,h
    ld      a,(hl)              ; are we about to hit some thing?
    and     a
    ld      b,a
    pop     hl
    ld      a,0                 ; doesn't alter z flag
    jr      z,_loop             ; nothing above us, so continue

    ld      a,b

    cp      CH_MINEBLANK        ; mine trail?
    jr      z,_loop

    cp      $30                 ; some solid thing above?
    jr      nc,_loop

    ; all done - become an explosion

_breach:
    ld      a,SFX_MINEBREACH
    call    AFXPLAY

_gobang:
    ld      l,(iy+_SCRPOS+0)    ; remove characters from the mirror
    ld      h,(iy+_SCRPOS+1)
    set     7,h
    res     6,h
    ld      (hl),0
    ld      bc,600
    add     hl,bc
    ld      (hl),0

    ld      (iy+_COUNTER),0      ; swap to explosion coroutine
    jp      becomeexplosion



magicminecheck:
    and     $70
    cp      NME_STATMINE
    ret     nz

_cbmm:
    ld      hl,_magicmines
    ld      (_mmptr),hl
    ld      b,6

_mmptr = $+1
-:  ld      hl,(0)
    and     a
    sbc     hl,de
    jr      z,_isMagic
    ld      hl,_mmptr+1
    inc     (hl)
    djnz    {-}
    ret

_isMagic:
    ret

    .align  16
_magicmines:
    .word   10, 87, 187, 350, 359, 583
