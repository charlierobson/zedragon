;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module LASER 
;

_laserReq:
    .byte   0


_makeSound:
    ld      a,(_laserReq)
    or      a
    ret     z

    ld      a,(laserframe)
    and     $83
    ld      a,SFX_LECTRIC
    call    z,AFXPLAY
    ret


laseremup:
    ld      a,1
    ld      (_laserReq),a

    YIELD

    xor     a
    ld      (_laserReq),a

    ld      a,(collision)                   ; die if sub died
    or      a
    DIENZ
    call    cIfOffscreenLeft
    DIEC

    jr      laseremup
