readjoy:
    call    $1ffe
    or      %00000111
    ld      (LAST_J),a

    ; point at first input state block
    ld      hl,inputstates

    call    updateinputstate ; (up)
    call    updateinputstate ; (down)
    call    updateinputstate
    call    updateinputstate
    call    updateinputstate

    ; fall into here for last input - quit

updateinputstate:
    ld      a,(hl)
    ld      (uibittest),a
    inc     hl

    ld      bc,(LAST_K) 
    ld      a,b
    and     (hl)
    inc     hl
    ld      b,a
    ld      a,c
    and     (hl)
    inc     hl
    or      b
    ld      b,a
    jr      z,{+}           ; skip joystick read if pressed - h is 0

    ld      a,(LAST_J)
    ld      b,a

+:  ld      a,(hl)           ; 0 - not pressed, 1 - just pressed, 3 - held, 2 - just released
    sla     a               ;  C <- [7......0] <- 0

uibittest = $+1
    bit     0,b
    jr      nz,{+}          ; skip if fire bit 1

    or      1               ; indicate that the input is asserted

+:  and     3               ; we only keep bottom 2 bits - perhaps keep more bits for timing purposes?
    ld      (hl),a
    inc     hl
    ret
