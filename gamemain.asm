    .module GAMEMAIN

_RSPL = OUSER+1
_RSPH = OUSER+2
_COUNTER = OUSER+3


gamemain:
    call    cls

    YIELD

    xor     a                       ; zone number
    ld      (zone),a

    ld      a,4                     ; set initial lives
    ld      (lives),a

    call    installmaincharset          ; (re)install the main character set    
    call    showscoreline
    call    displayscore
    call    displayhi
    call    showlives
    call    enablegamesound

    xor     a
    ld      (ocount),a
    ld      (ocountmax),a

    ld      a,r                     ; seed the rng
    ld      (rng+1),a

    ld      hl,scrollflags          ; enable scrolling
    set     0,(hl)

    ld      hl,dofs                 ; set starting zone
    ld      (iy+_RSPL),l
    ld      (iy+_RSPH),h

    ld      a,(laserframe)          ; can't remember why but reasons
    ld      (laserframe+1),a

    ld      hl,playermovesub        ; install the sub remote controller
    ld      (submvfunc),hl

    ld      a,$ff
    ld      (pauseposs),a           ; pausing is possible

_resetafterdeath:
    xor     a                       ; reset collision flag that gets set when sub dies
    ld      (collision),a

    call    refreshmap

    call    resetair
    call    resetenemies

    ld      l,(iy+_RSPL)            ; get sub position from the restart info
    ld      h,(iy+_RSPH)
    ld      c,(hl)
    inc     hl
    ld      b,(hl)
    inc     hl
    ld      (scrollpos),bc
    push    hl

	call	getobject               ; spawn the sub
	ld		bc,subfunction
	call	initobject
	call	insertobject_beforehead

    pop     hl                      ; points to restart X,Y (pixel positions)
    ldi
    ldi

_gameloop:
    call    _advancecheck
    call    featurecheck

    ld      hl,(gameframe)
    inc     hl
    ld      (gameframe),hl

    call    LASER._makeSound

    call    scroll
    ld      a,(scrollflags)
    rlca

    call    c,zonecheck             ; coarse scroll has occurred - check zone

    ;call    displayocount
    xor     a
    ld      (ocount),a
    YIELD

    call    animatecharacters

    ld      a,(bonus)
    and     a
    jr      z,{+}
 
    sub     2
    ld      (bonus),a
    ld      bc,2
    call    addscore

+:  call    displayscore
    call    checkhi
    call    c,displayhi

    call    enemyinitiator

    ld      a,(FrameCounter)          ; play ping sfx (id = 0) every so often
    and     127
    call    z,AFXPLAY2

    ld      a,(collision)       ; loop until the sub has collided with something or beaten the boss
    cp      $ff
    jp      z,_dienow

    cp      0
    jp      z,_gameloop

    ; sub's dead
    ld      a,(gamemode)
    ld      l,a
    ld      a,(lives)
    sub     l
    ld      (lives),a
    call    showlives

    ld      (iy+_COUNTER),100        ; counts up until roll-over: 150ish = ~3 sec

_interlifedelay:
    xor     a
    ld      (ocount),a
    ;call    displayocount
    call    scroll
    YIELD

    call    animatecharacters

    inc     (iy+_COUNTER)
    jr      nz,_interlifedelay

_nomoreo:
    ld      a,(ocount)              ; wait until all objects apart from MAIN and GAMEMAIN are dead
    cp      2
    jr      nz,_nomoreo

    ld      a,(lives)           ; if no more subs are available then it's game over
    and     a
    jp      nz,_resetafterdeath

    ld      bc,teletypergameover
    call    objectafterhead

_dienow:
    xor     a
    ld      (pauseposs),a           ; pausing now not possible

    call    writehi

    DIE




featurecheck:
    ld      a,(feature)
    cp      1
    ret     nz

    ld      a,SFX_LECTRIC    ; let player know
    call    AFXPLAY

    ld      a,(gamemode)
    xor     1
    ld      (gamemode),a
    call    showlives
    ret



_advancecheck:
    ld      a,(advance)
    dec     a
    ret     nz

    ld      a,(zone)
    ld      hl,maxzone
    cp      (hl)
    ret     z

    ld      a,SFX_ZONEREACH     ; let player know
    call    AFXPLAY

    ld      l,(iy+_RSPL)
    ld      h,(iy+_RSPH)
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    ld      (iy+_RSPL),l
    ld      (iy+_RSPH),h
    jr      _showzone


zonecheck:
    ; check if we've hit a restart point

    ld      l,(iy+_RSPL)        ; this is definitely a bit starbucks
    ld      h,(iy+_RSPH)
    inc     hl                  ; look past the current restart info
    inc     hl
    inc     hl
    inc     hl
    push    hl
    ld      e,(hl)              ; next restart x into de
    inc     hl
    ld      d,(hl)
    ld      hl,(scrollpos)
    and     a
    sbc     hl,de
    pop     hl
    ret     nz                  ; we haven't reached the restart yet

    ld      (iy+_RSPL),l        ; store the new restart info pointer
    ld      (iy+_RSPH),h

_showzone:
    ld      hl,zone             ; increment zone number
    inc     (hl)

    ld      a,(maxzone)         ; if zone > maxzone then bump maxzone
    cp      (hl)
    jr      nc,{+}

    inc     a
    ld      (maxzone),a

+:  call    displayzone

    ld      a,SFX_ZONEREACH     ; let player know
    jp      AFXPLAY
