initjoy:
    ld      a,$f8
    ld      (lastjoy),a
    ret



readjoy:
    ld      hl,(LAST_K)

    ld      de,$0240        ; mask for enter key - done this way to potentially allow redefinable keys
    ld      a,h
    and     d
    ld      h,a
    ld      a,l
    and     e
    or      h
    ld      h,a
    jr      z,{+}           ; skip joystick read if pressed - h is 0

    call    $1ffe
    ld      h,a             ; cache joystick value

+:  ld      a,(fire)        ; 0 - fire not pressed, 1 - fire just pressed, 3 - fire held, 2 - fire just released
    sla     a               ;  C <- [7......0] <- 0

    bit     6,h
    jr      nz,{+}          ; skip if fire bit zero

    or      1               ; indicate that the input is asserted

+:  and     3               ; we only keep bottom 2 bits - perhaps keep more bits for timing purposes?
    ld      (fire),a
    ret
