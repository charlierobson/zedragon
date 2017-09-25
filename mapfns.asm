initmap:
    ld      hl,D_BUFFER
    ld      de,map
    ld      bc,6000
    ldir

    ld      bc,600
    ld      e,$3b
    ld      hl,map
-:  ld      a,(hl)
    and     a
    jr      nz,{+}
    ld      (hl),e
+:  inc     hl
    dec     bc
    ld      a,b
    or      c
    jr      nz,{-}

    ret
