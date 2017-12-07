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
    call    decrunch

    ld      hl,scrollpos                ; ensure scroll is at 0 by waiting a cycle
    ld      (hl),0
    YIELD

_attractloop:
    ld      a,(FRAMES)
    and     127
    call    z,updatecredits

    YIELD

	ld		bc,gamemain
    ld      a,(fire)
    cp      1
    jr      z,_gamestart

    ld      bc,testmain
    ld      a,(feature)
    cp      1
    jr      nz,_attractloop
    
_gamestart:
    push    bc
    call    silencesound
    pop     bc
	call	getobject
	call	initobject
	call	insertobject_afterhead
	DIE
