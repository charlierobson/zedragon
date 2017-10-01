updatecounter:
    inc     c           ; the reset value is bumped
    ld      a,(hl)
    or      a
    jr      nz,{+}      ; if the value was already zero we need to reset it
    ld      a,c         ; the reset is done here
+:  dec     a           ; the dec is always performed which is why reset value was bumped
    ld      (hl),a
    ret                 ; we return with Z set when the counter has reached zero

