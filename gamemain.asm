gamemain:
    call    cls
    call    resetscore
    call    enablegamesound

    ;ld      a,(advance)
    ;cp      1
    ;ret     nz

resetafterdeath:
    call    resetscroll
    call    refreshmap
    call    resetair

	call	getobject
	ld		bc,subfunction
	call	initobject
	call	insertobject_afterthis

aliveloop:
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
