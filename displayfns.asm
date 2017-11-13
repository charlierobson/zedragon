    .module DISPLAYFNS

	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	;
    ; Depack udg into its home at 8K.
    ;
    ; Copy the first 128 chars up to higher memory, inverting the
    ; non-inverted half as we go. This  makes the sub rendering easier.
    ;
initcharsets:
    ld      hl,charsetlz
    ld      de,UDG
    call    LZ48_decrunch

    ; copy game character set up high

    ld      hl,UDG
    ld      de,CHARSETS
    ld      bc,1024
    ldir

    ; bc is 0 from the ldir, ready for djnz
    ; call the inverter to do 256 bytes...
    ;
    ld     hl,CHARSETS
    call   _inverness
    ;
    ; ...then drop straight back into it to do the next 256
    ;
_inverness:
    ld      a,(hl)
    xor     $ff
    ld      (hl),a
    inc     hl
    djnz    _inverness
    ret


	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	;
    ; Kill time until we notice the FRAMES variable change
    ;
    ; A display has just been produced, and now we can continue.
    ;
waitvsync:
    ld      hl,FRAMES
    ld      a,(hl)
-:  cp      (hl)
    jr      z,{-}
    ret


	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	;
    ; Clear the display to white. Reset scroll pointers.
    ;
cls:
    xor     a

    ld      hl,D_BUFFER
    ld      bc,6000
    call    fillmem

    ld      (scrollpos),bc          ; bc is 0 at thispoint
    ld      (BUFF_OFFSET),bc

    ld      hl,TOP_LINE
    ld      bc,32
    call    fillmem

    ld      hl,BOTTOM_LINE
    ld      bc,32
    ;
    ; falls in to ...

	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	;
    ; Fill BC bytes of memory at HL with value in A register.
    ;
fillmem:
    dec     bc
    ld      d,h
    ld      e,l
    inc     de
    ld      (hl),a
    ldir
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
    cp      12              ; reset counter every complete cycle
    jr      nz,{+}

    xor     a

+:  ld      (titlecredidx),a

    bit     0,a             ; if bit 1 is set show one of the two repeated items 
    jr      z,{+}

    ld      a,6*2

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

    ld      de,BOTTOM_LINE
    ld      bc,32
    ldir
    ret


animatecharacters:
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
    ld      (UDG+$1a8),a         ; ship rear end, $35
    inc     hl
    ld      a,(hl)
    ld      (UDG+$1a8+1),a

    ld      a,(UDG+$181)        ; shooter, $30
    xor     $66 ^ $7e
    ld      (UDG+$181),a
    and     $3c                 ; laser, $31
    ld      (UDG+$18e),a

    ld      a,(UDG+$189)        ; laser
    xor     $a7 ^ $e5
    ld      (UDG+$189),a

    ld      a,(waterframe)
    inc     a
    ld      (waterframe),a
    and     7
    ld      hl,wateranimation
    ld      d,0
    ld      e,a
    add     hl,de
    ld      a,(hl)
    ld      (UDG+$3ff),a
    ld      (CHARSETS+$3ff),a

    xor     a

testevery8:
    and     7
    ret     nz

    ; every 8 frames

    ld      hl,shooterframe
    ld      c,5                     ; 6 frames, 0..5 inclusive
    call    updatecounter
    ld      de,shooteranimation
    add     a,e
    ld      e,a
    ld      a,(de)
    ld      (UDG+$183),a
    ld      (UDG+$18b),a
    ret



scroll:
    ld      hl,scrollflags
    res     7,(hl)                  ; scrollflag.7 = 1 when scrolled

    bit     0,(hl)                  ; scrollflag.0 = 1 when scrolling enabled
    ret     z

    ld      hl,scrolltick           ; return if it's not time to scroll
    ld      c,23
    call    updatecounter
    ret     nz

    ld      hl,(scrollpos)

    ld      a,l                     ; check if we've hit the end. don't scroll if so
    cp      (600-32) & 255
    jr      nz,{+}

    ld      a,h
    cp      (600-32) / 256
    ret     z

+:  ; do actual scroll

    inc     hl
    ld      (scrollpos),hl
    ld      hl,scrollflags
    set     7,(hl)                  ; scrollflag.7 = 1 when scrolled
    ret


showsubcoords:
    ld      a,(subx)
    ld      de,TOP_LINE+7
    call    hexout
    xor     a
    ld      (de),a
    ld      a,(suby)
    call    hexout
    xor     a
    ld      (de),a
    ld      a,(subx)
    and     7
    call    hexout
    ret


displayocount:
    ld      a,(ocount)
    ld      de,TOP_LINE
    call    hexout
    ret


displaylastk:
    ld      de,TOP_LINE+23
    ld      a,(LAST_K+1)
    call    hexout
    ld      a,(LAST_K)
    call    hexout
    ld      de,TOP_LINE+28
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
+:  add     a,$10
    ld      (de),a
    inc     de
    ret


binaryout:
    ld      b,8
    ld      c,$80

-:  ld      a,l
    and     c
    ld      a,16
    jr      z,{+}
    inc     a
+:  ld      (de),a
    inc     de
    rrc     c
    djnz    {-}
    ret


copychar:
    ld      a,(hl)
    push    af
    inc     hl
    push    hl

    ld      hl,eightuffuffs    
    and     a
    jr      z,{+}

    ld      hl,CHARSETS
    ld      b,0             ; prep to receive carry
    sla     a               ; if this char is +64 (codes $80..$c0) then C is set
    rr      b               ; 0, or $80 if this was a +64 char
    or      b               ; add bit 7 back into the function as bit 6 after a shift
    ld      b,0
    ld      c,a
    rl      b
    sla     c
    rl      b
    sla     c
    rl      b
    add     hl,bc

:+  ldi \ ldi               ; copy pixel data to new character pointed at by DE
    ldi \ ldi
    ldi \ ldi
    ldi \ ldi

    pop     hl
    pop     af
    ret

eightuffuffs:
    .fill   8