;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module LASER 
;

laseremup:
    ld      a,(laserframe)
    and     $83
    ld      a,SFX_LECTRIC
    call    z,AFXPLAY

    YIELD

    ld      a,(collision)                   ; die if sub died
    or      a
    DIENZ
    call    cIfOffscreenLeft
    DIEC

    jr      laseremup
