attract:
    call    cls
    call    drawtitle
    call    resetcredits
    call    enabletitlesound

-:  ld      a,(FRAMES)
    and     127
    call    z,updatecredits

    YIELD

    ld      a,(fire)
    cp      1
    jr      nz,{-}

    call    silencesound

	call	getobject
	ld		bc,gamemain
	call	initobject
	call	insertobject_afterhead

	DIE
