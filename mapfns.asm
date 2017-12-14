    .module MAPFNS

    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    ; Deompress the map into the mirror display file above 16k,
    ; and then memcpy that into the display file.
    ;
refreshmap:
    ld      hl,PUREMAP
    ld      de,D_MIRROR
    call    decrunch

    ld      hl,D_MIRROR
    ld      de,D_BUFFER
    ld      bc,6000
    ldir

    ret


    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    ; Remove all 'busy'/'used' status bits from the enemy table.
    ;
resetenemies:
    ld      b,0
    ld      hl,enemydat

-:  res     BIT_INACT,(hl)
    inc     hl
    djnz    {-}

    ret


    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    ; Consider each of the enemies currently on screen. HL contains
    ; a pointer to a function which is used to consider each enemy.
    ; If the consideration function returns with C set, then that
    ; enemy is ready to run.
    ;
findenemy:
    ld      (consideration),hl

    ld      de,(scrollpos)      ; find the first enemy on screen
    ld      hl,enemyidx
    add     hl,de
    ex      de,hl
    ld      b,32                ; and check up to 32 screen x positions from there

-:  ld      a,(de)              ; get enemy table index, or ff if no enemy at this x pos
    cp      $ff
    jr      z,_skipthis

    ld      h,enemydat / 256    ; make pointer into enemy data table
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
