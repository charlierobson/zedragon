; memory at $2000
;
; $2000 - $3eff
; $3f00 - $3f13  mul-by-600 table
; $3f14 - $3fff
;
; memory at $8000
;
; $8000 - $81bf
; $81C0 - $9930  display mirror
; $9940 - $9fff  task tables (24 x 64 bytes + lists)


inittables:
    xor     a
    ld      hl,$3f00
    ld      bc,$100
    call    zeromem

    ld      hl,mul600
    ld      de,$3f00
    ld      bc,20
    ldir

    ret


mulby600:
    sla     a
    ld      ({+}+2),a
+:  ld      de,($3f00)
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



rng:
	ld		a,0
	ld		b,a
	add		a,a
	add		a,a
	add		a,b
	inc		a
	ld		(rng+1),a
	ret
