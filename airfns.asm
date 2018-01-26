    .module AIR

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

    cp      6
    jr      nz,_decrease

    ; increase air

    ld      c,4                 ; increase air every 5 cycles
    call    updatecounter
    ret     nz                  ; not time to modify air value yet

    ld      a,(airlevel)        ; don't overpressurise
    cp      AIR_MAX
    ret     z

    inc     a
    ld      (airlevel),a
    jr      _display

_decrease
    ld      c,11                 ; decrease air every few game cycles
    call    updatecounter
    ret     nz                  ; not time to modify air value yet

    ld      a,(airlevel)
    dec     a
    ld      (airlevel),a

    cp      32
    jr      nc,_display

    bit     0,a
    jr      nz,_display

    ; make sound

    push    af
    and     16
    rrca
    rrca
    rrca
    rrca
    add     a,SFX_ALARM0
    call    AFXPLAY
    pop     af

_display:
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
