    .module MAPFNS

    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    ; The map at 8k is known as the 'pure' map. it is used to reset
    ; the collison map which shadows the display in upper memory. 
    ;
    ; copy the compressed map data somewhere safe for later
    ;
initmap:
    ld      hl,maplz
    ld      de,PUREMAP
    ld      bc,maplzsz
    ldir
    ret


    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    ; copy the pure map up to the mirror above 16k. copy the mirror
    ; into the display file.
    ;
refreshmap:
    ld      hl,PUREMAP
    ld      de,D_MIRROR
    call    LZ48_decrunch

    ld      hl,D_MIRROR
    ld      de,D_BUFFER
    ld      bc,6000
    ldir

    ret


    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    ; remove any status bits from the enemy table
    ;
resetmines:
    ld      b,NUMENEMY
    ld      hl,ENEMYTBL

-:  res     BIT_INACT,(hl)
    inc     hl
    djnz    {-}

    ret


    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    ; using a supplied method we will consider each of the enemies
    ; currently on screen. if the consideration function returns
    ; with C set, that enemy is considered as selected.
    ;
findenemy:
    ld      (consideration),hl

    ld      de,(scrollpos)      ; find the first enemy on screen
    ld      hl,ENEMYIDX
    add     hl,de
    ex      de,hl
    ld      b,32                ; and check up to 32 screen x positions from there

-:  ld      a,(de)              ; get enemy table index, or ff if no enemy at this x pos
    cp      $ff
    jr      z,_skipthis

    ld      h,ENEMYTBL / 256    ; make pointer into enemy data table
    ld      l,a

    ld      a,(hl)              ; get enemy type
    and     $f0                 ; isolate type

consideration = $+1
    call    0
    ret     c                   ; this is our enemy!

_skipthis:
    inc     de
    djnz    {-}

    xor     a                   ; clear carry
    ret
