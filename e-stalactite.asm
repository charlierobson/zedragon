;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module STALAC
;

stalfall:
    ld      a,SFX_STALAC
    call    AFXPLAY

    ld      l,(iy+OUSER)        ; hl = x
    ld      h,(iy+OUSER+1)
    ld      a,(iy+OUSER+2)      ; = y

    ld      (iy+OUSER+3),a      ; keep X & Y around for various comparisons
    ld      (iy+OUSER+4),l
    ld      (iy+OUSER+5),h

    call    mulby600
    add     hl,de               ; hl = x + 600 * (y-1)
    ld      de,D_BUFFER
    add     hl,de

    xor     a

_loop:
    ld      (iy+OUSER),l        ; screen pointer
    ld      (iy+OUSER+1),h
    ld      (iy+OUSER+2),a      ; counter
    ld      d,h
    ld      e,l
    set     7,d
    res     6,d

    and     %00000110
    add     a,CH_STALACBASE
    call    char2dlist
    ld      (de),a
    inc     a
    ld      bc,600
    add     hl,bc
    call    char2dlist
    ex      de,hl
    add     hl,bc
    ld      (hl),a

    YIELD

    ld      l,(iy+OUSER+0)      ; restore screen pointers
    ld      h,(iy+OUSER+1)

    inc     (iy+OUSER+2)        ; only move when frame = 0
    ld      a,(iy+OUSER+2)
    and     7
    jr      nz,_loop

    ; move down and check to see if we've reached ground level.

    ld      bc,600              ; move down one line
    add     hl,bc
    push    hl
    inc     (iy+OUSER+5)
    ld      a,(iy+OUSER+5)
    cp      9
    jr      z,_sink

    add     hl,bc
    ld      d,h
    set     7,d
    res     6,d
    ld      e,l
    pop     hl
    ld      a,(de)              ; check to see if we're about to hit the ground
    and     a
    jr      z,_loop

_sink:
    xor     a

    ; 'sink' into the ground

_loop2:
    ld      (iy+OUSER),l        ; screen pointer
    ld      (iy+OUSER+1),h
    ld      (iy+OUSER+2),a      ; counter
    ld      d,h
    ld      e,l
    set     7,d
    res     6,d

    and     %00000110
    add     a,CH_STALACBASE
    call    char2dlist
    ld      (de),a

    YIELD

    ld      l,(iy+OUSER+0)      ; restore screen pointers
    ld      h,(iy+OUSER+1)

    inc     (iy+OUSER+2)
    ld      a,(iy+OUSER+2)
    and     7
    jr      nz,_loop2

    DIE
