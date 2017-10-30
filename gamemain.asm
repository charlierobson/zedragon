
;               HEAD
;    ...[mines][core][bullets][gamemain/attract][sub][explosions]...

gamemain:
    call    cls
    call    resetscore
    call    enablegamesound

	ld		a,r
	ld		(rng+1),a

    ld      hl,dofs
    ld      (restartPoint),hl

    ld      a,4
    ld      (lives),a
    call    showlives

resetafterdeath:
    call    refreshmap
    call    resetair

    ld      hl,(restartPoint)
    ld      c,(hl)
    inc     hl
    ld      b,(hl)
    inc     hl
    ld      (scrollpos),bc
    ld      a,(hl)
    ld      (subx),a
    inc     hl
    ld      a,(hl)
    ld      (suby),a

    call    scroll                  ; this pushes the scroll pos on 1 sub-pixel. is necessary
    call    resetmines              ; find the first mine on screen wrt scroll position

	call	getobject
	ld		bc,subfunction
	call	initobject
	call	insertobject_afterthis

aliveloop:
    ld      hl,(gameframe)
    inc     hl
    ld      (gameframe),hl

    call    scroll              ; haven't scrolled the bg, so we don't need to update any pointers
    jr      nz,{+}

    call    findfirstmine

    ld      hl,(restartPoint)
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    push    hl
    ld      e,(hl)
    inc     hl
    ld      d,(hl)
    ld      hl,(scrollpos)
    and     a
    sbc     hl,de
    pop     hl
    jr      nz,{+}

    ld      (restartPoint),hl

    ld      a,12
    call    AFXPLAY

+:  ;call    displayandresetocount

    YIELD

    call    updateair

    call    minerelease

    ld      de,0
    ld      (bulletHitX),de
    call    updatebullets

    ld      a,(FRAMES)              ; play ping sfx every so often
    and     127
    call    z,AFXPLAY

    ld      a,(fire)
    cp      1
    call    z,startbullet

    ld      a,(collision)
    and     a
    jr      z,aliveloop


    ; sub's dead
deadsub:
    xor     a
    ld      (iy+OUSER),a

    ld      a,(lives)
    dec     a
    ld      (lives),a
    call    showlives

-:  call    updatebullets

    YIELD

    inc     (iy+OUSER)
    jr      nz,{-}

    ld      a,(lives)
    and     a
    jp      nz,resetafterdeath

    call    silencesound

	call	getobject
	ld		bc,attract
	call	initobject
	call	insertobject_afterhead

	DIE
