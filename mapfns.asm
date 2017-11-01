    .module MAPFNS

	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	;
	; The map doesn't contain any enemy data. Use the enemy tables
	; to initialise the nasties.
    ;
    ; While we're here, draw a water layer in the top row.
    ;
    ; The map at 8k is known as the 'pure' map. it is used to reset
    ; the collison map which shadows the display in upper memory. 
	;
initmap:
    ld      hl,maplz
    ld      de,PUREMAP
    call    LZ48_decrunch

    ; create mines and stalactites in the pure map

    ld      b,NUMENEMY
    ld      hl,ENEMYIDX
    ld      de,PUREMAP

-:  ld      a,(hl)
    cp      $ff
    call    nz,processenemy

    inc     de
    inc     hl
    djnz    {-}

    ; set up the water

    ld      hl,PUREMAP
    ld      bc,600

-:  ld      a,(hl)
    and     a
    jr      nz,{++}     ; for some reason a single + doesn't work here

    ld      (hl),$bf

++: inc     hl
    dec     bc
    ld      a,b
    or      c
    jr      nz,{-}

    ret


processenemy:
    push    hl
    push    de
    push    bc

    push    de

    ld      d,ENEMYTBL / 256
    ld      e,a
    ld      a,(de)
    ld      b,a

    and     $80         ; get enemy type, either mine or stalac
    rlca
    rlca
    rlca
    rlca
    add     a,CH_STALAC
    ld      c,a

    ld      a,b
    and     $0f             ; get y
    call    mulby600        ; de = y * 600
    ex      de,hl

    pop     de              ; retrieve puremap + x
    add     hl,de

    ld      (hl),c          ; store enemy in pure map

    bit     BIT_STATIC,b    ; if it's a chained mine then draw the chain
    call    nz,drawchain

    pop     bc
    pop     de
    pop     hl
    ret



-:  ld      (hl),CH_CHAIN      ; draw a chain character into the map

drawchain:
    ld      de,600
    add     hl,de
    ld      a,(hl)
    and     a
    jr      z,{-}
    ret



	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	;
	; copy the pure map up to the mirror above 16k. copy the mirror
	; into the display file. update the display file to show water.
    ;
refreshmap:
    ld      hl,PUREMAP
    ld      de,D_MIRROR
    ld      bc,6000
    ldir

    ld      hl,PUREMAP
    ld      de,D_BUFFER
    ld      bc,6000
    ldir

    ret


resetmines:
    ld      hl,ENEMYTBL             ; remove the inactive bits from all entries
    ld      b,NUMENEMY
-:  res     BIT_INACT,(hl)
    inc     hl
    djnz    {-}
    ret


    ;
    ; return with carry set and hl = pointer to a mine struct if considered for action
    ;
findmine:
    ld      (consideration),hl

    ld      de,(scrollpos)      ; get the 'first mine' pointer
    ld      hl,ENEMYIDX
    add     hl,de
    ex      de,hl
    ld      b,32

-:  ld      a,(de)
    cp      $ff
    jr      z,_skipthis

    ld      h,ENEMYTBL / 256
    ld      l,a

    ; consider this mine
consideration = $+1
    call    0
    ret     c                   ; this is our mine!

_skipthis:
    inc     de
    djnz    {-}

    xor     a                   ; clear carry
    ret
