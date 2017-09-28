drawsub:
    ld      hl,(lastsubpos)
    xor     a
    ld      (hl),a
    inc     hl
    ld      (hl),a

    ld      hl,D_BUFFER
    ld      de,(scrollpos)
    add     hl,de
    ld      de,(subpos)
    add     hl,de
    ld      (lastsubpos),hl

    ld      a,$be
    ld      (hl),a
    inc     hl
    inc     a
    ld      (hl),a
    ret


movesub:
    ld      a,(up)
    ld      de,-600
    cp      1
    call    z,move

    ld      a,(down)
    ld      de,600
    cp      1
    call    z,move

    ld      a,(left)
    ld      de,-1
    cp      1
    call    z,move

    ld      a,(right)
    ld      de,1
    cp      1
    ret     nz

move:
    ld      hl,(subpos)
    add     hl,de
    ld      (subpos),hl
    ret
