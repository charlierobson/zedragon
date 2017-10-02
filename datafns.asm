inittables:
    ld      hl,mul600
    ld      de,$403c
    ld      bc,20
    ldir
    ret


updatecounter:
    inc     c           ; the reset value is bumped
    ld      a,(hl)
    or      a
    jr      nz,{+}      ; if the value was already zero we need to reset it
    ld      a,c         ; the reset is done here
+:  dec     a           ; the dec is always performed which is why reset value was bumped
    ld      (hl),a
    ret                 ; we return with Z set when the counter has reached zero


mulby600:
    sla     a
    add     a,$3c
    ld      (toff1),a
    inc     a
    ld      (toff2),a
toff1 = $+2
    ld      e,(iy+0)
toff2 = $+2
    ld      d,(iy+0)
    ret
