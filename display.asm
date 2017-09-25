setupudg:
    ld      hl,charsets
    ld      de,$2000
    ld      bc,1024
    ldir
    ld      a,$21
    ld      i,a
    ret


cls:
    xor     a
    ld      hl,D_BUFFER
    ld      bc,6000-1
    call    {+}
    ld      hl,TOP_LINE
    ld      bc,32-1
    call    {+}
    ld      hl,BOTTOM_LINE
    ld      bc,32-1
+:
    ld      d,h
    ld      e,l
    inc     de
    ld      (hl),a
    ldir
    ret


drawtitle:
    ld      hl,titlescreen
    ld      de,D_BUFFER + 604
    ld      b,9
-:  push    bc
    ld      bc,24
    ldir
    push    hl
    ex      de,hl
    ld      de,600-24
    add     hl,de
    ex      de,hl
    pop     hl
    pop     bc
    djnz    {-}
    ret


drawmap:
    ld      hl,map
    ld      de,D_BUFFER
    ld      bc,6000
    ldir
    ret


animateEnemies:
    ; animate shooters
    ld      a,(FRAMES)
    and     15
    jr      nz,{+}

    ld      a,(ssa-charsets+$2001)
    xor     $66 ^ $7e
    ld      (ssa-charsets+$2001),a
    and     $3c
    ld      (ssa-charsets+$200e),a
    ld      a,(ssa-charsets+$2009)
    xor     $a7 ^ $e5
    ld      (ssa-charsets+$2009),a
    xor     a

+:  and     7
    ret     nz
    ld      a,(sbframe)
    and     a
    jr      nz,{+}
    ld      a,6
+:  dec     a
    ld      (sbframe),a
    ld      de,sbdata
    add     a,e
    ld      e,a
    ld      a,(de)
    ld      (ssa-charsets+$2003),a
    ld      (ssa-charsets+$200b),a
    ret


animatewater:
    ld      a,(FRAMES)
    and     %01110000
    rrca
    rrca
    rrca
    rrca
    ld      de,wateranimation
    add     a,e
    ld      e,a
    ld      a,(de)
    ld      (wsa-charsets+$2000),a
    ret
