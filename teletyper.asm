    .module TELETYPE

_DATAL = OUSER+0
_DATAH = OUSER+1
_CURSORX = OUSER+2
_CURSORY = OUSER+3
_SCRPL = OUSER+4
_SCRPH = OUSER+5
_AFTERL = OUSER+6
_AFTERH = OUSER+7
_TIMER = OUSER+8

TTRATE = 3

failtext:
    .asc    "         MISSION FAILED}"
            ;--------========--------========

teletypergameover:
    ld      (iy+_DATAL),failtext & 255
    ld      (iy+_DATAH),failtext / 256
	ld		(iy+_AFTERL),attract & 255
	ld		(iy+_AFTERH),attract / 256

    ld      (iy+_CURSORY),4-1
    call    _newlinetest
    jr      _teletype


teletypercongrat:
    ld      (iy+_DATAL),congrattext & 255
    ld      (iy+_DATAH),congrattext / 256
	ld		(iy+_AFTERL),gamemain & 255
	ld		(iy+_AFTERH),gamemain / 256

    ld      (iy+_CURSORY),-1
    call    _newlinetest

    ; fall in

_teletype:
    ld      (iy+_SCRPL),l
    ld      (iy+_SCRPH),h

    call    cls

    ld      hl,ttfont
    ld      de,UDG
    call    decrunch

    ld      hl,0
    ld      (scrollpos),hl

_ttloop:
    ld      (iy+_TIMER),TTRATE
    ld      l,(iy+_SCRPL)
    ld      h,(iy+_SCRPH)
    ld      (hl),$3f

-:  YIELD
    dec     (iy+_TIMER)
    jr      nz,{-}

    ld      (iy+_TIMER),TTRATE
    ld      l,(iy+_SCRPL)
    ld      h,(iy+_SCRPH)
    ld      (hl),$00

-:  YIELD
    dec     (iy+_TIMER)
    jr      nz,{-}

    ld      l,(iy+_SCRPL)
    ld      h,(iy+_SCRPH)
    ld      e,(iy+_DATAL)
    ld      d,(iy+_DATAH)
    ld      a,(de)
    inc     de
    ld      (iy+_DATAL),e
    ld      (iy+_DATAH),d
    
    cp      $3d
    jr      z,_done         ; end of text

    cp      $3e
    call    z,_newlinetest  ; returns with new screen pointer and character if n/l hit

    ld      (hl),a
    inc     hl
    ld      (iy+_SCRPL),l
    ld      (iy+_SCRPH),h

    jr      _ttloop

_done:
    ld      (iy+_TIMER),0

-:  YIELD

    ld      l,(iy+_SCRPL)
    ld      h,(iy+_SCRPH)
    ld      a,(iy+_TIMER)
    bit     2,a
    ld      a,0
    jr      nz,{+}
    ld      a,$3f
+:  ld      (hl),a

    dec     (iy+_TIMER)

    ld      hl,titlecreds+192+1
    bit     6,(iy+_TIMER)
    jr      nz,{+}

    ld      hl,BOTTOM_LINE

+:  ld      de,BOTTOM_LINE+1
    ld      bc,31
    ldir

+:  ld      a,(fire)
    cp      1
    jr      nz,{-}

	ld		c,(iy+_AFTERL)
	ld		b,(iy+_AFTERH)
	call	getobject
	call	initobject
	call	insertobject_afterhead

    DIE

_newlinetest:
    ld      a,(iy+_CURSORY)
    inc     a
    ld      (iy+_CURSORY),a
    call    mulby600
    ld      hl,D_BUFFER-1
    add     hl,de
    ld      a,$3f
    ret
