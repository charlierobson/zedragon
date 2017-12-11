    .module SCORE

_score:
    .word   0

_hiscore:
    .word   $0200


resetscore:
    ld      hl,0
    ld      (_score),hl
    ret

showscoreline:
    ld      hl,scoreline
    ld      de,TOP_LINE
    ld      bc,32
    ldir
    ret


checkhi:
    ld      hl,(_hiscore)
    ld      de,(_score)
    and     a
    sbc     hl,de               ; results in carry set when score > hiscore
    ret     nc
    ex      de,hl
    ld      (_hiscore),hl       ; update hiscore, return with C set
    ret



addscore:
    ld      hl,(_score)
    ld      d,h
    ld      a,l
    add     a,c
    daa
    ld      l,a
    ld      a,h
    adc     a,b
    daa
    ld      h,a
    ld      (_score),hl
    sub     d
    cp      $10
    ret     c

;    ld      hl,lives
;    inc     (hl)
    ret


displayscore:
    ld      de,TOP_LINE+6
    ld      hl,(_score)
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
    ld      de,TOP_LINE+16
    ld      hl,(_hiscore)
    ld      a,h
    call    _bcd_a

    ld      a,l
    jp      _bcd_a


displayzone:
    ld      de,TOP_LINE+25
    ld      a,(zone)
    add     a,17
    ld      (de),a
    ret

