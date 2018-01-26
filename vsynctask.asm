vsynctask:
	push	iy				;stc (and ayfx) player uses iy
GO_PLAYER = $+1
	ld		a,0
	and		a
SOUNDFN = $+1
	call	nz,0
	pop		iy

	ret

	ld		hl,laserframe
	xor		a
	inc		(hl)
	jp		m,{+}

	ld		l,(hl)
	ld		h,1
	ld		a,(hl)
	and		$08

+:	xor		$ff

	ld		hl,UDG+$2b8			; character $97 - laser  we want a shimmering laser effect
	ld		de,CHARSETS+$2b8

	ld		(hl),a
	ld		(de),a
	inc		hl
	inc		de
	ld		(hl),a
	ld		(de),a
	inc		hl
	inc		de
	ld		(hl),a
	ld		(de),a
	inc		hl
	inc		de
	ld		(hl),a
	ld		(de),a
	inc		hl
	inc		de
	ld		(hl),a
	ld		(de),a
	inc		hl
	inc		de
	ld		(hl),a
	ld		(de),a
	inc		hl
	inc		de
	ld		(hl),a
	ld		(de),a
	inc		hl
	inc		de
	ld		(hl),a
	ld		(de),a
	RET

laserframe:
	.word	0
