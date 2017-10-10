; memory at $3f00
;
; $3f00 - $3f13  mul-by-600 table
; $3f14 - $3f27
; $3f28          reserved
; $3f29 - $3f3a
; $3f3b          reserved
; $3f3c - $3f3f
; $3f40 - $3fff  task data blocks

inittables:
    xor     a
    ld      hl,$3f00
    ld      bc,$100
    call    zeromem

    ld      hl,mul600
    ld      de,$3f00
    ld      bc,20
    ldir

    ld      a,(iy+$28)
    ld      ($3f28),a
    ld      a,(iy+$3b)
    ld      ($3f3b),a

    ld      iy,$3f00
    ret


mulby600:
    sla     a
    ld      (toff1),a
    inc     a
    ld      (toff2),a
toff1 = $+2
    ld      e,(iy+0)
toff2 = $+2
    ld      d,(iy+0)
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
