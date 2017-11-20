    .module TESTMAIN

;               HEAD
;    ...[mines][core][bullets][gamemain/attract][sub][explosions]...

testmain:
    ld      l,0

-:  ld      (iy+OUSER),l
    ld      h,0
    ld      (scrollpos),hl
    YIELD
    ld      l,(iy+OUSER)
    inc     l
    ld      a,33
    cp      l
    jr      nz,{-}

    ;

    ld      a,r
    ld      (rng+1),a

    ld      hl,testenemyidx
    ld      de,enemyidx
    ld      bc,64
    ldir
    ld      hl,testenemydat
    ld      de,enemydat
    ld      bc,16
    ldir

    call    resetair

_testreset:
    ld      hl,titlescreen
    ld      de,D_MIRROR
    call    LZ48_decrunch

    ld      hl,D_MIRROR
    ld      de,D_BUFFER
    ld      bc,6000
    ldir

	call	getobject
	ld		bc,subfunction
	call	initobject
	call	insertobject_afterthis

    ld      (hl),32                     ; X
    inc     hl
    ld      (hl),32                     ; Y

    call    resetenemies

_aliveloop:
    ld      hl,(gameframe)
    inc     hl
    ld      (gameframe),hl

    call    displayocount
    xor     a
    ld      (ocount),a
    YIELD

    call    enemyinitiator

    ;call    showcols

    ld      a,(collision)
    and     a
    jr      z,_aliveloop

    ; sub's dead

    ld      (iy+OUSER),$80

-:  call    displayocount
    xor     a
    ld      (ocount),a
    YIELD

    inc     (iy+OUSER)
    jr      nz,{-}

    jr      _testreset


testenemydat:
    .byte   $24,$30,$42,$41,$30,$51,$28,$02,$26,$03,$25
testenemyidx:
    .fill   32,$ff
    .byte   $03, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $04, $FF
    .byte   $FF, $FF, $05, $06, $FF, $08, $09, $FF, $FF, $FF, $FF, $FF, $FF, $0A, $FF, $FF
