resetscore:
    ld      hl,scoreline
    ld      de,TOP_LINE
    ld      bc,32
    ldir
    ret


showlives:
    ld      a,(lives)
    add     a,16
    ld      (TOP_LINE+31),a
    ret

