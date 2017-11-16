;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module BULLET
;

_PIXX = OUSER+0
_PIXY = OUSER+1
_MASK = OUSER+2
_SPEED = OUSER+3
_LCOLB = OUSER+4
_RCOLB = OUSER+5
_LCHAR = OUSER+6
_RCHAR = OUSER+7
_BCHAR = OUSER+8
_COLNF = OUSER+9
_UNDRAW = OUSER+10

    .align  16
bchar:
    .fill   16

allocbrender:
    ld      de,bchar
    ld      a,$b6
    ret


obullet:
    ld      (iy+_SPEED),0

    ld      a,(iy+_PIXY)
    add     a,4
    ld      (iy+_PIXY),a

    ld      a,(iy+_PIXX)
    add     a,12

    ld      hl,bulletCount
    inc     (hl)

_loop:
    ; calculate pixel mask

    ld      (iy+_PIXX),a       ; pixel x offset
    push    af
    and     7
    ld      hl,obdata
    or      l
    ld      l,a
    ld      a,(hl)
    ld      (iy+_MASK),a       ; cache mask

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
+:  ld      a,(iy+_PIXY)       ; calculate y character
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

    call    allocbrender        ; get pointer to bullet udg slot in de
    push    de                  ; stash for rendering
    ld      (iy+_BCHAR),a       ; store returned character number
    call    copychar
    ld      (iy+_LCHAR),a      ; left character
    call    copychar
    ld      (iy+_RCHAR),a      ; right character

    ; source character data is inverted, as we only write into UDGs $80-$c0

    ld      a,(iy+_PIXY)       ; vertical offset into bullet character
    and     7
    pop     de                  ; recover character data pointer
    or      e
    ld      e,a

    ld      a,(iy+_MASK)       ; '00011111' for example, when bullet is at (x & 7) == 3
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
    ld      (iy+_LCOLB),a      ; leave collided bits here for a minute

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
    ld      (iy+_RCOLB),a

    ; all rendered.

    ld      l,(iy+_UNDRAW)     ; undraw trailing character of bullet
    ld      h,(iy+_UNDRAW+1)
    push    hl
    set     7,h
    res     6,h
    ld      a,(hl)
    pop     hl
    ld      (hl),a

    pop     hl                  ; recover latest address
    ld      (bullet1sp),hl
    ld      a,(iy+_BCHAR)
    ld      (hl),a
    ld      (iy+_UNDRAW),l     ; stash current address as last undraw
    ld      (iy+_UNDRAW+1),h
    inc     hl
    inc     a
    ld      (hl),a
    ld      (bullet2sp),hl

    YIELD

    ; when we arrive back here the previously rendered bullet will be on screen

    ld      c,(iy+_RCHAR)
    ld      a,(iy+_RCOLB)
    or      a
    call    nz,_collisioncheck

    dec     (iy+_COLNF)
    jr      z,_bulletdie

    ld      a,(iy+_SPEED)
    cp      8 ;28
    jr      z,{+}

    inc     a
    ld      (iy+_SPEED),a

+:  srl     a
    srl     a
    add     a,(iy+_PIXX)       ; until new position is off screen right
    jp      nc,_loop

    ; off screen or collided, stop

_bulletdie:
    ld      l,(iy+_UNDRAW)     ; undraw both bullet chars
    ld      h,(iy+_UNDRAW+1)
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


_collisioncheck:
    ld      (iy+_COLNF),0

    ld      a,c
    or      a
    ret     z

    cp      $30
    jr      nc,_testenemy

    ld      l,(iy+_UNDRAW)     ; remove enemy and bullet from mirror
    ld      h,(iy+_UNDRAW+1)
    inc     hl
    push    hl
    call    startexplosion      ; start an explosion
    pop     de
    ld      (hl),e
    inc     hl
    ld      (hl),d
    inc     (iy+_COLNF)
    ret

_testenemy:
    ld      a,(iy+_PIXX)        ; convert pixel x of torpedo tip to map character x
    add     a,7
    and     $f8
    rrca
    rrca
    rrca
    ld      de,(scrollpos)
    ADD_DE_A
    call    getenemy
    and     a
    ret     m

    and     $0f                 ; enemy Y
    ld      e,a

    ld      a,(iy+_PIXY)        ; convert pixel y of torpedo to map row
    and     $f8
    rrca
    rrca
    rrca
    cp      e
    ret     nz

    set     7,(hl)              ; kill enemy

    ld      l,(iy+_UNDRAW)     ; remove enemy and bullet from mirror
    ld      h,(iy+_UNDRAW+1)
    set     7,h
    res     6,h
    ld      (hl),0
    inc     hl
    ld      (hl),0

    inc     (iy+_COLNF)
    ret



startexplosion:
	call	getobject
	ld		bc,explosion
	call	initobject
	jp      insertobject_afterthis



getenemy:
    ld      hl,enemyidx
    add     hl,de
    ld      a,(hl)
    cp      $ff
    ret     z
    ld      h,enemydat/256
    ld      l,a
    ld      a,(hl)
    ret


_dispcolls:
    ld      a,(iy+_LCHAR)
    ld      de,TOP_LINE+4
    call    hexout
    ld      a,(iy+_LCOLB)
    ld      de,TOP_LINE+7
    call    hexout
    ld      a,(iy+_RCHAR)
    ld      de,TOP_LINE+10
    call    hexout
    ld      a,(iy+_RCOLB)
    ld      de,TOP_LINE+13
    jp      hexout
