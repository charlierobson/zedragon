bulletinfo:
    .byte   0,0,0,0

startbullet:
    ld      a,(subx)
    add     a,12
    ld      (bulletinfo),a
    ld      a,(suby)
    add     a,6
    ld      (bulletinfo+1),a
    ret

updatebullets:
    ld      a,(bulletinfo)
    and     a
    ret     z

    inc     a
    ld      (bulletinfo),a
    srl     a
    srl     a
    srl     a
    ld      l,a
    ld      h,0

    ld      de,(scrollpos)
    add     hl,de
    ld      de,D_BUFFER
    add     hl,de

    ld      a,(bulletinfo+1)
    srl     a
    srl     a
    srl     a
    call    mulby600        ; de = a * 600
    add     hl,de

    ld      a,$B0
    ld      (hl),a
    ret
