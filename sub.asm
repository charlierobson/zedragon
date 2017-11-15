O_SUBX = OUSER+0          ; don't change
O_SUBY = OUSER+1          ; don't change
O_PBULLET = OUSER+2
O_COLLTAB = OUSER+4

subfunction:
    ld      hl,$0000
    ld      (subaddress),hl         ; we'll sink the first sub drawing into the ROM
    ld      (oldsubaddress),hl

substart:
    ; undraw the old sub

    ld      hl,(oldsubaddress)      ; point hl into clean map
    ld      e,l
    ld      d,h
    res     6,h
    set     7,h
    ldi
    ldi
    ldi
    ld      de,600-3
    add     hl,de
    ld      e,l
    ld      d,h
    res     7,d
    set     6,d
    ldi
    ldi
    ldi

    ; now draw the mini bitmap containing the sub to the screen

    ld      hl,600
    ld      de,(subaddress)
    add     hl,de
    ld      (oldsubaddress),de

    ld      a,(gameframe)           ; $b0 even frames, $b8 odd frames
    and     1
    ld      a,$b0
    jr      nz,{+}                  ; we're a frame ahead, remember ;)

    ld      a,$b8

+:  ld      (de),a
    inc     a
    inc     de
    ld      (hl),a
    inc     a
    inc     hl
    ld      (de),a
    inc     a
    inc     de
    ld      (hl),a
    inc     a
    inc     hl
    ld      (de),a
    inc     a
    ld      (hl),a

    ;
    ; move sub
    ;

    push    iy
    pop     hl
    ld      de,O_SUBY
    add     hl,de

    ld      a,(up)          ; min y = 6
    and     1
    jr      z,{+}
    ld      a,(hl)
    cp      7
    jr      c,{+}
    cp      0
    jr      z,{+}
    dec     (hl)

+:  ld      a,(down)        ; max y = $48
    and     1
    jr      z,{+}
    ld      a,(hl)
    cp      $48
    jr      nc,{+}
    inc     (hl)

+:  push    iy
    pop     hl
    ld      de,O_SUBX
    add     hl,de

    ld      a,(left)        ; min x = 0
    and     1
    jr      z,{+}
    ld      a,(hl)
    and     a
    jr      z,{+}
    dec     (hl)

+:  ld      a,(right)       ; max x = 160
    and     1
    jr      z,_checkfire
    ld      a,(hl)
    cp      $a0
    jr      nc,_checkfire
    inc     (hl)

    ;
    ; check fire
    ;

_checkfire:
    ld      a,(fire)
    cp      1
    jr      nz,_subrender

    ld      bc,obullet
    call    getobject
    call    initobject
    call    insertobject_afterthis
    ld      (iy+O_PBULLET),l
    ld      (iy+O_PBULLET+1),h
    ld      a,(iy+O_SUBX)
    ld      (hl),a
    inc     hl
    ld      a,(iy+O_SUBY)
    ld      (hl),a

    ;
    ; render sub
    ;

_subrender:
    ; calculate address of sub in the map, relative to the current scroll position

    ld      a,(iy+O_SUBX)       ; pixel -> char conversion
    srl     a
    srl     a
    srl     a
    ld      l,a
    ld      h,0

    ld      a,(iy+O_SUBY)       ; div by 8 to get character line then mul by 600
    srl     a
    srl     a
    srl     a
    call    mulby600            ; de = a * 600
    add     hl,de               ; character offset relative to visible window

    ld      de,(scrollpos)
    add     hl,de

    ld      de,D_BUFFER
    add     hl,de

    ld      (subaddress),hl     ; sub's address in the display memory

    ; find the character codes that appear under the sub in its new position
    ; use the map cache as the code source because the display is dirty at this point
    ; copy the pixel data corresponding to the characters under the sub
    ; to a new group of 3x2 characters - effectively a tiny bitmap
    ;
    ; on-screen (even frames)  (odd  frames)
    ;            $b0 $b2 $b4    $b8 $ba $bc
    ;            $b1 $b3 $b5    $b9 $bb $bd
    ;
    ; it's like this because the rendering of the sub char is easier using columns

    res     6,h                 ; point hl at mapcache in high memory
    set     7,h                 ; hl is source pointer for character data
    push    hl

    ld      de,charcache        ; b0/b8
    call    copycharx
    ld      (iy+O_COLLTAB),a    ; collision index 0, store character code

    ld      de,charcache+16     ; ... char b2/ba
    call    copycharx
    ld      (iy+O_COLLTAB+4),a  ; coll. idx. 2

    ld      de,charcache+32     ; b4/bc
    call    copycharx
    ld      (iy+O_COLLTAB+8),a  ; c.i. 4

    pop     hl
    ld      bc,600
    add     hl,bc

    ld      de,charcache+8      ; b1/b9
    call    copycharx
    ld      (iy+O_COLLTAB+2),a      ; c.i 1 

    ld      de,charcache+24     ; b3/bb
    call    copycharx
    ld      (iy+O_COLLTAB+6),a      ; c.i 3

    ld      de,charcache+40     ; b5/bd
    call    copycharx
    ld      (iy+O_COLLTAB+10),a     ; c.i 5

    ld      de,$2380
    ld      a,(gameframe)       ; even frames $2380, odd frames $23c0
    and     1
    jr      z,{+}
    ld      e,$c0
+:  ld      (basecharptr),de

    ld      hl,charcache        ; copy chars into charset
    ld      bc,48
    ldir

    ;

    xor     a                   ; zero out collision bits
    ld      (iy+O_COLLTAB+1),a
    ld      (iy+O_COLLTAB+3),a
    ld      (iy+O_COLLTAB+5),a
    ld      (iy+O_COLLTAB+7),a
    ld      (iy+O_COLLTAB+9),a
    ld      (iy+O_COLLTAB+11),a
    ld      (collision),a

    ld      a,OUSER+1
    ld      (subcoloff),a

    ; now we've effectively built our tiny bitmap and cleared out the collision bits,
    ; we can render the sub into it and collect any collision pixels
    ;
    ; choose which set of 3 pre-scrolled sub tiles to use.

    ld      a,(iy+O_SUBX)       ; pixel offset 0..7
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

    ld      de,(basecharptr)    ; pointer to 1st byte within column of 16 rows inside mini bitmap
    ld      a,(IY+O_SUBY)       ; that we will render to
    and     7
    or      e
    ld      e,a

    ld      b,3             ; 3 characters

--: push    bc

    ; copy 8 sub pixels into bg bitmap

    ld      b,8             ; 8 lines

    ld      a,(iy+O_SUBY)   ; keep track of the row number that we're rendering into,
    and     7               ; so that we can track collision data on a per character cell basis
    ld      (subrowoff),a

    ld      a,(subcoloff)   ; init collision indices
    ld      (colidx1),a
    ld      (colidx2),a

-:  ld      c,(hl)          ; get sub pixels
    ld      a,(de)          ; get bg pixels
    push    af
    and     c               ; merge sub into background
    ld      (de),a

    pop     af              ; get bg pixels
    or      c               ; or together
    xor     $ff             ; any 0 bits are collisions
    ld      c,a

    ; we need to know what collision pixels map to which background char

    ld      a,(subrowoff)   ; when rendering hits row 8 bump collision data index
    inc     a
    ld      (subrowoff),a
    cp      8
    jr      nz,{+}

    ld      a,(colidx1)
    inc     a
    inc     a
    ld      (colidx1),a
    ld      (colidx2),a

colidx1 = $+2
colidx2 = $+6
+:  ld      a,(iy+0)        ; update collision bits for this background cell
    or      c
    ld      (iy+0),a

    inc     hl
    inc     de
    djnz    {-}

    ; step across the dest bitmap to the next column
    ; we know the address won't overflow the bottom 8 bits

    ld      a,8
    add     a,e
    ld      e,a

    ld      a,(subcoloff)  ; iy+ouser progression: +1, (+3), +5, (+7), +9, (+11)
    inc     a
    inc     a
    inc     a
    inc     a
    ld      (subcoloff),a

    pop     bc
    djnz    {--}

    ; all rendered

    YIELD

    ld      d,O_COLLTAB
    ld      e,O_COLLTAB+1
    ld      b,6

-:  ld      a,d
    ld      (chkidx1),a
    ld      a,e
    ld      (chkidx2),a

chkidx1 = $+2
chkidx2 = $+5
    ld      c,(iy+0)                ; character cell content
    ld      a,(iy+0)                ; pixel collision data
    and     a                       ; clears carry
    call    nz,testcollision        ; test the collision
    jr      c,collided

    inc     d
    inc     d
    inc     e
    inc     e
    djnz    {-}

    ;call    showcols

    ld      a,(airlevel)
    and     a
    jp      nz,substart

    ; sub is dead, explo-o-o-o-ode

collided:
    ld      a,1
    ld      (collision),a

    ; trigger some explosions

    ld      hl,explooff
    ld      a,(FRAMES)
    and     6

    add     a,l
    ld      l,a
    adc     a,h
    sub     l
    ld      h,a
    ld      (exploptr),hl

    call    subsubexplo
    call    subsubexplo
    call    subsubexplo
    call    subsubexplo
    call    subsubexplo
    call    subsubexplo

    ld      a,12-1
    call    AFXPLAY

    DIE

charcache:
    .fill   48

testcollision:
    ld      a,c
    and     a
    ret     z
    cp      $a0         ; no collision with chars $a0 or greater
    ret


subsubexplo:
    ld      hl,(exploptr)
    ld      e,(hl)
    inc     hl
    ld      d,(hl)
    inc     hl
    ld      (exploptr),hl
    ld      hl,(subaddress)
    add     hl,de
    push    hl

    call	getobject
	ld		bc,explosion
	call	initobject
	call	insertobject_afterthis

    pop     de
    ld      (hl),e
    inc     hl
    ld      (hl),d

    YIELD
    YIELD
    YIELD
    ret

explooff:
    .word   0,601,600,2,1,602
    .word   0,601,600,2,1,602
exploptr:
    .word   0


showcols:
    ld      hl,TOP_LINE
    ld      bc,32
    xor     a
    call    fillmem
    ld      a,(iy+O_COLLTAB+0)
    ld      de,TOP_LINE
    call    hexout
    ld      a,(iy+O_COLLTAB+1)
    ld      de,TOP_LINE+2
    call    hexout
    ld      a,(iy+O_COLLTAB+2)
    ld      de,TOP_LINE+5
    call    hexout
    ld      a,(iy+O_COLLTAB+3)
    ld      de,TOP_LINE+7
    call    hexout
    ld      a,(iy+O_COLLTAB+4)
    ld      de,TOP_LINE+10
    call    hexout
    ld      a,(iy+O_COLLTAB+5)
    ld      de,TOP_LINE+12
    call    hexout

    ld      a,(iy+O_COLLTAB+6)
    ld      de,TOP_LINE+15
    call    hexout
    ld      a,(iy+O_COLLTAB+7)
    ld      de,TOP_LINE+17
    call    hexout
    ld      a,(iy+O_COLLTAB+8)
    ld      de,TOP_LINE+20
    call    hexout
    ld      a,(iy+O_COLLTAB+9)
    ld      de,TOP_LINE+22
    call    hexout
    ld      a,(iy+O_COLLTAB+10)
    ld      de,TOP_LINE+25
    call    hexout
    ld      a,(iy+O_COLLTAB+11)
    ld      de,TOP_LINE+27
    call    hexout


    ret
