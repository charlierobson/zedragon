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

+:  ld      a,(down)        ; max y = $48
    and     1
    jr      z,{+}
    ld      a,(hl)
    cp      $48
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
    ; copy the pixel data corresponding to the characters under the sub
    ; to a new group of 3x2 characters - effectively a tiny bitmap
    ;
    ; on-screen:
    ;   $98 $9a $9c
    ;   $99 $9b $9d
    ;
    ; it's like this because the rendering of the sub char is easier using columns
    ; all the character data is inverted

    res     6,h                 ; point hl at mapcache in high memory
    set     7,h
    push    hl
    ld      de,$22c0            ; address of char $98
    call    copychar
    ld      e,$d0               ; ... char 9a
    call    copychar
    ld      e,$e0               ; 9c
    call    copychar
    pop     hl
    ld      bc,600
    add     hl,bc
    ld      e,$c8
    call    copychar
    ld      e,$d8
    call    copychar
    ld      e,$e8
    call    copychar

    ; now we've effectively built our tiny bitmap we can render the sub into it
    ; choose which set of 3 pre-scrolled sub tiles to use.

    ld      a,(subx)        ; pixel offset 0..7
    and     7
    ld      c,a
    add     a,a
    add     a,c             ; * 3, a is offset to set of 3 characters

    sla     a
    sla     a
    sla     a               ; * 8, a is offset to 1st byte of sub char data 

    ; get pointers to sub pixel data within the character set

    ld      h,$22           ; form address in character set $22xx
    ld      l,a

    ld      de,$22c0        ; pointer to 1st byte within column of 16 that we will render to
    ld      a,(suby)
    and     7
    or      e
    ld      e,a

    ld      b,3             ; 3 characters

    xor     a               ; zero out collision bits
    ld      (collision),a

--: push    bc

    ; copy 8 sub pixels into bg bitmap

    ld      b,8             ; 8 lines

-:  ld      c,(hl)          ; get sub pixels
    ld      a,(de)          ; get bg pixels
    push    af
    and     c               ; merge sub into background
    ld      (de),a

    pop     af              ; get bg pixels
    or      c               ; or together
    xor     $ff             ; any 0 bits are collisions
    ld      c,a
    ld      a,(collision)
    or      c
    ld      (collision),a

    inc     hl
    inc     de
    djnz    {-}

    ; step across the dest bitmap to the next column
    ; we know the address won't overflow the bottom 8 bits

    ld      a,8
    add     a,e
    ld      e,a

    pop     bc
    djnz    {--}

    ; undraw the old sub

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
    res     7,d
    set     6,d
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

    ; show collision bits

    ld      a,(collision)
    ld      ($2418),a       ; collision char

    ld      a,$03           ; show collision character
    ld      (TOP_LINE+26),a

    ret

