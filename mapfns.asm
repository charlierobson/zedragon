puremap = $2600


	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	;
	; copy the map from its load position in screen ram down to its
	; resting place in the 8k block after the character sets. this
    ; map at 8k is known as the 'pure' map. it is used to reset
    ; the collison map which shadows the display in upper memory. 
	;
initmap:
    ld      hl,D_BUFFER
    ld      de,puremap
    ld      bc,6000
    ldir

    ; reset mines and stalactites in the pure map

    ld      b,minecount
    ld      hl,minetbl

mineloop:
    push    bc

    ld      e,(hl)      ; x char => de
    inc     hl
    ld      d,(hl)
    inc     hl
    ld      a,(hl)      ; y => a
    inc     hl
    push    hl

    ex      de,hl       ; hl = x char
    call    mulby600    ; de = a * 600
    add     hl,de
    ld      de,puremap
    add     hl,de
    ex      de,hl

    pop     hl
    ld      a,(hl)      ; get enemy type
    and     $3f         ; mask off modifier bits
    bit     6,(hl)      ; but remember state of modifier
    inc     hl
    ld      (de),a
    call    nz,drawchain

    pop     bc
    djnz    mineloop

    ; set up the water

    ld      hl,puremap
    ld      bc,600

-:  ld      a,(hl)
    and     a
    jr      nz,rmp0

    ld      (hl),$bf

rmp0:
    inc     hl
    dec     bc
    ld      a,b
    or      c
    jr      nz,{-}

    ret




-:  xor     a
    ld      (de),a

undrawchain:
    ld      a,$58           ; de += 600
    add     a,e
    ld      e,a
    ld      a,$02
    adc     a,d
    ld      d,a

    ld      a,(de)          ; if (de) == 0, make (de) = chain character, else done
    cp      CH_CHAIN
    jr      z,{-}

    ret



-:  ld      a,CH_CHAIN      ; draw a chain character into the map
    ld      (de),a

drawchain:
    ld      a,$58           ; de += 600
    add     a,e
    ld      e,a
    ld      a,$02
    adc     a,d
    ld      d,a

    ld      a,(de)
    and     a
    jr      z,{-}

    ret



	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	;
	; copy the pure map up to the mirror above 16k. copy the mirror
	; into the display file. update the display file to show water.
    ;
refreshmap:
    ld      hl,puremap
    ld      de,D_BUFFER+$4000
    ld      bc,6000
    ldir

    ld      hl,puremap
    ld      de,D_BUFFER
    ld      bc,6000
    ldir

    ret


resetmines:
    ld      bc,minecount            ; remove the inactive bits from all entries
    ld      hl,minetbl+3
-:  res     7,(hl)
    inc     hl
    inc     hl
    inc     hl
    inc     hl
    dec     bc
    ld      a,b
    or      c
    jr      nz,{-}

    ld      hl,minetbl              ; reset the 'first mine' pointer
    ld      (minebase),hl

findfirstmine:
    ld      hl,(minebase)           ; find the first mine on screen
    ld      de,(scrollpos)

-:  push    hl
    ld      a,(hl)
    inc     hl
    ld      h,(hl)
    ld      l,a
    sbc     hl,de
    pop     hl
    ld      (minebase),hl
    ret     nc                  ; hl points to first on screen mine

    inc     hl
    inc     hl
    inc     hl
    inc     hl
    jr      {-}


    ;
    ; return with carry set and hl = pointer to a mine struct if considered for action
    ;
findmine:
    ld      (consideration),hl
    ld      hl,(scrollpos)
    ld      de,32
    add     hl,de
    ex      de,hl

    ld      hl,(minebase)

-:  push    hl
    ld      a,(hl)
    inc     hl
    ld      h,(hl)
    ld      l,a
    sbc     hl,de
    pop     hl
    ret     nc                  ; no more mines on screen

    ; consider this mine
consideration = $+1
    call    0
    ret     c                   ; this is our mine!

    inc     hl
    inc     hl
    inc     hl
    inc     hl
    jr      {-}

