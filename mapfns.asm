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
    ld      hl,enemyidx
    ld      de,puremap

mineloop:
    push    bc

    ld      a,(hl)      ; x char => de
    cp      $ff
    jr      z,noenemyinthiscol

    push    hl          ; cache idx table
    push    de          ; cache puremap ptr

    ld      d,enemytbl / 256
    ld      e,a
    ld      a,(de)

    push    af
    and     $f0         ; get character
    rlca
    rlca
    rlca
    rlca
    add     a,CH_STALAC
    ld      c,a

    pop     af
    and     $0f         ; get y
    call    mulby600    ; de = a * 600
    ex      de,hl

    pop     de          ; retrieve puremap + x
    add     hl,de

    ld      (hl),c      ; store enemy in pure map

    pop     hl          ; retrieve enemy index table

noenemyinthiscol:
    inc     de
    inc     hl
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
    ld      hl,enemytbl             ; remove the inactive bits from all entries
    ld      b,enemycount
-:  res     BIT_INACT,(hl)
    inc     hl
    djnz    {-}

    ld      hl,scrollval            ; reset the 'first mine' pointer
    ld      de,enemyidx
    add     hl,de
    ld      (minebase),hl
    ret


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
