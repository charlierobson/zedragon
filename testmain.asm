    .module TESTMAIN

;               HEAD
;    ...[mines][core][bullets][gamemain/attract][sub][explosions]...

testmain:
	ld		a,r
	ld		(rng+1),a

    ld      hl,D_BUFFER
    ld      de,D_MIRROR
    ld      bc,6000
    ldir

    ld      hl,testenemyidx
    ld      de,enemyidx
    ld      bc,64
    ldir
    ld      hl,testenemydat
    ld      de,enemydat
    ld      bc,10
    ldir

    call    resetair

    ld      bc,32
    ld      (scrollpos),bc
    ld      a,32
    ld      (subx),a
    ld      (suby),a

    call    resetmines

	call	getobject
	ld		bc,subfunction
	call	initobject
	call	insertobject_afterthis

_aliveloop:
    ld      hl,(gameframe)
    inc     hl
    ld      (gameframe),hl

    call    displayocount
    xor     a
    ld      (ocount),a
    YIELD

    call    enemyinitiator

    ld      de,0
    ld      (bulletHitX),de
    call    updatebullets

    call    startbullet

    ld      a,(collision)
    and     a
    jp      z,_aliveloop

    ; sub's dead

    xor     a
    ld      (iy+OUSER),a

-:  call    updatebullets

    call    displayocount
    xor     a
    ld      (ocount),a
    YIELD

    inc     (iy+OUSER)
    jr      nz,{-}

    jp      _aliveloop


testenemydat:
    .byte   $24,$30,$42,$41,$30,$51,$28,$02,$26,$03,$25
testenemyidx:
    .fill   32,$ff
    .byte   $03, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $04, $FF
    .byte   $FF, $FF, $05, $06, $FF, $08, $09, $FF, $FF, $FF, $FF, $FF, $FF, $0A, $FF, $FF
