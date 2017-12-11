    .module TELETYPE

_DATAL = OUSER+0
_DATAH = OUSER+1
_CURSORX = OUSER+2
_CURSORY = OUSER+3
_SCRPL = OUSER+4
_SCRPH = OUSER+5
_TIMER = OUSER+6

TTRATE = 3

teletypercongrat:
    ld      (iy+_DATAL),_congrattext & 255
    ld      (iy+_DATAH),_congrattext / 256

teletype:
    call    cls

    ld      hl,ttfont
    ld      de,UDG
    call    decrunch

    ld      hl,0
    ld      (scrollpos),hl

    ld      (iy+_CURSORY),-1
    call    _newline

_ttloop:
    ld      (iy+_TIMER),TTRATE
    ld      l,(iy+_SCRPL)
    ld      h,(iy+_SCRPH)
    ld      (hl),1

-:
    YIELD
    dec     (iy+_TIMER)
    jr      nz,{-}

    ld      (iy+_TIMER),TTRATE
    ld      l,(iy+_SCRPL)
    ld      h,(iy+_SCRPH)
    ld      (hl),0

-:
    YIELD
    dec     (iy+_TIMER)
    jr      nz,{-}

    ld      e,(iy+_SCRPL)
    ld      d,(iy+_SCRPH)
    ld      l,(iy+_DATAL)
    ld      h,(iy+_DATAH)
    ldi
    ld      (iy+_SCRPL),e
    ld      (iy+_SCRPH),d

    ld      a,(hl)
    cp      $3e             ; ~ - newline
    call    z,_newline

    ld      (iy+_DATAL),l
    ld      (iy+_DATAH),h

    cp      $3d             ; } - end of text
    jr      nz,_ttloop

    DIE

_newline:
    push    af
    push    hl
    ld      a,(iy+_CURSORY)
    inc     a
    ld      (iy+_CURSORY),a
    call    mulby600
    ld      hl,D_BUFFER
    add     hl,de
    ld      (iy+_SCRPL),l
    ld      (iy+_SCRPH),h
    pop     hl
    pop     af
    inc     hl
    ret

    .asciimap 0, 255, {*}-'@'
    .asciimap ' ', ' ', 0
    .asciimap '.', '.', $1e
    .asciimap '!', '!', $3c

            ;--------========--------========
_congrattext:
    .asc    "    Congratulations Captain!~"
    .asc    "~"
    .asc    "The biggest threat to our planet~"
    .asc    "is defeated. We are safe again.~"
    .asc    "~"
    .asc    "You will receive the highest~"
    .asc    "honour our country can give_~"
    .asc    "~"
    .asc    "         _ANOTHER GO!!}"

            ;--------========--------========
