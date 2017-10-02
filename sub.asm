initsub:
    ld      hl,$0600
    ld      (subx),hl               ; sets subx = 0, suby = 1
    ld      (subaddress),hl     ; will sink the first sub 'undraw' into the ROM
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

    ld      a,(suby)        ; div by 8 then mul by 2 to index the mul600 table
    srl     a
    srl     a
    and     $fe

    ld      de,mul600
    add     a,e             ; add A to de
    ld      e,a
    adc     a,d
    sub     e
    ld      d,a

    ex      de,hl           ; retrieve multiplied value
    ld      a,(hl)
    inc     hl
    ld      h,(hl)
    ld      l,a
    ex      de,hl

    add     hl,de           ; character offset relative to visible window

    ld      de,(scrollpos)
    add     hl,de
    ld      de,D_BUFFER
    add     hl,de
    push    hl              ; character offset relative to display window

    ; undraw sub
    ; ideally we should do this as late as possible

    ld      hl,subundrawdata
    ld      de,(subaddress)
    ldi
    ldi
    ldi
    ex      de,hl
    ld      bc,600-3
    add     hl,bc
    ex      de,hl
    ldi
    ldi
    ldi

    ; save newposition as next frame's undraw location
    ; and preserve the characters under the sub

    pop     hl
    ld      (subaddress),hl
    ld      de,subundrawdata
    ldi
    ldi
    ldi
    ld      bc,600-3
    add     hl,bc
    ldi
    ldi
    ldi

    ; copy the pixel data corresponding to the characters
    ; under the sub to a new group of 3x2 characters - effectively a tiny bitmap

    ld      de,$22c0
    ld      a,(subundrawdata+0)
    call    copychar
    ld      a,(subundrawdata+3)
    call    copychar
    ld      a,(subundrawdata+1)
    call    copychar
    ld      a,(subundrawdata+4)
    call    copychar
    ld      a,(subundrawdata+2)
    call    copychar
    ld      a,(subundrawdata+5)
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

    ; now draw the mini bitmap containing the sub to the screen

    ld      hl,600
    ld      de,(subaddress)
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
    ld      hl,charsets
    ld      b,0
    bit     7,a
    jr      z,{+}

    and     $7f
    or      $40

+:  ld      c,a
    sla     c
    rl      b
    sla     c
    rl      b
    sla     c
    rl      b
    add     hl,bc
    ldi \ ldi
    ldi \ ldi
    ldi \ ldi
    ldi \ ldi
    ret
