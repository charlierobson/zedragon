initjoy:
    ld      a,$f8
    ld      (lastjoy),a
    ret

readjoy:
    call    $1ffe
    ld      hl,lastjoy
    cp      (hl)
    ret     z

    ld      (hl),a
    ld      l,a

    ld      a,(fire)        ; 0 - fire not pressed, 1 - fire just pressed, 3 - fire held, 2 - fire just released
    sla     a
    bit     6,l
    jr      nz,{+}
    or      1
+:  and     3
    ld      (fire),a
    ret
