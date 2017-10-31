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

    ld      hl,scrollpos
    ld      (hl),0
    YIELD

-:  ld      a,(FRAMES)
    and     127
    call    z,updatecredits

;    ld      de,TOP_LINE
;    ld      a,(kbin+7)
;    ld      l,a
;    call    binaryout

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
