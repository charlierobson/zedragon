resetscore:
    ld      hl,scoreline
    ld      de,TOP_LINE
    ld      bc,32
    ldir
    ret
