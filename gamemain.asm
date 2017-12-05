    .module GAMEMAIN

_LIVES = OUSER
_RSPL = OUSER+1
_RSPH = OUSER+2
_COUNTER = OUSER+3


gamemain:
    call    cls
    call    resetscore
    call    displayscore
    call    displayhi
    call    enablegamesound

    ld      a,r                     ; seed the rng
    ld      (rng+1),a

    ld      hl,scrollflags          ; enable scrolling
    set     0,(hl)

    ld      hl,dofs                 ; set starting zone
    ld      (iy+_RSPL),l
    ld      (iy+_RSPH),h
    xor     a                       ; zone number
    ld      (zone),a

    ld      a,4                     ; set initial lives
    ld      (iy+_LIVES),a
    call    _showlives

    ld      a,(laserframe)          ; can't remember why but reasons
    ld      (laserframe+1),a

_resetafterdeath:
    xor     a                       ; reset collision flag that gets set when sub dies
    ld      (collision),a

    call    refreshmap
    call    resetair
    call    resetenemies

    ld      l,(iy+_RSPL)            ; get sub position from the restart info
    ld      h,(iy+_RSPH)
    ld      c,(hl)
    inc     hl
    ld      b,(hl)
    inc     hl
    ld      (scrollpos),bc
    push    hl

	call	getobject               ; spawn the sub
	ld		bc,subfunction
	call	initobject
	call	insertobject_beforehead

    pop     hl                      ; points to restart X,Y (pixel positions)
    ldi
    ldi

_gameloop:
    call    _advancecheck
    call    featurecheck

    ld      hl,(gameframe)
    inc     hl
    ld      (gameframe),hl

    call    scroll
    ld      a,(scrollflags)
    rlca
    jr      nc,_notscrolled     ; haven't scrolled the bg, so we don't need to update any pointers

    call    zonecheck

_notscrolled:
    xor     a
    ld      (ocount),a
    YIELD

    call    displayscore
    call    checkhi
    call    c,displayhi

    call    enemyinitiator

    ld      a,(FRAMES)          ; play ping sfx (id = 0) every so often
    and     127
    call    z,AFXPLAY2

    ld      a,(collision)       ; loop until the sub has collided with something or beaten the boss
    cp      $ff
    DIEZ
    cp      0
    jp      z,_gameloop

    ; sub's dead
    ld      a,(gamemode)
    ld      l,a
    ld      a,(iy+_LIVES)
    sub     l
    ld      (iy+_LIVES),a
    call    _showlives

    ld      (iy+_COUNTER),100        ; counts up until roll-over: 150ish = ~3 sec

_interlifedelay:
    xor     a
    ld      (ocount),a
    YIELD

    inc     (iy+_COUNTER)
    jr      nz,_interlifedelay

_nomoreo:
    ld      a,(ocount)              ; wait until all objects apart from MAIN and GAMEMAIN are dead
    cp      2
    jr      nz,_nomoreo

    ld      a,(iy+_LIVES)           ; if no more subs are available then it's game over
    and     a
    jp      nz,_resetafterdeath

    call    silencesound

	call	getobject
	ld		bc,attract
	call	initobject
	call	insertobject_afterhead

	DIE



_showlives:
    ld      a,(gamemode)
    and     a
    ld      a,(iy+_LIVES)
    jr      nz,{+}

    ld      a,14 - 16

+:  add     a,16
    ld      (TOP_LINE+31),a
    ret



featurecheck:
    ld      a,(feature)
    cp      1
    ret     nz

    ld      a,SFX_LECTRIC    ; let player know
    call    AFXPLAY

    ld      a,(gamemode)
    xor     1
    ld      (gamemode),a
    call    _showlives
    ret

;    ld      a,(UDG+3)
 ;   xor     $8
  ;  ld      (UDG+3),a
   ; ret



_advancecheck:
    ld      a,(advance)
    dec     a
    ret     nz

    ld      a,(zone)
    cp      6
    ret     z

    ld      a,SFX_ZONEREACH     ; let player know
    call    AFXPLAY

    ld      l,(iy+_RSPL)
    ld      h,(iy+_RSPH)
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    ld      (iy+_RSPL),l
    ld      (iy+_RSPH),h
    jr      _showzone


zonecheck:
    ; check if we've hit a restart point

    ld      l,(iy+_RSPL)        ; this is definitely a bit starbucks
    ld      h,(iy+_RSPH)
    inc     hl                  ; look past the current restart info
    inc     hl
    inc     hl
    inc     hl
    push    hl
    ld      e,(hl)              ; next restart x into de
    inc     hl
    ld      d,(hl)
    ld      hl,(scrollpos)
    and     a
    sbc     hl,de
    pop     hl
    ret     nz                  ; we haven't reached the restart yet

    ld      (iy+_RSPL),l        ; store the new restart info pointer
    ld      (iy+_RSPH),h

_showzone:
    ld      hl,zone
    inc     (hl)
    call    displayzone

    ld      a,SFX_ZONEREACH     ; let player know
    jp      AFXPLAY
