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
_SCRPOSL = OUSER+10
_SCRPOSH = OUSER+11
_WORLDXL = OUSER+12
_WORLDXH = OUSER+13

    .align  16
bchar:
    .fill   16

_tempnmecolpos:
    .word   0
_tempbltx:
    .word   0

enemycollision:
    .word   0

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
+:  ld      (iy+_WORLDXL),l
    ld      (iy+_WORLDXH),h

    ld      a,(iy+_PIXY)       ; calculate y character
    and     $f8
    rrca
    rrca
    rrca
    call    mulby600
    add     hl,de               ; char to screen pos
    ld      de,D_BUFFER
    add     hl,de
    ld      (iy+_SCRPOSL),l
    ld      (iy+_SCRPOSH),h

    set     7,h                 ; point at background character in mirror map
    res     6,h

    call    allocbrender        ; get 'pointer to bullet udg' slot in de
    push    de                  ; stash for rendering
    ld      (iy+_BCHAR),a       ; store returned character number
    call    copychar
    ld      (iy+_LCHAR),a      ; left character that we'll overwrite, store for collision
    call    copychar
    ld      (iy+_RCHAR),a      ; right character

    ; source character data is pre-inverted, as we only write into UDGs $80-$c0

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

    ld      l,(iy+_SCRPOSL)
    ld      h,(iy+_SCRPOSH)

    ld      (bullet1sp),hl      ; stash the bullet screen location for sub rendering ... na-a-sty
    ld      a,(iy+_BCHAR)
    call    char2dlist
    inc     hl
    inc     a
    call    char2dlist
    ld      (bullet2sp),hl

    dec     hl
    ld      (_tempnmecolpos),hl
    ld      e,(iy+_WORLDXL)
    ld      d,(iy+_WORLDXH)
    ld      (_tempbltx),de

    ld      c,(iy+_LCHAR)
    ld      a,(iy+_LCOLB)
    and     a
    call    nz,_collisioncheck

    ld      a,(iy+_PIXX)                ; no need to check forward part if x mod 7 = 0
    and     7
    jr      z,_coldone

    ld      a,(iy+_RCOLB)
    and     a
    jr      z,_coldone

    ld      hl,(_tempnmecolpos)
    inc     hl
    ld      (_tempnmecolpos),hl
    ld      e,(iy+_WORLDXL)
    ld      d,(iy+_WORLDXH)
    inc     de
    ld      (_tempbltx),de
    ld      c,(iy+_RCHAR)
    call    _collisioncheck

_coldone:
    dec     (iy+_COLNF)
    jr      z,_bulletdie

    YIELD

;    ld      hl,collisionstore       ; should only reset collision store once per frame.
;    dec     (hl)
;    call    z,resetcollisionstore   ; if we've made the flag = 0 then reset the store

    ld      a,(iy+_SPEED)
    cp      28
    jr      z,{+}

    inc     a
    ld      (iy+_SPEED),a

+:  srl     a
    srl     a
    add     a,(iy+_PIXX)       ; until new position is off screen right
    jp      nc,_loop

    ; off screen or collided, stop

_bulletdie:
    ld      hl,0                ; don't render me no more bro
    ld      (bullet1sp),hl
    ld      (bullet2sp),hl

    ld      hl,bulletCount      ; die
    dec     (hl)

    ; leave collision info in place for testers

    YIELD

    ; delete bullet collision info

    ld      hl,0
    ld      (bulletHitX),hl

    DIE


_collisioncheck:
    ld      (iy+_COLNF),0 

    ld      a,c

    cp      $90
    ret     nc                  ; collided with a 'no collision' character, carry on

    ld      (iy+_COLNF),1       ; indicate that we've collided with something solid

    cp      $30
    ret      c                  ; we've hit scenery, just stop

    ; enemy, probably

    ld      de,(_tempbltx)      ; there should be an enemy at this X
    call    getenemy
    cp      $ff
    ret     z

    and     $80                 ; is enemy dormant
    jr      z,{+}

    ld      hl,(_tempbltx)      ; there was something, but what? most likely an active enemy
    ld      (bulletHitX),hl
    ld      a,(iy+_PIXY)
    ld      (bulletHitY),a
    ret

+:  set     7,(hl)              ; kill enemy

    ld      bc,1
    call    addscore

    ld      hl,(_tempnmecolpos)
    push    hl                  ; stash for explosion
    set     7,h
    res     6,h
    ld      a,(hl)              ; note what we're overwriting
    ld      (hl),0              ; zero enemy site in mirror
    push    af
    call    startexplosion      ; start an explosion
    pop     af
    ex      de,hl
    pop     de
    ld      (hl),e
    inc     hl
    ld      (hl),d

    cp      CH_MINE             ; did we just pop a mine?
    ret     nz

    ; mine popped, so potentially drop the chain

    push    de
    call    getobject
    ld      bc,chaindrop
    call    initobject
    call    insertobject_afterhead

    ex      de,hl
    pop     de
    ld      (hl),e
    inc     hl
    ld      (hl),d

    ret



startexplosion:
    call    getobject
    ld      bc,explosion
    call    initobject
    jp      insertobject_afterhead



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
