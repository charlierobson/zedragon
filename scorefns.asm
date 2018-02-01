    .module SCORE

resetscore:
    ld      hl,0
    ld      a,h
    ld      (score),hl
    ld      (bonus),a
    ret


showscoreline:
    ld      hl,scoreline
    ld      de,TOP_LINE
    ld      bc,40
    ldir
    ret


checkhi:
    ld      hl,(hiscore)
    ld      de,(score)
    and     a
    sbc     hl,de               ; results in carry set when score > hiscore
    ret     nc
    ex      de,hl
    ld      (hiscore),hl       ; update hiscore, return with C set
    ret



addscore:
    ld      hl,(score)
    ld      d,h
    ld      a,l
    add     a,c
    daa
    ld      l,a
    ld      a,h
    adc     a,b
    daa
    ld      h,a
    ld      (score),hl

    sub     d               ; d is high byte of score, 0HHLL0
    cp      1               ; did score just flip the 1000s digit?
    ret     c

    bit     0,h             ; return if odd number of 1000s
    ret     nz

    ld      hl,lives        ; yielding a bonus sub every 2000 pints
    ld      a,(hl)
    cp      9
    ret     z

    inc     (hl)
    call    showlives
    ld      a,SFX_EXTRASUB
    call    AFXPLAY
    ret


displayscore:
    ld      de,TOP_LINE+SCOREP
    ld      hl,(score)
    ld      a,h
    call    _bcd_a

    ld      a,l

_bcd_a:
    ld      h,a
    rrca
    rrca
    rrca
    rrca
    and     $0f
    add     a,$10
    call    show_char
    ld      a,h
    and     $0f
    add     a,$10

show_char:
    ld      (de),a
    inc     de
    ret



displayhi:
    ld      de,TOP_LINE+HIP
    ld      hl,(hiscore)
    ld      a,h
    call    _bcd_a

    ld      a,l
    jp      _bcd_a


displayzone:
    ld      de,TOP_LINE+ZONEP
    ld      a,(zone)
    add     a,17
    ld      (de),a
    ret



showlives:
    ld      a,(gamemode)
    and     a
    ld      a,(lives)
    jr      nz,{+}

    ld      a,14 - 16

+:  add     a,16
    ld      (TOP_LINE+LIVESP),a
    ret
