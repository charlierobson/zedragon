
showcols:
    ld      hl,TOP_LINE
    ld      bc,32
    xor     a
    call    fillmem
    ld      a,(iy+_COLLTAB+0)   ; character occupying top left
    ld      de,TOP_LINE
    call    hexout
    ld      a,(iy+_COLLTAB+1)   ; overlapping bits from above
    ld      de,TOP_LINE+2
    call    hexout
    ld      a,(iy+_COLLTAB+2)
    ld      de,TOP_LINE+5
    call    hexout
    ld      a,(iy+_COLLTAB+3)
    ld      de,TOP_LINE+7
    call    hexout
    ld      a,(iy+_COLLTAB+4)
    ld      de,TOP_LINE+10
    call    hexout
    ld      a,(iy+_COLLTAB+5)
    ld      de,TOP_LINE+12
    call    hexout

    ld      a,(iy+_COLLTAB+6)
    ld      de,TOP_LINE+15
    call    hexout
    ld      a,(iy+_COLLTAB+7)
    ld      de,TOP_LINE+17
    call    hexout
    ld      a,(iy+_COLLTAB+8)
    ld      de,TOP_LINE+20
    call    hexout
    ld      a,(iy+_COLLTAB+9)
    ld      de,TOP_LINE+22
    call    hexout
    ld      a,(iy+_COLLTAB+10)
    ld      de,TOP_LINE+25
    call    hexout
    ld      a,(iy+_COLLTAB+11)
    ld      de,TOP_LINE+27
    call    hexout

    ld      a,(iy+_SUBX)
    ld      de,BOTTOM_LINE
    call    hexout
    ld      a,(iy+_SUBY)
    ld      de,BOTTOM_LINE+3
    call    hexout
    
    ret
