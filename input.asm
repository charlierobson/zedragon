initjoy:
    ld      a,$f8
    ld      (lastjoy),a
    ret



readjoy:
    call    $1ffe
    ld      l,a             ; cache joystick value

    ld      a,(LAST_K)      ; cache 'enter' key
    and     $40
    ld      h,a
    ld      a,(LAST_K+1)
    and     $02
    or      h
    ld      h,a

    ld      a,(fire)        ; 0 - fire not pressed, 1 - fire just pressed, 3 - fire held, 2 - fire just released
    sla     a

    bit     6,l
    jr      z,{+}           ; z set if fire pressed, so don't bother with testing kb

    ld      a,h             ; h 0 if enter pressed
    and     a
    jr      nz,{++}

+:  or      1               ; indicates that an input is asserted

++: and     3               ; we only keep bottom 2 bits
    ld      (fire),a
    ret
