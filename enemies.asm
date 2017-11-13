;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module ENEMIES
;

BIT_INACT    = 7      ; busy or dead

NME_STAL     = $00
NME_MINE     = $10
NME_STATMINE = $20
NME_DEPTH    = $30
NME_SHOOT    = $40
NME_LASER    = $50

; TODO - make x,y to screenpos function to share amongst objects
;        make function that creates & initialises object


    .align  32
_considertable:
    .word   considerstal, stalfall
    .word   considermine, minearise
    .word   considernull, 0     ; never consider static mines
    .word   considerdepth, depthchargeGenerator
    .word   considershooter, shootemup
    .word   considerlaser, laseremup


enemyinitiator:
    ld      de,(scrollpos)      ; find the first enemy on screen
    ld      hl,enemyidx
    add     hl,de
    ex      de,hl
    ld      b,32                ; and check up to 32 screen x positions from there

_search:
    ld      a,(de)              ; get enemy table index, or ff if no enemy at this x pos
    cp      $ff
    jr      z,_nope

    push    bc
    push    de

    ld      h,enemydat / 256    ; make pointer into enemy data table
    ld      l,a
    ld      a,(hl)              ; get enemy type
    bit     BIT_INACT,a
    call    z,_possibly

    pop     de
    pop     bc

_nope:
    inc     de
    djnz    _search

    ret


_possibly:
    and     $f0                 ; isolate type
    rrca
    rrca

    push    hl

    ld      hl,_considertable   ; index into consideration table
    or      l
    ld      l,a

    push    de
    ld      de,_considerator+1
    ldi
    ldi
    ld      de,_starterator+1
    ldi
    ldi
    pop     de

    pop     hl

_considerator:
    call    0
    ret     nc

_yep:
    set     BIT_INACT,(hl)              ; setting the inactive bit will change the enemy id
    ld      a,(hl)
    and     $0f                         ; isolate Y - also clears carry for SBC below
    push    af

    ld      hl,enemyidx                 ; calculate X
    ex      de,hl
    sbc     hl,de
    push    hl

_starterator:
    ld      bc,0

    call    getobject
    call    initobject
    call    insertobject_beforehead     ; exits with hl-> data area

    pop     de                          ; retrieve X
    ld      (hl),e
    inc     hl
    ld      (hl),d
    inc     hl
    pop     af                          ; retrieve Y
    ld      (hl),a

    ret


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
; consideration functions - return with carry set to go with
; this object.
;
considerdepth:          ; always starts
considershooter:
considerlaser:
    scf
considernull:           ; never starts
    ret

considermine:
    push    bc
    call    rng
    pop     bc
    cp      1
    ret                 ; return with C set to choose this enemy

considerstal:
    push    bc
    call    rng
    pop     bc
    cp      1
    ret


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
; Return with carry set if x is off screen left
;
cIfOffscreenLeft:
    ld      l,(iy+OUSER+0)
    ld      h,(iy+OUSER+1)
    ld      de,(scrollpos)
    and     a
    sbc     hl,de
    ret


    .include "e-stalactite.asm"
    .include "e-mine.asm"
    .include "e-shooter.asm"
    .include "e-depth.asm"
    .include "e-laser.asm"
    