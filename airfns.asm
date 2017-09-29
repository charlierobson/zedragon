resetair:
    ld      a,27*8
    ld      (airlevel),a

    ld      hl,airline
    ld      de,BOTTOM_LINE
    ld      bc,32
    ldir

    ret


updateair:
    ld      a,(airupdatecounter)
    or      a
    jr      nz,{+}
    ld      a,6
+:  dec     a
    ld      (airupdatecounter),a
    ret     nz

    ld      a,(airlevel)            ; quit when air all gone
    or      a
    ret     z

    dec     a
    ld      (airlevel),a
    push    af

    ld      hl,BOTTOM_LINE+5
    srl     a
    srl     a
    srl     a
    add     a,l                         ; hl aligned to 32 bytes, so no need to carry
    ld      l,a

    pop     af
    and     7
    jr      z,{+}
    add     a,6
+:  ld      (hl),a
    ret
