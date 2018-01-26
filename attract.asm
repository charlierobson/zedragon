    .module ATTRACT

attract:
    call    cls

    YIELD

    call    installmaincharset          ; (re)install the main character set

    ld      hl,scrollpos
    ld      (hl),32
    xor     a
    ld      (ScrollXFine),a
    YIELD

    ld      hl,titletunelz
    ld      de,D_MIRROR
    call    decrunch

    call    resetcredits
    call    enabletitlesound

    ld      hl,titlescrn
    ld      de,D_BUFFER
    call    decrunch

    ld      hl,scrollpos                ; ensure scroll is at 0 by waiting a cycle
    ld      (hl),0
    YIELD

_attractloop:
    ld      a,(FrameCounter)
    and     127
    call    z,updatecredits

    ld      a,(up)
    cp      1
    call    z,screenup
    ld      a,(down)
    cp      1
    call    z,screendown

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


screenup:
    ld      a,(VCentreTop)
    cp      $3d
    ret     z
    dec     a
    jr      setmargin

screendown:
    ld      a,(VCentreTop)
    cp      $66
    ret     z
    inc     a

setmargin:
    ld      (VCentreTop),a
    ld      b,a
    ld      a,TOTAL_MARGIN
    sub     b
    ld      (VCentreBot),a
    ret


    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    ; Start displaying the credits at the 0th item.
    ;
resetcredits:
    xor     a
    jr      {+}


    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    ; Cycle through the credits, showing 'press fire' every other
    ; time. The new credit goes in the bottom line of the display.
    ;
updatecredits:
    ld      a,(titlecredidx)
    inc     a
    cp      14              ; reset counter every complete cycle
    jr      nz,{+}

    xor     a

+:  ld      (titlecredidx),a

    bit     0,a             ; if bit 1 is set show one of the two repeated items 
    jr      z,{+}

    ld      a,7*2

+:  and     $fe
    sla     a
    sla     a
    sla     a
    sla     a
    ld      hl,titlecreds

    add     a,l             ; add A to HL
    ld      l,a
    adc     a,h
    sub     l
    ld      h,a

    ld      de,BOTTOM_LINE+5
    ld      bc,32
    ldir

    ret
