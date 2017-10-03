initsub:
    ld      hl,$0600
    ld      (subx),hl               ; sets subx = 0, suby = 1
    ld      (oldsubaddress),hl      ; we'll sink the first sub 'undraw' into the ROM
    ret


movesub:
    ld      hl,suby

    ld      a,(up)          ; min y = 6
    and     1
    jr      z,{+}
    ld      a,(hl)
    cp      7
    jr      c,{+}
    dec     (hl)

+:  ld      a,(down)        ; max y = $47
    and     1
    jr      z,{+}
    ld      a,(hl)
    cp      $47
    jr      nc,{+}
    inc     (hl)

+:  ld      hl,subx

    ld      a,(left)        ; min x = 0
    and     1
    jr      z,{+}
    ld      a,(hl)
    and     a
    jr      z,{+}
    dec     (hl)

+:  ld      a,(right)       ; max x = 160
    and     1
    jr      z,{+}
    ld      a,(hl)
    cp      $a0
    jr      nc,{+}
    inc     (hl)
+:  ret


drawsub:
    ; calculate address of sub in the map, relative to the current scroll position

    ld      a,(subx)            ; pixel -> char conversion
    srl     a
    srl     a
    srl     a
    ld      l,a
    ld      h,0

    ld      a,(suby)            ; div by 8 to get character line then mul by 600
    srl     a
    srl     a
    srl     a
    call    mulby600            ; de = a * 600
    add     hl,de               ; character offset relative to visible window

    ld      de,(scrollpos)
    add     hl,de

    ld      de,D_BUFFER
    add     hl,de

    ld      (subaddress),hl     ; sub's address in the display memory

    ; find the character codes that appear under the sub in its new position
    ; use the map cache as the code source because the display is dirty at this point

    res     6,h                 ; point hl at mapcache in high memory
    set     7,h
    ld      de,bgchardata    ; cache the characters from the map copy
    ldi
    ldi
    ldi
    push    de
    ld      de,600-3
    add     hl,de
    pop     de
    ldi
    ldi
    ldi

    ; copy the pixel data corresponding to the characters
    ; under the sub to a new group of 3x2 characters - effectively a tiny bitmap

    ld      de,$22c0
    ld      a,(bgchardata+0)
    call    copychar
    ld      a,(bgchardata+3)
    call    copychar
    ld      a,(bgchardata+1)
    call    copychar
    ld      a,(bgchardata+4)
    call    copychar
    ld      a,(bgchardata+2)
    call    copychar
    ld      a,(bgchardata+5)
    call    copychar

    ; now we've effectively built our tiny bitmap we can render the sub into it
    ; choose which set of 3 pre-scrolled sub tiles to use

    ld      a,(subx)        ; pixel offset 0..7
    and     7
    ld      c,a             ; * 3
    add     a,a
    add     a,c
    sla     a               ; * 8
    sla     a
    sla     a 

    ; get pointers to sub pixel data within the character set

    ld      h,$22
    ld      l,a
    ld      de,$22c0
    ld      a,(suby)
    and     7
    or      e
    ld      e,a

    ld      b,3

--: push    bc

    ; copy 8 sub pixels into bg bitmap

    ld      b,8

-:  ld      c,(hl)          ; get sub pixels
    ld      a,(de)          ; get bg pixels
    and     c               ; merge sub into background
    ld      (de),a

    inc     hl
    inc     de
    djnz    {-}

    ; step across the dest bitmap

    ld      a,8
    add     a,e
    ld      e,a
    adc     a,d
    sub     e
    ld      d,a

    pop     bc
    djnz    {--}

    ; undraw the old sub pos

    ld      hl,(oldsubaddress)      ; point hl into clean map
    ld      e,l
    ld      d,h    
    res     6,h
    set     7,h
    ldi
    ldi
    ldi
    ld      de,600-3
    add     hl,de
    ld      e,l
    ld      d,h    
    res     6,h
    set     7,h
    ldi
    ldi
    ldi

    ; now draw the mini bitmap containing the sub to the screen

    ld      hl,600
    ld      de,(subaddress)
    ld      (oldsubaddress),de
    add     hl,de
    ld      a,$98
    ld      (de),a
    inc     a
    inc     de
    ld      (hl),a
    inc     a
    inc     hl
    ld      (de),a
    inc     a
    inc     de
    ld      (hl),a
    inc     a
    inc     hl
    ld      (de),a
    inc     a
    inc     de
    ld      (hl),a

    ret


copychar:
    ld      hl,charsets     ; source data pointer

    ld      b,0             ; forward initialisation of counter

    bit     7,a             ; is this a character from the $+64 set
    jr      z,{+}

    and     $7f             ; high character, so adjust offset in char map
    or      $40

+:  ld      c,a             ; char number -> byte offset
    sla     c
    rl      b
    sla     c
    rl      b
    sla     c
    rl      b
    add     hl,bc

    ldi \ ldi               ; copy pixel data to new character pointed at by DE
    ldi \ ldi
    ldi \ ldi
    ldi \ ldi
    ret
