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

    jr      nz,bullethit        ; jump if pixels detected under blt

    ld      (bltundrawchar),a
    ld      a,$be
    ld      (hl),a
    ret


bullethit:
    ; a has the hit character, hl is the screen address
    and     $f0
    cp      $30
    jr      nz,{+}

    ; clear enemy from screen and mirror map
    ld      (hl),0
    push    hl
    res     6,h                 ; point hl at mapcache in high memory
    set     7,h
    ld      (hl),0
    push    hl

    ; clear tether if there is one
    pop     de
    call    undrawchain
    pop     de
    call    undrawchain

+:  xor     a                   ; deactivate
    ld      (bltlife),a
    ret
