    .module TROLLDISPLAY

setupdisplay:
	push	ix
	pop		hl
	ld		(previx),hl
	ld		ix,DRAW_MAP
    ret

previx:
	.word	0

restoredisplay:
	ld		hl,(previx)
	push	hl
	pop		ix
    ret



waitvsync:
	ld		hl,FrameCounter
	ld		a,(hl)
-:	cp		(hl)
	jr		z,{-}
	ret


; ----------------
; MapStart: where the drawing begins on the map, used to scroll per character
; ScrollXFine: 0-7, resolution is every second pixel
DRAW_MAP:
; waste time
	ld	b,7			; 7
	djnz	$			; 13/8
	ld	bc,$1234		; 10
; prepare font pointer
	ld	a,$24			; 7
	ld	i,a			; 9
; reset LINECNTR in ULA
	in	a,($fe) 		; 11
	out	($ff),a 		; 11
; prepare to draw 8 lines of status text
	ld	b,8			; 7
; draw the text
	jp	TOP_LINE + $8000	; 10
TOP_LINE_DONE:
; waste time
	ld	b,12			; 7
	djnz	$			; 13/8
	nop				; 4
	nop				; 4
; prepare font pointer
	ld	a,$21			; 7
	ld	i,a			; 9
; save shadow registers
	exx				; 4
	push	bc			; 11
	push	de			; 11
	push	hl			; 11
; init shadow registers
	ld	hl,(MapStart)		; 16
	ld	de,DISPLAY_WIDTH	; 10
	add	hl,de			; 11
	ld	de,MAP_WIDTH		; 10
	ld	c,$c9			; 7 $c9 = ret
; change dfile+32 to a ret
	ld	b,(hl)			; 7
	ld	(hl),c			; 7
	exx				; 4
; save real stack
	ld	(StackSave),sp		; 20
; init line-stack
	ld	sp,LINE_STACK_START	; 10
MapStart = $ + 1
	ld	hl,MAP_DATA		; 10
	set	7,h			; 8
	ld	de,MAP_WIDTH		; 10
	ld	b,DISPLAY_HEIGHT_RASTERS; 7
; waste time depending on ScrollXFine
ScrollXFine = $ + 1
	ld	a,0			; 7
	and	6			; 7
	sla	a			; 8
	add	a,DELAY1 & 255	; 7
	ld	(DelayTable1),a 	; 13
; reset LINECNTR in ULA
	in	a,($fe) 		; 11
	out	($ff),a 		; 11
; clear carry
	xor	a			; 4
DelayTable1 = $ + 1
	jp	DELAY1 		; 10
	.align 16
DELAY1:
	and	(hl)			; 7
	jp	AFTER_DELAY1		; 10
;.DELAY1:
	dec	bc			; 6
	jp	AFTER_DELAY1		; 10
;.DELAY2:
	ret	c			; 5
	jp	AFTER_DELAY1		; 10
;.DELAY3:
	nop				; 4
	jp	AFTER_DELAY1		; 10
AFTER_DELAY1:
; draw the picture as specified
	jp	(hl)			; 4

; ----------------
AFTER_LINE0:
; dec line counter
	dec	b			; 4
	jp	z,DRAW_MAP_DONE 	; 10/10 previous line was last
; reinit line stack
	ld	sp,LINE_STACK		; 10
; waste time
	.repeat 9
		nop			; 4 * 9 = 36
	.loop
	ret	z			; 5
; draw 1 raster of 32 chars
	jp	(hl)			; 4 + (32 * 4) + 10 = 142 (65 left)

; ----------------
AFTER_LINE1_6:
; dec line counter
	dec	b			; 4
	jp	z,DRAW_MAP_DONE 	; 10/10 previous line was last
; waste time
	.repeat 11
		nop			; 4 * 11 = 44
	.loop
	xor	0			; 7
; draw 1 raster of 32 chars
	jp	(hl)			; 4 + (32 * 4) + 10 = 142 (65 left)

; ----------------
AFTER_LINE7:
; dec line counter
	dec	b			; 4
	jp	z,DRAW_MAP_DONE 	; 10/10 previous line was last
; point to next line of text
	add	hl,de			; 11
; restore old dfile-data
	exx				; 4
	ld	(hl),b			; 7
; change dfile+32 to a ret
	add	hl,de			; 11
	ld	b,(hl)			; 7
	ld	(hl),c			; 7
	exx				; 4
; draw 1 raster of 32 chars
	jp	(hl)			; 4 + (32 * 4) + 10 = 142 (65 left)

; ----------------
AFTER_TOP_LINE:
; dec line counter
	dec	b			; 4
	jp	z,TOP_LINE_DONE	; 10/10 previous line was last
; waste time
	ld	a,0			; 7
	inc	de			; 6
; draw 1 raster of 40 chars
	jp	TOP_LINE + $8000	; 10

; ----------------
AFTER_BOTTOM_LINE:
; dec line counter
	dec	b			; 4
	jp	z,BOTTOM_LINE_DONE	; 10/10 previous line was last
; waste time
	ld	a,0			; 7
	inc	de			; 6
; draw 1 raster of 40 chars
	jp	BOTTOM_LINE + $8000	; 10

; ----------------
DRAW_MAP_DONE:
; restore stack
	ld	sp,(StackSave)		; 20
; waste time depending on ScrollXFine
	ld	a,(ScrollXFine) 	; 13
	and	6			; 7
	sla	a			; 8
	add	a,DELAY2 & 255	; 7
	ld	(DelayTable2),a 	; 13
	xor	a			; 4
DelayTable2 = $ + 1
	jp	DELAY2 		; 10
	.align 16
DELAY2:
	nop				; 4
	jp	AFTER_DELAY2		; 10
;.DELAY1:
	ret	c			; 5
	jp	AFTER_DELAY2		; 10
;.DELAY2:
	dec	hl			; 6
	jp	AFTER_DELAY2		; 10
;.DELAY3:
	and	(hl)			; 7
	jp	AFTER_DELAY2		; 10
AFTER_DELAY2:
; waste time
	.repeat 5
		nop			; 4 * 5 = 20
	.loop
; prepare font pointer
	ld	a,$24			; 7
	ld	i,a			; 9
; restore dfile+32
	exx				; 4
	ld	(hl),b			; 7
	exx				; 4
; increment FrameCounter
	ld	hl,FrameCounter 	; 10
	inc	(hl)			; 11
; prepare for bottom margin and VSYNC
VCentreBot = $+1
	ld	a,BOTTOM_MARGIN 	; 7
	neg				; 8
	inc	a			; 4
	ex	af,af'			; 4
	ld	ix,GENERATE_VSYNC	; 14
; reset LINECNTR in ULA
	in	a,($fe) 		; 11
	out	($ff),a 		; 11
; prepare to draw 8 lines of status text
	ld	b,8			; 7
; draw the text
	jp	BOTTOM_LINE + $8000	; 10
BOTTOM_LINE_DONE:
; NMI on
	out	($fe),a 		; 11
	call	vsynctask
; restore shadow registers
	exx
	pop	hl			; 10
	pop	de			; 10
	pop	bc			; 10
	exx
; restore registers
	pop	hl			; 10
	pop	de			; 10
	pop	bc			; 10
	pop	af			; 10
; return to application
	ret				; 10
; jp vsynctask ; crashes :(

; ----------------
GENERATE_VSYNC:
; VSync start
	in	a,($fe) 		; 11

;; read some keys
;	ld	bc,$effe		; 10 read keys 0-6
;	in	a,(c)			; 12
;	ld	(Keys0),a		; 13
;	ld	bc,$f7fe		; 10read keys 1-5
;	in	a,(c)			; 12
;	ld	(Keys1),a		; 13
; = 70
;
;; waste time, 4 rasters worth of VSync
;	ld	b,57			; 7
;	djnz	$			; 13/8
; = 756
;
; total T = 70 + 756 = 826

    ld      de,INPUT._kbin  ; 10
    ld      bc,$fefe        ; 10
	; = 20
    .repeat 8
        in      a,(c)       ; 12
        rlc     b           ; 8
        ld      (de),a      ; 7
        inc     de          ; 6  = 33
    .loop
	; = 8 * 33 = 264

	;waste time
	ld		b,40		; 7
	djnz	$			; 13/8
	; = (40*13)+8+7 = 535

	; for timing only
	ld	a,TOP_MARGIN		; 7

; total T = 535 + 264 + 20  + 7 = 826

; prepare for top margin
VCentreTop = $+1
	ld	a,TOP_MARGIN		; 7
	neg				; 8
	inc	a			; 4
; prepare a' for NMI-counter
	ex	af,af'			; 4
; reset the row counter at the correct raster to enable fine scrolling Y
	ld	ix,DRAW_MAP		; 14
; restore registers
	pop	hl			; 10
	pop	de			; 10
	pop	bc			; 10
	pop	af			; 10
; NMI on, VSync stop
	out	($fe),a 		; 11
; return to application
	ret				; 10

; ----------------
; It would have been more logical to do have a stack 0-7, but there are
; no cycles left after line7.
; The solution is to rotate the line-stack so that line0 is the last,
; and deal with the arithmetic that entails.
	.align 256
LINE_STACK:
	.word	AFTER_LINE1_6
	.word	AFTER_LINE1_6
	.word	AFTER_LINE1_6
	.word	AFTER_LINE1_6
	.word	AFTER_LINE1_6
	.word	AFTER_LINE1_6
	.word	AFTER_LINE7
LINE_STACK_START:
	.word	AFTER_LINE0



;----------------
MAP_WIDTH = 600
MAP_HEIGHT = 10
MAP_DATA = D_BUFFER

DISPLAY_WIDTH = 32
DISPLAY_HEIGHT_RASTERS = 80
DISPLAY_HEIGHT = DISPLAY_HEIGHT_RASTERS / 8

TOTAL_RASTERS	= 312			;PAL=312, NTSC=262
VSYNC_RASTERS	= 4
VISIBLE_RASTERS = DISPLAY_HEIGHT_RASTERS + 8 + 8
WASTED_RASTERS	= 5
TOTAL_MARGIN	= TOTAL_RASTERS - VISIBLE_RASTERS - VSYNC_RASTERS - WASTED_RASTERS
TOP_MARGIN	= (TOTAL_MARGIN / 2) - 16
BOTTOM_MARGIN	= TOTAL_MARGIN - TOP_MARGIN


StackSave	.word	0
FrameCounter	.byte	0

TOP_LINE:
	.fill	40,0
	jp	AFTER_TOP_LINE

BOTTOM_LINE:
	.fill	40,0
	jp	AFTER_BOTTOM_LINE
