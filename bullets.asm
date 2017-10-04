bulletinfo:
    .byte   0,0,0,0,0,0,0

startbullet:
    ld      a,(bulletinfo+2)
    or      a
    ret     nz

    ld      (bulletinfo+6),a

    ld      a,(subx)            ; start bullet in front of sub
    add     a,16
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
    add     a,5
    srl     a
    srl     a
    srl     a
    call    mulby600
    add     hl,de
    ld      (bulletinfo),hl

    ld      a,(subx)            ; work out bullet maximum lifespan
    add     a,16
    neg
    srl     a
    srl     a
    srl     a
    ld      (bulletinfo+2),a

    ld      a,(suby)            ; work out bullet y offset
    add     a,5
    and     7
    ld      (bulletinfo+3),a

    ret


updatebullets:
    ld      a,(bulletinfo+2)    ; bail if bullet not active
    and     a
    ret     z

    dec     a                   ; bullet lives another day?
    ld      (bulletinfo+2),a

    ld      hl,(bulletinfo)     ; remove old bullet
    ld      a,(bulletinfo+6)
    ld      (hl),a

    inc     hl                  ; calculate new position
    ld      (bulletinfo),hl

    ret     z                   ; all done if lifetime became 0

    ld      de,$23f0
    call    copychar
    ld      a,(bulletinfo+3)
    add     a,$f0
    ld      l,a
    ld      h,d

    ld      a,(hl)              ; see what's on screen under the bullet
    ld      (hl),0              ; then draw the bullet
    cp      $ff
    jr      nz,{+}              ; jump if pixels detected under bullet

    ld      hl,(bulletinfo)     ; draw our freshly rendered bullet + bg
    ld      a,(hl)
    ld      (bulletinfo+6),a
    ld      a,$be
    ld      (hl),a
    ret

+:  xor     a                   ; deactivate
    ld      (bulletinfo+2),a
    ret
