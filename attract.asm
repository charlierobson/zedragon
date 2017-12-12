    .module ATTRACT

attract:
    call    cls

    YIELD

    call    installmaincharset          ; (re)install the main character set

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

    call    animatecharacters

	ld		bc,gamemain
    ld      a,(fire)
    cp      1
    jr      nz,_attractloop
    
_gamestart:
    push    bc
    call    silencesound
    call    resetscore
    pop     bc

	call	objectafterhead
	DIE
