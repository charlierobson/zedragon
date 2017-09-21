    .emptyfill  0
    .org        $4009

#include "include\sysvars.asm"
#include "include\zxline0.asm"

; ------------------------------------------------------------
starthere:
    ld      hl,charsets
    ld      de,$2000
    ld      bc,1024
    ldir

    ld      hl,scoreline
    ld      de,TOP_LINE
    ld      bc,32
    ldir

    ld      hl,airline
    ld      de,BOTTOM_LINE
    ld      bc,32
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

    ld      hl,map
    ld      de,D_BUFFER
    ld      bc,6000
    ldir

    ld      a,$21
    ld      i,a

    call    setupDisplay

mainloop:
    ld      hl,FRAMES
    ld      a,(hl)
-:  cp      (hl)
    jr      z,{-}

    ld      hl,(xscroll)
    inc     hl
    ld      (xscroll),hl
    and     a
    rr      h
    rr      l
    ld      (BUFF_OFFSET),hl

    call    $1ffe           ; readjoy
    and     $f8
    cp      $f8
    jr      z,mainloop

    ld      a,$1e
    ld      i,a

    jp      restoreDisplay

#include "readisplay.asm"

#include "data.asm"

    .align 512
charsets:
#include "charset.asm"

map:
    .incbin "mungedmap.bin"

endshere:
; ------------------------------------------------------------

#include "include\zxline1.asm"

    .end
