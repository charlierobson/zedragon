    .module ATTRACT

attract:
    call    cls

    ld      hl,scrollpos
    ld      (hl),32
    YIELD

    call    resetcredits
    call    enabletitlesound

    ld      hl,titlescreen
    ld      de,D_BUFFER
    call    LZ48_decrunch

    ld      hl,scrollpos                ; ensure scroll is at 0 by waiting a cycle
    ld      (hl),0
    YIELD

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
