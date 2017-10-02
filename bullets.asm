bulletinfo:
    .byte   $20,0,0,0

startbullet:
    ld      a,(subx)
    add     a,12
    srl     a
    srl     a
    srl     a
    ld      (bulletinfo),a
    ld      a,(suby)
    add     a,4
    ld      (bulletinfo+1),a
    ret

updatebullets:
    ld      a,(bulletinfo)
    cp      32
    ret     z

    inc     a
    ld      (bulletinfo),a
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

    ld      a,(bulletinfo+1)
    and     7
    srl     a
    add     a,$B0
    ld      (hl),a
    ld      hl,(bulletinfo+2)
    xor     a
    ld      (hl),a
    ld      (bulletinfo+2),hl
    ret
