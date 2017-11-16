;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module BULLET
;

O_PIXX = OUSER+0
O_PIXY = OUSER+1
O_MASK = OUSER+2
O_SPEED = OUSER+3
O_LCOLB = OUSER+4
O_RCOLB = OUSER+5
O_LCHAR = OUSER+6
O_RCHAR = OUSER+7
O_UNDRAW = OUSER+8

    .align  16
bchar:
    .fill   16

obullet:
    ld      (iy+O_SPEED),0

    ld      a,(iy+O_PIXY)
    add     a,4
    ld      (iy+O_PIXY),a

    ld      a,(iy+O_PIXX)
    add     a,12

    ld      hl,bulletCount
    inc     (hl)

_loop:
    ; calculate pixel mask

    ld      (iy+O_PIXX),a       ; pixel x offset
    push    af
    and     7
    ld      hl,obdata
    or      l
    ld      l,a
    ld      a,(hl)
    ld      (iy+O_MASK),a       ; cache mask

    ; calculate display position

    pop     af                  ; recover x pixel pos
    ld      hl,(scrollpos)
    and     $f8                 ; remove bottom 3 bits b/c rolling
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
    set     7,h                 ; point at background character in mirror map
    res     6,h

    ld      de,bchar            ; copy characters into bullet render buffer
    push    de                  ; stash pointer
    call    copychar
    ld      (iy+O_LCHAR),a      ; left character
    call    copychar
    ld      (iy+O_RCHAR),a      ; right character

    ; source character data is inverted, as we only write into UDGs $80-$c0

    ld      a,(iy+O_PIXY)       ; vertical offset into bullet character
    and     7
    pop     de                  ; recover character data pointer
    or      e
    ld      e,a

    ld      a,(iy+O_MASK)       ; '00011111' for example, when bullet is at (x & 7) == 3
    ld      c,a                 ; stash mask
    xor     $ff                 ; why not store the mask inverted? you'll see .. ;)
    ld      b,a                 ; '11100000'

    ld      a,(de)              ; character bits - clear bits are black on-screen
    ld      l,a
    and     b
    ld      (de),a

    ld      a,l                 ; calculate left collision bits
    xor     $ff
    and     c
    ld      (iy+O_LCOLB),a      ; leave collided bits here for a minute

    ld      a,e                 ; next character address
    or      8
    ld      e,a

    ld      a,(de)
    ld      l,a
    and     c                   ; '11100000' - the inverted mask is the remainder of the 8 pixel bullet
    ld      (de),a

    ld      a,l                 ; calculate right collision bits
    xor     $ff
    and     b
    ld      (iy+O_RCOLB),a

    ; all rendered.

    ld      l,(iy+O_UNDRAW)     ; undraw trailing character of bullet
    ld      h,(iy+O_UNDRAW+1)
    push    hl
    set     7,h
    res     6,h
    ld      a,(hl)
    pop     hl
    ld      (hl),a

    pop     hl                  ; recover latest address
    ld      (bullet1sp),hl
    ld      (hl),$b6
    ld      (iy+O_UNDRAW),l     ; stash current address as last undraw
    ld      (iy+O_UNDRAW+1),h
    inc     hl
    ld      (hl),$b7
    ld      (bullet2sp),hl

    YIELD

    ; when we arrive back here the previously rendered bullet will be on screen

    ld      a,(iy+O_LCHAR)
    ld      de,TOP_LINE+4
    call    hexout
    ld      a,(iy+O_LCOLB)
    ld      de,TOP_LINE+7
    call    hexout
    ld      a,(iy+O_RCHAR)
    ld      de,TOP_LINE+10
    call    hexout
    ld      a,(iy+O_RCOLB)
    ld      de,TOP_LINE+13
    call    hexout

;    ld      a,(iy+O_SPEED)
;    cp      28
;    jr      z,{+}
;
;    inc     a
;    ld      (iy+O_SPEED),a
;
;+:  srl     a
;    srl     a
;    add     a,(iy+O_PIXX)       ; until new position is off screen right
    ld      a,(advance)
    cp      1
    ld      a,(iy+O_PIXX)
    jp      nz,_loop
    inc     a
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
    ret
