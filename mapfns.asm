initmap:
    ld      hl,D_BUFFER
    ld      de,map
    ld      bc,6000
    ldir
    ret
