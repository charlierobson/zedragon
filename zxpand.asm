    .module ZXPAND

;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
; return with z set if zxpand present
;
detectzxp:
    ld      bc,$e007
    ld      a,$55
    out     (c),a
    nop
    nop
    nop
    nop
    in      a,(c)
    cp      $0f
    ret     nz
    ld      a,$aa
    out     (c),a
    nop
    nop
    nop
    nop
    in      a,(c)
    cp      $f0
    ret


;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
;
; set RAM low and install the zxpand joystick reading function
;
enablezxpandfeatures:
    ld      bc,$e007            ; go low, ram at 8-40k
    ld      a,$b2
    out     (c),a

    ld      hl,_readspandstick  ; install zxpand joystick read function
    ld      (jsreadfn),hl
    ret


_readspandstick:
    call    $1ffe               ; get the joystick bits
    or      %00000111           ; we need some 1 bits for 'no joy' test
    ret
