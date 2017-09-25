    .emptyfill  0
    .org        $4009

#include "include\sysvars.asm"
#include "include\zxline0.asm"

; ------------------------------------------------------------
starthere:
    call    cls
    call    drawtitle

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

    call    setupudg
    call    setupDisplay

mainloop:
    ; wait for new frame
    ld      hl,FRAMES
    ld      a,(hl)
-:  cp      (hl)
    jr      z,{-}

    ; scroll
    ld      hl,(xscroll)
    ld      a,l
    cp      (2400-128) & $ff
    jr      nz,{+}
    ld      a,h
    cp      (2400-128) / 256
    jr      z,{++}

+:  ;;;inc     hl
    ld      (xscroll),hl

++: and     a
    rr      h
    rr      l
    and     a
    rr      h
    rr      l
    ld      (BUFF_OFFSET),hl

+:  call    animateEnemies
    call    animateWater

+:  call    $1ffe           ; readjoy
    and     $f8
    cp      $f8
    jr      z,mainloop

    ld      a,$1e
    ld      i,a

    jp      restoreDisplay

#include "readisplay.asm"

#include "air.asm"
#include "score.asm"
#include "display.asm"

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
