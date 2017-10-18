attract:
    call    cls
    call    drawtitle
    call    resetcredits
    call    enabletitlesound

-:  ld      a,(FRAMES)
    and     127
    call    z,updatecredits

;    ld      de,TOP_LINE
;    ld      a,(kbin+7)
;    ld      l,a
;    call    binaryout

    YIELD

    ld      a,(advance)
    cp      1
    jr      nz,{+}

	call	getobject
	ld		bc,minearise
	call	initobject
	call	insertobject_afterthis
    ld      de,minetblx
    ex      de,hl
    ldi
    ldi
    ldi

+:  ld      a,(fire)
    cp      1
    jr      nz,{-}

    call    silencesound

	call	getobject
	ld		bc,gamemain
	call	initobject
	call	insertobject_afterhead

	DIE


minetblx:
    .word   5
    .byte   8,CH_MINE
