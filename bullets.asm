;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module BULLET
;

O_PIXX = OUSER+0
O_PIXY = OUSER+1
O_MASK = OUSER+2
O_UNDRAW = OUSER+3

obullet:
    ld      a,(iy+O_PIXY)
    add     a,6
    ld      (iy+O_PIXY),a

    ld      a,(iy+O_PIXX)
    add     a,16

    ld      hl,bulletCount
    inc     (hl)

_loop:
    ld      (iy+O_PIXX),a       ; calculate pixel mask using pixel x offset
    push    af                  ; stash x pixel pos
    and     7
    ld      hl,obdata
    or      l
    ld      l,a
    ld      a,(hl)
    ld      (iy+O_MASK),a       ; cache mask

    ; target display position
    pop     af                  ; recover x pixel pos
    ld      hl,(scrollpos)
    and     $f8
    rrca                        ; / 8
    rrca
    rrca
    add     a,l
    ld      l,a
    jr      nc,{+}
    inc     h
+:  ld      a,(iy+O_PIXY)       ; calculate y character
    and     $f8
    rrca
    rrca
    rrca
    call    mulby600
    add     hl,de               ; char to screen pos
    ld      de,D_BUFFER
    add     hl,de
    push    hl                  ; stash draw address
    set     7,h                 ; get character out of mirror map
    res     6,h
    ld      a,(hl)

_scalc:
    ld      a,(gameframe)       ; $23b0/b8 even frames, $23f0/f8 odd
    and     1
    ld      e,$b0
    jr      z,_cf0
    ld      e,$f0
_cf0:
    ld      d,$23
    push    de
    push    hl

    call    copychar
    pop     hl
    inc     hl
    call    copychar

    ld      a,(iy+O_PIXY)
    and     7
    pop     de
    or      e
    ld      e,a

    ld      a,(iy+O_MASK)
    push    af                  ; save pixel mask
    xor     $ff
    ld      b,a
    ld      a,(de)
    and     b
    ld      (de),a

    pop     bc                  ; recover pixel mask
    ld      a,e                 ; next character address
    or      8
    ld      e,a
    ld      a,(de)
    and     b
    ld      (de),a

    ld      l,(iy+O_UNDRAW)     ; undraw trailing character of bullet
    ld      h,(iy+O_UNDRAW+1)
    push    hl
    set     7,h
    res     6,h
    ld      a,(hl)
    pop     hl
    ld      (hl),a

    ld      a,(gameframe)       ; $b6/b7 on even frames, $be/bf
    and     1
    ld      a,$b6
    jr      z,_cf1
    ld      a,$be
_cf1:
    pop     hl                  ; recover latest address
    ld      (hl),a
    ld      (iy+O_UNDRAW),l     ; stash current address as last undraw
    ld      (iy+O_UNDRAW+1),h
    inc     hl
    inc     a
    ld      (hl),a

    YIELD

    ld      a,(iy+O_PIXX)       ; new position is off screen right
    add     a,1
    jp      nc,_loop

    ld      l,(iy+O_UNDRAW)     ; undraw both bullet chars
    ld      h,(iy+O_UNDRAW+1)
    push    hl
    set     7,h
    res     6,h
    ld      a,(hl)
    inc     hl
    ld      b,(hl)
    pop     hl
    ld      (hl),a
    inc     hl
    ld      (hl),b

    ld      hl,bulletCount      ; die
    dec     (hl)

    DIE


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

    ld      a,(000000)
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

    ld      a,(000000)
    
    bit     2,a
    jr      z,{+}

    ld      de,600              ; modify draw address if sub is > 7 pixels deep in 16 pix window
    add     hl,de

+:  add     a,4
    ld      (bulletY),a
    and     7
    ld      (bltyoff),a

    ld      (bltdrawaddr),hl    ; where bullet got drawn

    ld      a,(00000)            ; work out blt maximum lifespan
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

    ld      de,$2370            ; address of bullet buffer character, = char $ae
    call    copychar
    ld      a,(bltyoff)
    add     a,$2370 & $ff
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
