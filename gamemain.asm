
;               HEAD
;    ...[mines][core][bullets][gamemain/attract][sub][explosions]...

dofspecial:
    .word   $70
	.byte	$78,$28

gamemain:
    call    cls
    call    resetscore
    call    enablegamesound

	ld		a,r
	ld		(rng+1),a

    ld      hl,scrollflags          ; enable scrolling
    set     0,(hl)

    ld      hl,dofs
    ;ld      hl,dofspecial
    ld      (restartPoint),hl

    ld      a,4
    ld      (lives),a
    call    showlives

    ld      a,(laserframe)
    ld      (laserframe+1),a

resetafterdeath:
    call    refreshmap
    call    resetair
    call    resetenemies

    ld      hl,(restartPoint)
    ld      c,(hl)
    inc     hl
    ld      b,(hl)
    inc     hl
    ld      (scrollpos),bc
    push    hl

	call	getobject
	ld		bc,subfunction
	call	initobject
	call	insertobject_afterthis

    pop     de                      ; points to restart X,Y (pixel positions)
    ex      de,hl                   ; de now points to sub's user data area
    ldi
    ldi

aliveloop:
    ld      a,(advance)
    cp      1
    jr      nz,{+}
    ld      hl,(restartPoint)
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    ld      (restartPoint),hl
+:

    ld      hl,(gameframe)
    inc     hl
    ld      (gameframe),hl

    ld      hl,laserframe
    ld      a,(hl)
    and     $80
    inc     hl
    cp      (hl)
    jr      z,{+}

    ld      (hl),a
    and     a
    jr      nz,{+}

    ld      a,15
    call    AFXPLAY

+:  call    scroll
    ld      a,(scrollflags)
    rlca
    jr      nc,{+}              ; haven't scrolled the bg, so we don't need to update any pointers

    ld      hl,(restartPoint)   ; do something with a 'count till next restart point' ??
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    push    hl
    ld      e,(hl)
    inc     hl
    ld      d,(hl)
    ld      hl,(scrollpos)
    and     a
    sbc     hl,de
    pop     hl
    jr      nz,{+}

    ld      (restartPoint),hl

    ld      a,12
    call    AFXPLAY

+:  call    displayocount
    xor     a
    ld      (ocount),a
    YIELD

    call    updateair
    call    enemyinitiator

    ld      de,0
    ld      (bulletHitX),de

    ld      a,(FRAMES)              ; play ping sfx every so often
    and     127
    call    z,AFXPLAY

    ld      a,(collision)
    and     a
    jp      z,aliveloop


    ; sub's dead
deadsub:
    xor     a
    ld      (iy+OUSER),a

    ld      a,(lives)
    dec     a
    ld      (lives),a
    call    showlives

-:  call    displayocount
    xor     a
    ld      (ocount),a
    YIELD

    inc     (iy+OUSER)
    jr      nz,{-}

    ld      a,(ocount)              ; wait until all objects apart from MAIN and GAMEMAIN are dead
    cp      2
    jr      nz,{-}

    ld      a,(lives)
    and     a
    jp      nz,resetafterdeath

    call    silencesound

	call	getobject
	ld		bc,attract
	call	initobject
	call	insertobject_afterhead

	DIE
