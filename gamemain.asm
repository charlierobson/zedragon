gamemain:
    call    cls
    call    refreshmap
    call    resetscore
    call    enablegamesound

    ;ld      a,(advance)
    ;cp      1
    ;ret     nz

resetafterdeath:
    call    cls
    call    resetscroll

    YIELD

    call    drawmap
    call    resetair

	call	getobject
	ld		bc,subfunction
	call	initobject
	call	insertobject_afterthis

aliveloop:
    ld      hl,(gameframe)
    inc     hl
    ld      (gameframe),hl

    call    scroll
    call    updateair

    call    showsubcoords

    call    updatebullets

    ld      a,(FRAMES)              ; play sfx 0 every ~1 sec
    and     127
    call    z,AFXPLAY

    ld      a,(fire)
    cp      1
    call    z,startbullet

    YIELD

    ld      a,(collision)
    and     a
    jr      z,aliveloop

    xor     a
    ld      (iy+OUSER),a

-:  call    updatebullets

    YIELD

    inc     (iy+OUSER)
    jr      nz,{-}

    jr      resetafterdeath

    call    silencesound

	call	getobject
	ld		bc,attract
	call	initobject
	call	insertobject_afterhead

	DIE
