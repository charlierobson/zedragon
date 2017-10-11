bltdrawaddr:
    .word   0
bltundrawchar:
    .byte   0
bltlife:
    .byte   0
bltyoff:
    .byte   0

startbullet:
    ld      a,(bltlife)
    or      a
    ret     nz

    ld      hl,(subaddress)     ; we always draw bullet in front of sub
    inc     hl

    ld      a,(suby)
    
    bit     2,a
    jr      z,{+}

    ld      de,600              ; modify draw address if sub is > 7 pixels deep in 16 pix window
    add     hl,de

+:  add     a,4
    and     7
    ld      (bltyoff),a

    ld      a,(hl)
    ld      (bltundrawchar),a   ; save sub's char as 1st undraw
    ld      (bltdrawaddr),hl    ; where bullet got drawn

    ld      a,(subx)            ; work out blt maximum lifespan
    add     a,16
    neg
    srl     a
    srl     a
    srl     a
    ld      (bltlife),a

    ret


updatebullets:
    ld      a,(bltlife)    ; bail if blt not active
    and     a
    ret     z

    dec     a                   ; blt lives another day?
    ld      (bltlife),a

    ld      hl,(bltdrawaddr)    ; remove old blt
    ld      a,(bltundrawchar)
    ld      (hl),a

    inc     hl                  ; calculate new position
    ld      (bltdrawaddr),hl

    ret     z                   ; all done if lifetime became 0

    ld      de,$23f0
    call    copychar
    ld      a,(bltyoff)
    add     a,$f0
    ld      l,a
    ld      h,d

    ld      a,(hl)              ; see what's on screen under the bullet
    ld      (hl),0              ; then draw the blt
    cp      $ff

    ld      hl,(bltdrawaddr)    ; fetch the character that the bullet hit
    ld      a,(hl)
    ld      b,a
    jr      z,{+}

    and     $f0
    cp      $30
    jr      nz,bullethit        ; jump if blocking pixels detected under blt

+:  ld      a,b
    ld      (bltundrawchar),a
    ld      a,$be
    ld      (hl),a
    ret


bullethit:
    ; a has the hit character, hl is the screen address
    ; clear enemy from screen and mirror map
    cp      $20
    jr      nz,{+}

    ld      (hl),0
    call    explode_start
    call    chaindrop_start
    res     6,h                 ; point hl at mapcache in high memory
    set     7,h
    ld      (hl),0

+:  xor     a                   ; deactivate
    ld      (bltlife),a
    ret


chaindrop_start:
    call    findfnslot
    ret     nz
    ld      de,chaindrop_impl
    ld      (iy+1),e
    ld      (iy+2),d
    ld      (iy+3),l
    ld      (iy+4),h
    xor     a
    ld      (iy+5),a
    ret

chaindrop_impl:
    inc     (iy+5)
    bit     1,(iy+5)
    ret     z

    ld      e,(iy+3)
    ld      d,(iy+4)

    ld      a,$58           ; de += 600
    add     a,e
    ld      e,a
    ld      a,$02
    adc     a,d
    ld      d,a

    ld      a,(de)          ; if (de) == 0, make (de) = $22, else done
    cp      CH_CHAIN
    jp      nz,fnstop

    ld      (iy+3),e
    ld      (iy+4),d
    xor     a
    ld      (de),a
    set     7,d
    res     6,d
    ld      (de),a
    ret



explode_start:
    call    findfnslot
    ret     nz

    ld      de,explode_impl
    ld      (iy+1),e
    ld      (iy+2),d
    ld      (iy+3),l
    ld      (iy+4),h
    xor     a
    ld      (iy+5),a
    ret


explode_impl:
    ld      l,(iy+3)
    ld      h,(iy+4)
    ld      a,(iy+5)
    inc     a
    ld      (iy+5),a
    cp      24
    jr      nc,{+}

    sra     a
    sra     a
    add     a,CH_EXPLODEBASE
    ld      (hl),a
    ret

+:  ld      (hl),0
    jp      fnstop
