bulletinfo:
    .byte   0,0,0,0,0


startbullet:
    ld      a,(subx)
    srl     a
    srl     a
    srl     a
    ld      l,a
    ld      h,0
    ld      de,D_BUFFER
    add     hl,de
    ld      de,(scrollpos)
    add     hl,de
    ld      a,(suby)
    add     a,4
    srl     a
    srl     a
    srl     a
    call    mulby600
    add     hl,de
    ld      (bulletinfo),hl

    ld      a,(subx)
    add     a,10
    neg
    srl     a
    srl     a
    srl     a
    ld      (bulletinfo+2),a    ; max lifetime for bullet

    ld      a,(suby)
    add     a,4
    and     7
    srl     a
    add     a,$b0
    ld      (bulletinfo+3),a
    ret


updatebullets:
    ld      a,(bulletinfo+2)
    and     a
    ret     z
    dec     a
    ld      (bulletinfo+2),a

    ld      hl,(bulletinfo)      ; xpos
    xor     a
    ld      (hl),a
    inc     hl
    ld      (bulletinfo),hl

    ld      a,(bulletinfo+3)
    ld      (hl),a
    ret
