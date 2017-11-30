    .module GAMEMAIN

_LIVES = OUSER
_RSPL = OUSER+1
_RSPH = OUSER+2
_COUNTER = OUSER+3

; for debugging
dofspecial:
    .word   $70
    .byte   $78,$28


gamemain:
    call    cls
    call    resetscore
    call    displayscore
    call    displayhi
    call    enablegamesound

    ld      a,r
    ld      (rng+1),a

    ld      hl,scrollflags          ; enable scrolling
    set     0,(hl)

    ld      hl,dofs ;; dofspecial
    ld      (iy+_RSPL),l
    ld      (iy+_RSPH),h

    ld      a,4
    ld      (iy+_LIVES),a
    call    _showlives

    xor     a
    ld      (zone),a

    ld      a,(laserframe)
    ld      (laserframe+1),a

_resetafterdeath:
    call    refreshmap
    call    resetair
    call    resetenemies

    ld      l,(iy+_RSPL)
    ld      h,(iy+_RSPH)
    ld      c,(hl)
    inc     hl
    ld      b,(hl)
    inc     hl
    ld      (scrollpos),bc
    push    hl

	call	getobject
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

    ld      a,(collision)       ; loop until the sub has collided with something
    and     a
    jp      z,_gameloop

    ; sub's dead

    ld      a,(iy+_LIVES)
    dec     a
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
    ld      a,(iy+_LIVES)
    add     a,16
    ld      (TOP_LINE+31),a
    ret



featurecheck:
    ld      a,(feature)
    cp      1
    ret     nz

    ld      a,(UDG+3)
    xor     $8
    ld      (UDG+3),a
    ret



_advancecheck:
    ld      a,(advance)
    dec     a
    ret     nz

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
