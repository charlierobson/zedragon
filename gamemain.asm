gamemain:
    call    initsub
    call    cls
    call    resetscroll
    call    refreshmap
    call    drawmap
    call    resetscore
    call    resetair
    call    enablegamesound

    ;ld      a,(advance)
    ;cp      1
    ;ret     nz

-:  ;call    scroll
    call    updateair
    call    movesub

    call    showsubcoords

    call    drawsub
    call    updatebullets

    ld      a,(fire)
    cp      1
    call    z,startbullet

    YIELD

    ld      a,(quit)
    cp      1
    jr      {-}

    call    silencesound

	call	getobject
	ld		bc,attract
	call	initobject
	call	insertobject_afterhead

	DIE
