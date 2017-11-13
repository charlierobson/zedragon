;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module BULLET
;
    .align  8
_obdata:
    .byte   %11111111
    .byte   %01111111
    .byte   %00111111
    .byte   %00011111
    .byte   %00001111
    .byte   %00000111
    .byte   %00000011
    .byte   %00000001

bulletCount:
    .byte   0


startOBullet:
    ld      bc,obullet
    call    getobject
    call    initobject
    call    insertobject_afterthis
    ret


obullet:
    ld      a,18

    ld      hl,bulletCount
    inc     (hl)

_loop:
    ld      (iy+OUSER+10),a
    and     7
    ld      hl,_obdata
    or      l
    ld      l,a
    ld      a,(hl)
    ld      (iy+OUSER+11),a         ; cache mask

    ld      a,0 ;(hl)                  ; get character out of mirror map
    ld      de,$23b0
    call    copychar
    ld      a,0 ;(hl)                  ; get character out of mirror map
    ld      de,$23b8
    call    copychar

    ld      a,(iy+OUSER+11)
    xor     $ff
    ld      b,a
    ld      a,($23b0)
    and     b
    ld      ($23b0),a

    ld      a,(iy+OUSER+11)
    ld      b,a
    ld      a,($23b8)
    and     b
    ld      ($23b8),a

    ld      hl,(scrollpos)
    ld      a,(iy+OUSER+10)         ; pixel x pos
    and     $f8
    rrca                            ; / 8
    rrca
    rrca
    add     a,l
    ld      l,a
    jr      nc,{+}
    inc     h
+:  ld      a,3                     ; y character
    call    mulby600
    add     hl,de
    ld      de,D_BUFFER
    add     hl,de
    ld      (hl),$b6
    inc     hl
    ld      (hl),$b7

    YIELD

    ld      a,(iy+OUSER+10)
    inc     a
    jr      nc,_loop

    ld      hl,bulletCount
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
