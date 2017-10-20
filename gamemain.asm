
;               HEAD
;    ...[mines][core][bullets][gamemain/attract][sub][explosions]...

gamemain:
    call    cls
    call    resetscore
    call    enablegamesound

	ld		a,r
	ld		(rng+1),a

    xor     a
    ld      (restartPoint),a

resetafterdeath:
    call    refreshmap
    call    resetair

    ld      hl,dofs
    ld      a,(restartPoint)        ; reset scroll
    rlca
    rlca
    add     a,l
    ld      l,a
    ld      a,0
    adc     a,h
    ld      h,a
    ld      a,(hl)
    inc     hl
    push    hl
    ld      h,(hl)
    ld      l,a
    ld      (restartScrollPos),hl
    ld      (scrollpos),hl
    ld      (BUFF_OFFSET),hl
    pop     hl
    inc     hl
    ld      a,(hl)
    ld      (subx),a
    inc     hl
    ld      a,(hl)
    ld      (suby),a

    call    scroll              ; to ensure sub background capture doesn't compensate

    call    resetmines              ; find the first mine on screen wrt scroll position

	call	getobject
	ld		bc,subfunction
	call	initobject
	call	insertobject_afterthis

aliveloop:
    ld      a,(advance)
    cp      1
    jr      nz,{+}

    ld      a,(restartPoint)
    inc     a
    ld      (restartPoint),a
+:

    ld      hl,(gameframe)
    inc     hl
    ld      (gameframe),hl

    call    scroll
    call    findfirstmine

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

    xor     a
    ld      (iy+OUSER),a

-:  call    updatebullets

    YIELD

    inc     (iy+OUSER)
    jr      nz,{-}

    jp      resetafterdeath

    call    silencesound

	call	getobject
	ld		bc,attract
	call	initobject
	call	insertobject_afterhead

	DIE
