    .emptyfill  0
    .org        $4009

#include "include\sysvars.asm"
#include "include\zxline0.asm"

; ------------------------------------------------------------
starthere:
    call    setupDisplay

    ld      hl,map
    ld      de,D_BUFFER
    ld      bc,6000
    ldir

    ld      hl,charsets
    ld      a,h
    ld      i,a

-:  call    $1ffe           ; readjoy
    and     $f8
    cp      $f8
    jr      z,{-}

    jp      restoreDisplay

#include "readisplay.asm"
#include "charset.asm"

map:
    .incbin "mungedmap.bin"

endshere:
; ------------------------------------------------------------

#include "include\zxline1.asm"

    .end
