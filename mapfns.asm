initmap:
    ld      de,mapname
    xor     a
    call    $1ff8

addwatertomap:
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
