;  rom   ram   ram   ram   ram
; $0000 $2000 $4000 $6000 $8000 $a000 $c000 $e000
;  0000  0010  0100  0110  1000  1010  1100  1110 


map = $2600

initmap:
    ld      hl,D_BUFFER
    ld      de,map
    ld      bc,6000
    ldir
    ret


refreshmap:
    ; copy 'pure' map data up into high memory where it mirrors the display file

    ld      hl,map
    push    hl
    ld      de,D_BUFFER+$4000
    push    de
    ld      bc,6000
    ldir

    ; copy the mirror map into the display

    pop     hl
    pop     de
    ld      bc,6000
    ldir

    ret
