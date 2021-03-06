    .module DISPLAYFNS

    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    ; Depack udg into a back-up store in high mem. Invert the
    ; first 512 bytes so all characters are inverted, which is
    ; how we need them fot the micro-bitmap work - sub/bullet.
    ;
initcharset:
    ld      hl,charsetx         ; depack all 3 pages of UDG to ensure charset 3 is available
    ld      de,UDG
    call    decrunch

    ld      hl,UDG              ; preserve first 2 pages of charsets in high mem
    ld      de,CHARSETS
    push    de                  ; stash pointer to chars in high mem that we will invert
    ld      bc,1024
    ldir

    pop     hl
    call   _inverness           ; invert first 256 bytes of 512

    ; then fall back in to do the rest

_inverness:
    ld      a,(hl)
    xor     $ff
    ld      (hl),a
    inc     hl
    djnz    _inverness
    ret


    ;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    ;
    ; Copy the backup character set data from high memory into
    ; place for the character generator to access. (Un)invert the
    ; characters we inverted in the first place.
    ;
installmaincharset:
    ld      hl,CHARSETS
    ld      de,UDG
    push    de                  ; stash pointer to chars in UDG area that we will (un)invert
    ld      bc,1024
    ldir
    pop     hl
    call    _inverness          ; (un)invert the first 256 bytes
    jp      _inverness          ; then the remaining




	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	;
    ; Clear the display to white. Reset scroll pointers.
    ;
cls:
    xor     a
    ld      (ScrollXFine),a
    ld      hl,D_BUFFER
    ld      (MapStart),hl
    ld      bc,6000
    call    fillmem

    ld      hl,TOP_LINE
    ld      bc,40
    call    fillmem

    ld      hl,BOTTOM_LINE
    ld      bc,40
    ;
    ; falls in to ...

	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	;
    ; Fill BC bytes of memory at HL with value in A register.
    ;
fillmem:
    dec     bc
    ld      d,h
    ld      e,l
    inc     de
    ld      (hl),a
    ldir
    ret



animatecharacters:
    ld      a,(FrameCounter)
    and     15
    jr      nz,testevery8

    ; every 16 frames

    ld      a,(UDG+$181)        ; shooter, $30
    xor     $66 ^ $7e
    ld      (UDG+$181),a
    and     $3c                 ; laser, $31
    ld      (UDG+$18e),a

    ld      a,(UDG+$189)        ; laser
    xor     $a7 ^ $e5
    ld      (UDG+$189),a

    ld      a,(waterframe)
    inc     a
    ld      (waterframe),a
    and     7
    ld      hl,wateranimation
    ld      d,0
    ld      e,a
    add     hl,de
    ld      a,(hl)
    ld      (UDG+$37f),a
    ld      (CHARSETS+$37f),a

    xor     a

testevery8:
    and     7
    ret     nz

    ; every 8 frames

    ld      hl,flaganimation
    ld      a,(FrameCounter)
    rra
    rra
    rra
    and     %00000011
    add     a,a
    add     a,l
    ld      l,a
    ld      a,(hl)
    ld      (UDG+$198),a         ; ship rear end, $33
    inc     hl
    ld      a,(hl)
    ld      (UDG+$199),a

    ld      hl,shooterframe
    ld      c,5                     ; 6 frames, 0..5 inclusive
    call    updatecounter
    ld      de,shooteranimation
    add     a,e
    ld      e,a
    ld      a,(de)
    ld      (UDG+$183),a
    ld      (UDG+$18b),a
    ret



scroll:
    ld      hl,(scrollpos)
    ld      de,600-32
    and     a
    sbc     hl,de
    ret     z

    ld      hl,scrollflags
    res     7,(hl)                  ; scrollflag.7 = 1 when scrolled

    bit     0,(hl)                  ; scrollflag.0 = 1 when scrolling enabled
    ret     z

    ld      a,(scrolltick)
    inc     a
    ld      (scrolltick),a
    srl     a
    srl     a
    and     7

    ld      hl,finescroll
    cp      (hl)
    ret     z

    ld      (hl),a

    and     a                       ; return if not at next char boundary
    ret     nz

    ld      hl,scrollflags
    set     7,(hl)                  ; scrollflag.7 = 1 when scrolled a character

    ld      hl,(scrollpos)
    inc     hl
    ld      (scrollpos),hl
    ret


displayocount:
    ld      de,TOP_LINE
    ld      a,(ocount)
    call    hexout
    ld      a,(ocountmax)
    call    hexout
    ret




hexout:
    push    af
    rrca
    rrca
    rrca
    rrca
    call    {+}
    pop     af
+:  and     $0f
    cp      10
    jr      c,{+}
    add     a,7
+:  add     a,$10
    ld      (de),a
    inc     de
    ret


bullet1sp:
    .word   0
bullet2sp:
    .word   0
bullet1ch:
    .byte   0

    .module COPYCHAR

copycharx:
    ld      a,(bullet1sp)
    sub     l
    jr      nz,_tryp2
    ld      a,(bullet1sp+1)
    set     7,a
    res     6,a
    sub     h
    jr      nz,_tryp2

; should this be from mirror or 0?
    push    af
    inc     hl
    push    hl
    ld      hl,bchar
    jp      _cpnquit

_tryp2:
    ld      a,(bullet2sp)
    sub     l
    jr      nz,copychar
    ld      a,(bullet2sp+1)
    set     7,a
    res     6,a
    sub     h
    jr      nz,copychar

; should this be from mirror or 0?
    push    af
    inc     hl
    push    hl
    ld      hl,bchar+8
    jp      _cpnquit

copychar:
    ld      a,(hl)
    push    af
    inc     hl
    push    hl

    ld      hl,eightuffuffs    
    and     a
    jr      z,_cpnquit

    ld      hl,CHARSETS
    ld      b,0             ; prep to receive carry
    sla     a               ; if this char is +64 (codes $80..$c0) then C is set
    rr      b               ; 0, or $80 if this was a +64 char
    or      b               ; add bit 7 back into the function as bit 6 after a shift
    ld      b,0
    ld      c,a
    rl      b               ; bc * 8
    sla     c
    rl      b
    sla     c
    rl      b
    add     hl,bc

_cpnquit:
    ldi \ ldi               ; copy pixel data to new character pointed at by DE
    ldi \ ldi
    ldi \ ldi
    ldi \ ldi

    pop     hl
    pop     af
    ret

eightuffuffs:
    .fill   8



dlp:
    .word   DRAWLIST_0
elp:
    .word   DRAWLIST_1



	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	;
	; put a character draw request in the drawlist. address is in
    ; hl, character in a
	;
char2dlist:
    push    de
    push    hl
    ex      de,hl
    ld      hl,(dlp)
    ld      (hl),e
    inc     hl
    ld      (hl),d
    inc     hl
    ld      (hl),a
    inc     hl
    ld      (dlp),hl
    pop     hl
    pop     de
    ret


nme2dlistandmirror:
    push    de
    push    hl
    ld      hl,(dlp)
    ld      e,(iy+OUSER+3)
    ld      (hl),e
    inc     hl
    ld      d,(iy+OUSER+4)
    ld      (hl),d
    inc     hl
    ld      (hl),a
    inc     hl
    set     7,d
    res     6,d
    ld      (de),a
    ld      (dlp),hl
    pop     hl
    pop     de
    ret

	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	;
	; render the screen according to the characters generated by
    ; the previous frame of activity, after undrawing using the
    ; characters from the frame before that...
	;
    ; each frame characters will be queued here, in DRAWLIST_0 on
    ; even frames, else DRAWLIST_1.
    ;
    ; when the new frame starts, characters drawn last frame will
    ; be undrawn using the addresses added last frame, and char
    ; data from the mirror map. then new characters will be drawn.
    ;
    ; the newly emptied list will then be filled with new chars,
    ; ready for rendering at the start of next frame.
    ;
updatescreen:
    ld      hl,(elp)            ; erase list pointer
    inc     l
    dec     l
    jr      z,_draw             ; skip undraw if list empty

    ld      b,l                 ; low byte contains count * 3, offset of first free item
    ld      l,0                 ; reset pointer to start of list

    ; undraw old

_eraloop:
    ld      e,(hl)              ; character address
    inc     hl
    ld      d,(hl)
    inc     hl
    inc     hl                  ; skip character code, undraw from data in mirror map
    push    de
    set     7,d                 ; display -> mirror
    res     6,d
    ld      a,(de)              ; get undraw char
    pop     de                  ; recover display pointer
    ld      (de),a

    ld      a,l                 ; b = loop counter / offset of last draw item
    cp      b
    jr      nz,_eraloop

    ; draw new

_draw:
    ld      hl,(dlp)            ; erase list pointer
    inc     l
    dec     l
    jr      z,_swap

    ld      b,l                 ; low byte contains count * 3, offset of first free item
    ld      l,0                 ; reset pointer to start of list

_drwloop:
    ld      e,(hl)
    inc     hl
    ld      d,(hl)
    inc     hl
    ld      a,(hl)
    inc     hl
    ld      (de),a

    ld      a,l                 ; b = loop counter / offset of last draw item
    cp      b
    jr      nz,_drwloop

_swap:
    ld      de,(elp)            ; swap draw and erase list pointers
    ld      e,0                 ; resetting draw count in the process
    ld      hl,(dlp)
    ld      (elp),hl
    ld      (dlp),de

    ret
