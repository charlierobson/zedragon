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

    ld      a,4-1
    call    AFXPLAY

    ld      a,(subx)
    add     a,8
    srl     a
    srl     a
    srl     a
    ld      l,a
    ld      h,0
    ld      de,(scrollpos)
    add     hl,de
    ld      (bulletX),hl

    ld      hl,(subaddress)     ; we always draw bullet in front of sub
    inc     hl

    ld      a,(suby)
    
    bit     2,a
    jr      z,{+}

    ld      de,600              ; modify draw address if sub is > 7 pixels deep in 16 pix window
    add     hl,de

+:  add     a,4
    ld      (bulletY),a
    and     7
    ld      (bltyoff),a

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
    ld      d,h
    ld      e,l
    set     7,d
    res     6,d
    ld      a,(de)
    ld      (hl),a

    inc     hl                  ; calculate new position
    ld      (bltdrawaddr),hl

    ret     z                   ; all done if lifetime became 0

    ld      de,(bulletX)
    inc     de
    ld      (bulletX),de

    ld      de,$23f0            ; address of bullet buffer character, = char $bd
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

    cp      $90
    jr      c,bullethit        ; jump if blocking pixels detected under blt

+:  ld      a,b
    ld      (bltundrawchar),a
    ld      (hl),CH_BULLET
    ret


endmine:
    push    hl
    push    de

    ld      de,(bulletHitX)
    ld      hl,enemyidx
    add     hl,de
    ld      e,(hl)
    ld      d,enemydat / 256
    ex      de,hl
    set     BIT_INACT,(hl)

    pop     de
    pop     hl
    and     a
    ccf
    ret


bullethit:
    ; a has the hit character, hl is the screen address
    ; clear enemy from screen and mirror map
    and     $f0
    cp      $80
    jr      nz,{+}

    push    hl
    push    hl

    ld      (hl),0
    res     6,h                 ; point hl at mapcache in high memory
    set     7,h
    ld      (hl),0

    ; nullify mine
    ld      hl,endmine          ; mark enemy as dead
    call    findenemy

	call	getobject
	ld		bc,explosion
	call	initobject
	call	insertobject_afterthis
    pop     de
    ld      (hl),e
    inc     hl
    ld      (hl),d

	call	getobject
	ld		bc,chaindrop
	call	initobject
	call	insertobject_afterthis
    pop     de
    ld      (hl),e
    inc     hl
    ld      (hl),d

+:  ld      de,(bulletX)
    ld      (bulletHitX),de
    ld      a,(bulletY)
    ld      (bulletHitY),a

    xor     a                   ; deactivate bullet
    ld      (bltlife),a
    ret
