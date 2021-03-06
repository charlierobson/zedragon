initmovedata:
    ld      hl,datax
    ld      de,$2e00
    ld      bc,$4000-$2e00
    ldir

    ld      hl,inputstatesx
    ld      de,inputsid
    ld      bc,inputstatesxsz
    ldir

    ret



mulby600:
    sla     a
    add     a,mul600tab & 255
    ld      ({+}+2),a
+:  ld      de,(mul600tab)
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
