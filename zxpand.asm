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
    ld      a,1
    ld      (zxpandenabled),a

    ld      bc,$e007            ; go low, ram at 8-40k
    ld      a,$b2
    out     (c),a

    ld      hl,_readspandstick  ; install zxpand joystick read function
    ld      (jsreadfn),hl

    call    readhi

    ret


_readspandstick:
    call    $1ffe               ; get the joystick bits
    or      %00000111           ; we need some 1 bits for 'no joy' test
    ret


readhi:
    ld      a,(zxpandenabled)
    or      a
    ret     z

    ld      de,_ghiheader       ; write the eeprom request header (offset, length)
    ld      l,2
    ld      a,1
    call    $1ffc

    ld      bc,$e007            ; read eeprom & wait for command completion
    ld      a,$ae
    out     (c),a
    call    $1ff6

    ld      de,_ghiheader       ; read the eeprom data back
    ld      l,2+6
    ld      a,0
    call    $1ffc

    ld      a,(_ghiheader+2)    ; if zedragon data is present then data will contain
    cp      $2d                 ; hex 2d as its first byte. 2d = ZD - geddit? ;)
    ret     nz

    ; we have hiscore data

    ld      hl,_ghiheader+3
    ld      de,hiscore
    ldi
    ldi
    ldi
    ret


writehi:
    ld      a,(zxpandenabled)
    or      a
    ret     z

    ld      a,$2d               ; 2d = ZD - geddit? ;) id byte for hiscore data
    ld      (_ghiheader+2),a

    ld      hl,hiscore
    ld      de,_ghiheader+3
    ldi
    ldi
    ldi

    ld      de,_ghiheader       ; write eeprom data to zxpand
    ld      l,2+8
    ld      a,1
    call    $1ffc

    ld      bc,$e007            ; write eeprom & wait for command completion
    ld      a,$be
    out     (c),a
    call    $1ff6

    ret


_ghiheader:
    .byte   0,6,0,0,0,0,0,0
