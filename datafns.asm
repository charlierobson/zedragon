; memory at $3f00
;
; $3f00 - $3f13  mul-by-600 table
; $3f14 - $3f27
; $3f28          reserved
; $3f29 - $3f3a
; $3f3b          reserved
; $3f3c - $3fff
;
; memory at $8000
;
; $8000 - $81bf
; $81C0 - $84ff .. display mirror
; $8500 - $9bff
; $9c00 - $9fff task tables (16 x 64 bytes)


inittables:
    xor     a
    ld      hl,$3f00
    ld      bc,$100
    call    zeromem

    ld      hl,$8000
    ld      bc,$2000
    call    zeromem

    ld      hl,mul600
    ld      de,$3f00
    ld      bc,20
    ldir

    ld      a,($4028)
    ld      ($3f28),a
    ld      a,($403b)
    ld      ($3f3b),a

    ld      bc,64
    ld      hl,$9c00
    ld      de,nullfn

-:  push    hl
    pop     iy

    ld      a,($4028)
    ld      (iy+$28),a
    ld      a,($403b)
    ld      (iy+$3b),a
    ld      a,$c3
    ld      (iy+0),a
    ld      (iy+1),e
    ld      (iy+2),d
    add     hl,bc
    ld      a,h
    cp      $a0
    jr      nz,{-}

    ret


findfnslot:
    push    bc
    push    hl
    push    de

    ld      bc,64
    ld      hl,$9c00
    ld      de,nullfn

-:  push    hl
    pop     iy
    ld      a,(iy+1)
    cp      e
    jr      nz,{+}
    ld      a,(iy+2)
    cp      d
    jr      z,gotone

+:  add     hl,bc
    ld      a,h
    cp      $a0
    jr      nz,{-}

gotone:
    pop     de
    pop     hl
    pop     bc
    ret                         ; nz = no slot



funfuns:
    ld      iy,$9c00
    call    $9c00
    ld      iy,$9c40
    call    $9c40
    ld      iy,$9c80
    call    $9c80
    ld      iy,$9cc0
    call    $9cc0
    ld      iy,$9d00
    call    $9d00
    ld      iy,$9d40
    call    $9d40
    ld      iy,$9d80
    call    $9d80
    ld      iy,$9dc0
    call    $9Dc0
    ld      iy,$9e00
    call    $9e00
    ld      iy,$9e40
    call    $9e40
    ld      iy,$9e80
    call    $9e80
    ld      iy,$9ec0
    call    $9ec0
    ld      iy,$9f00
    call    $9f00
    ld      iy,$9f40
    call    $9f40
    ld      iy,$9f80
    call    $9f80
    ld      iy,$9fc0
    jp      $9fc0


fnstop:
    ld      hl,nullfn
    ld      (iy+1),l
    ld      (iy+2),h
nullfn:
    ret


mulby600:
    sla     a
    ld      (toff1),a
toff1 = $+2
    ld      de,($3f00)
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
