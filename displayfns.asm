setupudg:
    ld      hl,charsets
    ld      de,$2000
    ld      bc,3*$200
    ldir
    ld      a,$21
    ld      i,a

    ; invert the source character set in memory,
    ; makes the subpixel rendering easier

    ld      hl,charsets
    ld      b,0

-:  ld      a,(hl)
    xor     $ff
    ld      (hl),a
    inc     hl
    ld      a,(hl)
    xor     $ff
    ld      (hl),a
    inc     hl
    djnz    {-}

    ret


waitvsync:
    ld      hl,FRAMES
    ld      a,(hl)
-:  cp      (hl)
    jr      z,{-}
    ret


cls:
    xor     a
    ld      hl,D_BUFFER
    ld      bc,6000
    call    zeromem

    ld      (BUFF_OFFSET),bc    ; bc is 0 at thispoint

    ld      hl,TOP_LINE
    ld      bc,32
    call    zeromem

    ld      hl,BOTTOM_LINE
    ld      bc,32

zeromem:
    dec     bc
    ld      d,h
    ld      e,l
    inc     de
    ld      (hl),a
    ldir
    ret


drawtitle:
    ld      hl,titlescreen
    ld      de,D_BUFFER + 604
    ld      b,9
-:  push    bc
    ld      bc,24
    ldir
    push    hl
    ex      de,hl
    ld      de,600-24
    add     hl,de
    ex      de,hl
    pop     hl
    pop     bc
    djnz    {-}
    ret


resetcredits:
    xor     a
    ld      (FRAMES),a
    jr      {+}

 
updatecredits:
    ld      a,(titlecredidx)
    inc     a
    cp      12          ; reset counter every complete cycle
    jr      nz,{+}

    xor     a

+:  ld      (titlecredidx),a

    bit     0,a         ; if bit 1 is set show one of the two repeated items 
    jr      z,{+}

    ld      a,6*2

+:  and     $fe
    sla     a
    sla     a
    sla     a
    sla     a
    ld      hl,titlecreds
    add     a,l         ; add A to HL
    ld      l,a
    adc     a,h
    sub     l
    ld      h,a

    ld      de,BOTTOM_LINE
    ld      bc,32
    ldir
    ret


drawmap:
    ld      hl,map
    ld      de,D_BUFFER
    ld      bc,6000
    ldir
    ret


animatecharacters:
    ; animate shooters
    ld      a,(FRAMES)
    and     15
    jr      nz,testevery8

    ; every 16 frames

    ld      hl,flaganimation
    ld      a,(FRAMES)
    rra
    rra
    rra
    rra
    and     %00000011
    add     a,a
    add     a,l
    ld      l,a
    ld      a,(hl)
	ld      ($2000+$f8),a
    inc     hl
    ld      a,(hl)
	ld      ($2000+$f8+1),a

    ld      a,($2000+$101)
    xor     $66 ^ $7e
    ld      ($2000+$101),a
    and     $3c
    ld      ($2000+$10e),a

    ld      a,($2000+$109)
    xor     $a7 ^ $e5
    ld      ($2000+$109),a

    ld      a,(waterframe)
    inc     a
    ld      (waterframe),a
    and     7
    ld      hl,wateranimation
    ld      d,0
    ld      e,a
    add     hl,de
    ld      a,(hl)
    ld      ($2000+$3ff),a
    ld      (charsets+$3ff),a

    xor     a

testevery8:
    and     7
    ret     nz

    ; every 8 frames

    ld      a,(shooterframe)
    and     a
    jr      nz,{+}
    ld      a,6
+:  dec     a
    ld      (shooterframe),a
    ld      de,shooteranimation
    add     a,e
    ld      e,a
    ld      a,(de)
    ld      ($2000+$103),a
    ld      ($2000+$10b),a
    ret


resetscroll:
    ld      hl,0
    ld      (scrollpos),hl
    ret


scroll:
    ld      a,(scrolltick)
    and     a
    jr      nz,{+}

    ld      a,23+1

+:  dec     a
    ld      (scrolltick),a
    ret     nz

    ld      hl,(scrollpos)  
    ld      a,l
    cp      (600-32) & 255
    jr      nz,{+}

    ld      a,h
    cp      (600-32) / 256
    ret     z

+:  inc     hl
    ld      (scrollpos),hl

    ld      (BUFF_OFFSET),hl
    ret


displaylastk:
    ld      de,BOTTOM_LINE+23
    ld      a,(LAST_K+1)
    call    hexout
    ld      a,(LAST_K)
    call    hexout
    ld      de,BOTTOM_LINE+28
    ld      a,(LAST_K+1)
    xor     $ff
    call    hexout
    ld      a,(LAST_K)
    xor     $ff

hexout:
    push    af
    rrca
    rrca
    rrca
    rrca
    call    {+}
    pop     af
+:  and     $0f
    cp      10
    jr      c,{+}
    add     a,7
+:  add     a,$90
    ld      (de),a
    inc     de
    ret
