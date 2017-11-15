AIR_MAX = 25*8

resetair:
    xor     a
    ld      (airupdatecounter),a
    ld      a,AIR_MAX
    ld      (airlevel),a
    ld      hl,airline
    ld      de,BOTTOM_LINE
    ld      bc,32
    ldir
    ret


updateair:
    ld      hl,airupdatecounter

    ld      a,6 ;(airflag)         ; sub's usage of air
    cp      6
    jr      nz,decreaseair


increaseair:
    ld      c,5                 ; increase air every 5 cycles
    call    updatecounter
    ret     nz                  ; not time to modify air value yet

    ld      a,(airlevel)        ; don't overpressurise
    cp      AIR_MAX
    ret     z

    inc     a
    ld      (airlevel),a
    jr      displayair

decreaseair:
    ld      c,11                 ; decrease air every 11 cycles
    call    updatecounter
    ret     nz                  ; not time to modify air value yet

    ld      a,(airlevel)

    ; quit when air all gone
    or      a
    ret     z

    dec     a
    ld      (airlevel),a

    cp      32
    jr      nc,displayair

    bit     0,a
    jr      nz,displayair

    push    af
    and     16
    rrca
    rrca
    rrca
    rrca
    add     a,13
    call    AFXPLAY
    pop     af

displayair:
    push    af

    ld      hl,BOTTOM_LINE+5
    srl     a
    srl     a
    srl     a
    add     a,l                         ; hl aligned to 32 bytes, so no need to carry
    ld      l,a

    pop     af
    and     7
    add     a,6
    ld      (hl),a
    cp      7+6
    ret     nz

    xor     a
    inc     hl
    ld      (hl),a
    ret
