    .align  8
kbin:
    .fill   8

readinput:
    call    $1ffe               ; get the joystick bits
    or      %00000111
    ld      (LAST_J),a

    ld      de,kbin             ; read the keyboard, building a table at (de)
    ld      c,$fe
    ld      b,8

-:  ld      a,c                 ; read each of the 8 half rows
    in      a,($fe)
    ld      (de),a
    rlc     c
    inc     de
    djnz    {-}

    ; point at first input state block
    ;
    ld      hl,inputstates

    call    updateinputstate ; (up)
    call    updateinputstate ; (down)
    call    updateinputstate ;  etc.
    call    updateinputstate ;
    call    updateinputstate
    call    updateinputstate

    ; fall into here for last input - quit

updateinputstate:
    ld      a,(hl)          ; input info table
    ld      (uibittest),a   ; get opcode for j/s bit test

    inc     hl
    ld      a,(hl)          ; half-row index
    inc     hl
    ld      de,kbin         ; keyboard bits table pointer - 8 byte aligned
    or      e
    ld      e,a             ; add offset to table
    ld      a,(de)          ; get key input bits
    and     (hl)            ; result will be 0 if required key is down
    inc     hl
    jr      z,{+}           ; skip joystick read if pressed - h is 0

    ld      a,(LAST_J)

+:  sla     (hl)            ; (key & 3) = 0 - not pressed, 1 - just pressed, 2 - just released and >3 - held

uibittest = $+1
    bit     0,a             ; if a key was already detected a will be 0 so this test succeeds
    jr      nz,{+}          ; otherwise joystick bit is tested - skip if bit = 1 (not pressed)

    set     0,(hl)          ; signify impulse

+:  inc     hl              ; ready for next input in table
    ret
