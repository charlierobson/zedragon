;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
    .module SUB
;

_SUBX = OUSER+0          ; don't change
_SUBY = OUSER+1          ; don't change
_SCRADL = OUSER+2
_SCRADH = OUSER+3
_COLO = OUSER+4
_ROWO = OUSER+5
_COLLTAB = OUSER+6
_EXPLOCT = OUSER+6      ; overloads follow
_WAIT = OUSER+7

;;#include "testfns.asm"

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
; The submarine object.
;

subfunction:
submvfunc = $+1
    call    playermovesub       ; listen to controls by default, can be changed though

    ; calculate address of sub in the map, relative to the current scroll position

_drawsub:
    ld      a,(iy+_SUBX)        ; pixel -> char conversion
    srl     a
    srl     a
    srl     a
    ld      l,a
    ld      h,0

    ld      de,(scrollpos)
    add     hl,de

    ld      (subcharx),hl       ; expose this for the enemies

    ld      a,(iy+_SUBY)        ; div by 8 to get character line then mul by 600
    srl     a
    srl     a
    srl     a
    call    mulby600            ; de = a * 600
    add     hl,de               ; character offset relative to visible window

    ld      de,D_BUFFER
    add     hl,de

    ld      (iy+_SCRADL),l      ; sub's address in the display memory
    ld      (iy+_SCRADH),h

    ; find the character codes that appear under the sub in its new position
    ; use the map cache as the code source because the display is dirty at this point
    ; copy the pixel data corresponding to the characters under the sub
    ; to a cache of 6x8 bytes - effectively a tiny bitmap
    ;
    ; on-screen:  $b0 $b2 $b4
    ;             $b1 $b3 $b5
    ;
    ; it's arranged like this because the rendering of the sub char is
    ; easier using columns, even if it makes other things harder.

    res     6,h                 ; point hl at mapcache in high memory
    set     7,h                 ; hl is source pointer for character data
    push    hl

    ld      de,charcache        ; b0
    call    copycharx
    ld      (iy+_COLLTAB),a     ; collision index 0, store character code

    ld      de,charcache+16     ; ... char b2
    call    copycharx
    ld      (iy+_COLLTAB+4),a   ; coll. idx. 2

    ld      de,charcache+32     ; b4
    call    copycharx
    ld      (iy+_COLLTAB+8),a   ; c.i. 4

    pop     hl
    ld      bc,600
    add     hl,bc

    ld      de,charcache+8      ; b1
    call    copycharx
    ld      (iy+_COLLTAB+2),a   ; c.i 1 

    ld      de,charcache+24     ; b3
    call    copycharx
    ld      (iy+_COLLTAB+6),a   ; c.i 3

    ld      de,charcache+40     ; b5
    call    copycharx
    ld      (iy+_COLLTAB+10),a  ; c.i 5

    xor     a                   ; zero out collision bits
    ld      (iy+_COLLTAB+1),a
    ld      (iy+_COLLTAB+3),a
    ld      (iy+_COLLTAB+5),a
    ld      (iy+_COLLTAB+7),a
    ld      (iy+_COLLTAB+9),a
    ld      (iy+_COLLTAB+11),a

    ld      a,_COLLTAB+1
    ld      (iy+_COLO),a

    ; now we've effectively built our tiny bitmap and cleared out the collision bits,
    ; we can render the sub into it and collect any collision pixels
    ;
    ; choose which set of 3 pre-scrolled sub tiles to use.

    ld      a,(iy+_SUBX)        ; pixel offset 0..7
    and     7
    ld      c,a
    add     a,a
    add     a,c                 ; * 3, a is offset to set of 3 characters

    sla     a
    sla     a
    sla     a                   ; * 8, a is offset to 1st byte of sub char data 

    ; get pointers to sub pixel data within the character set

    ld      h,subpix / 256      ; form address in character set $22xx
    ld      l,a

    ld      de,charcache        ; pointer to 1st byte within column of 16 rows inside mini bitmap
    ld      a,(iy+_SUBY)        ; that we will render to
    and     7
    or      e
    ld      e,a

    ld      b,3                 ; 3 characters

_rendersub:
    push    bc

    ; copy 8 sub pixels into bg bitmap

    ld      b,8             ; 8 lines

    ld      a,(iy+_SUBY)   ; keep track of the row number that we're rendering into,
    and     7               ; so that we can track collision data on a per character cell basis
    ld      (iy+_ROWO),a

    ld      a,(iy+_COLO)   ; init collision indices
    ld      (colidx1),a
    ld      (colidx2),a

_column:
    ld      c,(hl)          ; get sub pixels
    ld      a,(de)          ; get bg pixels
    push    af
    and     c               ; merge sub into background
    ld      (de),a

    pop     af              ; get bg pixels
    or      c               ; or together
    xor     $ff             ; any 0 bits are collisions
    ld      c,a

colidx1 = $+2
colidx2 = $+6
    ld      a,(iy+0)        ; update collision bits for this background cell
    or      c
    ld      (iy+0),a

    ld      a,(iy+_ROWO)   ; when rendering hits row 8 bump collision data index
    inc     a
    ld      (iy+_ROWO),a
    cp      8
    jr      nz,{+}

    ld      a,(colidx1)
    inc     a
    inc     a
    ld      (colidx1),a
    ld      (colidx2),a

+:
    inc     hl
    inc     de
    djnz    _column

    ; step across the dest bitmap to the next column
    ; we know the address won't overflow the bottom 8 bits

    ld      a,8
    add     a,e
    ld      e,a

    ld      a,(iy+_COLO)  ; iy+ouser progression: +1, (+3), +5, (+7), +9, (+11)
    inc     a
    inc     a
    inc     a
    inc     a
    ld      (iy+_COLO),a

    pop     bc
    djnz    _rendersub

    ; all rendered. now draw the min i bitmap containing the sub to the screen
    ; b0 b2 b4
    ; b1 b3 b5

    ld      e,(iy+_SCRADL)
    ld      d,(iy+_SCRADH)
    ld      hl,(dlp)
    ld      (hl),e
    inc     hl
    ld      (hl),d
    inc     hl
    ld      (hl),$b0
    inc     hl
    inc     de
    ld      (hl),e
    inc     hl
    ld      (hl),d
    inc     hl
    ld      (hl),$b2
    inc     hl
    inc     de
    ld      (hl),e
    inc     hl
    ld      (hl),d
    inc     hl
    ld      (hl),$b4
    inc     hl

    ld      a,(iy+_SUBY)
    cp      $47
    jr      nc,_nosecondline

    push    hl
    ld      hl,600-2
    add     hl,de
    ex      de,hl
    pop     hl

    ld      (hl),e
    inc     hl
    ld      (hl),d
    inc     hl
    ld      (hl),$b1
    inc     hl
    inc     de
    ld      (hl),e
    inc     hl
    ld      (hl),d
    inc     hl
    ld      (hl),$b3
    inc     hl
    inc     de
    ld      (hl),e
    inc     hl
    ld      (hl),d
    inc     hl
    ld      (hl),$b5
    inc     hl

_nosecondline:
    ld      (dlp),hl

    YIELD

    ld      d,_COLLTAB
    ld      e,_COLLTAB+1
    ld      b,6

_checkcoll:
    ld      a,d
    ld      (chkidx1),a
    ld      a,e
    ld      (chkidx2),a

chkidx1 = $+2
chkidx2 = $+5
    ld      c,(iy+0)                ; character cell content
    ld      a,(iy+0)                ; pixel collision data
    and     a                       ; clears carry
    call    nz,_testcollision        ; test the collision
    jr      c,_subdead

    inc     d
    inc     d
    inc     e
    inc     e
    djnz    _checkcoll

    ld      a,(collision)
    and     a
    ld      a,(iy+_SUBY)
    call    z,updateair
    ld      a,(airlevel)
    or      a
    jp      nz,subfunction

    ; sub is dead, explo-o-o-o-ode

_subdead:
    ld      a,1
    ld      (collision),a

    ; trigger some explosions

    ld      (iy+_EXPLOCT),6
    ld      hl,explooff
    ld      a,(FRAMES)
    and     6
    add     a,l
    ld      l,a
    adc     a,h
    sub     l
    ld      h,a

_subsubexplo:
    ld      e,(hl)
    inc     hl
    ld      d,(hl)
    inc     hl
    ld      (iy+_COLO),l
    ld      (iy+_COLO+1),h

    ld      l,(iy+_SCRADL)
    ld      h,(iy+_SCRADH)
    add     hl,de
    push    hl

    ld      bc,explosion
    call    objectafterthis

    ex      de,hl
    pop     de
    ld      (hl),e
    inc     hl
    ld      (hl),d

    ld      a,r
    and     3
    add     a,5
    ld      (iy+_WAIT),a

-:  YIELD
    dec     (iy+_WAIT)
    jr      nz,{-}

    ld      l,(iy+_COLO)
    ld      h,(iy+_COLO+1)

    dec     (iy+_EXPLOCT)
    jr      nz,_subsubexplo

    ld      a,SFX_SUBDEAD
    call    AFXPLAY

    DIE


_testcollision:
    ld      a,c
    and     a
    ret     z
    cp      $a0         ; no collision with chars $a0 or greater
    ret



explooff:
    .word   0,601,600,2,1,602
    .word   0,601,600,2,1,602
exploptr:
    .word   0

    .align 16
charcache:
    .fill   48






;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
; Move the sub using the user controls.
;

playermovesub:
    push    iy
    pop     hl
    ld      de,_SUBY
    add     hl,de

    ld      a,(up)          ; min y = 6
    and     1
    jr      z,_checkdown
    ld      a,(hl)
    cp      7
    jr      c,_checkdown
    cp      0
    jr      z,_checkdown
    dec     (hl)

    cp      7               ; play the sub surfacing sound if we hit line 6
    ld      a,SFX_SUBSURFACE
    call    z,AFXPLAY

_checkdown:
    ld      a,(down)        ; max y = $48
    and     1
    jr      z,_checkleft
    ld      a,(hl)
    cp      $48
    jr      nc,_checkleft
    inc     (hl)

_checkleft:
    push    iy
    pop     hl
    ld      de,_SUBX
    add     hl,de

    ld      a,(left)        ; min x = 0
    and     1
    jr      z,_checkright
    ld      a,(hl)
    and     a
    jr      z,_checkright
    dec     (hl)

_checkright:
    ld      a,(right)       ; max x = 160
    and     1
    jr      z,_checkfire
    ld      a,(hl)
    cp      $a0
    jr      nc,_checkfire
    inc     (hl)

_checkfire:
    ld      a,(fire)
    cp      1
    ret     nz

    ld      a,(bulletCount)
    or      a
    ret     nz

    ld      bc,obullet
    call    getobject
    call    initobject
    call    insertobject_beforethis

    ldi                         ; copy pixel x & y
    ldi
    ret



;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
; Move the sub after killing the boss using remote control.
;

bossexit:
    ld      a,(iy+_SUBY)
    cp      5*8
    jr      z,_testx
    jr      c,_godown
    dec     a
    dec     a                   ; cheaper than a JR
_godown:
    inc     a
    ld      (iy+_SUBY),a
    ret

_testx:
    ld      a,(iy+_SUBX)
    inc     a
    ret     z
    ld      (iy+_SUBX),a
    ret
