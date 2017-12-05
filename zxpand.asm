;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
; return with z set if zxpand present
;
detectzxp:
    ld      bc,$e007
    ld      a,$55
    out     (c),a
    in      a,(c)
    cp      $0f
    ret     nz
    ld      a,$aa
    out     (c),a
    in      a,(c)
    cp      $f0
    ret


enablezxpandfeatures:
    ld      bc,$e007            ; go low, ram at 8-40k
    ld      a,$b2
    out     (c),a

    ld      hl,readspandstick   ; install zxpand joystick read function
    ld      (jsreadfn),hl
    ret


readspandstick:
    call    $1ffe               ; get the joystick bits
    or      %00000111           ; we need some 1 bits for 'no joy' test
    ret
