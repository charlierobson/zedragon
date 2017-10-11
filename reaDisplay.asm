    BUFFER_WIDTH    .equ 600
    NUMBER_OF_ROWS  .equ 10


setupdisplay:
	CALL	cls
	LD		HL,($400C)
	LD		(REAL_D_FILE),HL

	LD		HL,FAKE_D_FILE
	LD		($400C),HL
	PUSH	HL
	SET		7,H
	POP		DE
	EX		DE,HL
	LDI
	LDI
	LDI
	LDI
	RET

restoredisplay:
	OUT		($FD),A
REAL_D_FILE = $+1
	LD		HL,$0000
	OUT		($FE),A
	RET


FAKE_D_FILE:
	HALT	
	CALL	OUR_DISPLAY_ROUTINE

OUR_DISPLAY_ROUTINE:
;HERE WE DO THE TOP LINE FIRST, WE ARE COUNTING CYCLE TILL THE FIRST PIXEL OF THE NEXT SCAN LINE
;AND WE NEED TO RESET THE LINECOUNTER IT HAS TO BE DONE AT PRECISELY THE RIGHT TIME
	DI								;4	21
	POP		HL						;10	31

;@CHARLIE
;THIS IS THE OFFSET FOR THE WINDOW YOU WANT TO DISPLAY
;IT IS THE TOP LEFT OF A RECTANGLE 32 CHARS WIDE BY YOU NUMBER OF ROWS

BUFF_OFFSET =  $+1
	LD		HL,$0000				;10	41
;ADD BUFFER ADDRESS AND SET BIT 15                                            
	LD		DE,D_BUFFER + $8000		;10	51
	ADD		HL,DE 					;11	62
	LD		(HLST),HL				;16	78
;NOW ADD 32 AND CLEAR BIT 15 ( THIS IS THE BYTE THAT WILL GET A RET INSTRUCTION )       
	LD		DE,$8000 + 32 			;10	88
	ADD		HL,DE 					;11	99
	LD		(ALTHL),HL				;16	115

;WE ARE GOING TO USE ALL REGISTERS SO NEED TO SAVE ALT REGS
	EXX								;4	119
	PUSH	BC						;11	130
	PUSH	DE						;11	141
	LD		BC,$0800				;10	151

;	NOP							

;RESET ULA LINE COUNTER
	IN		A,($FE)					;11	162
	OUT		($FF),A					;11	173
;MORE TIMING
	LD	A,0						;7	180
	JP		TOP_DO_SCAN_LINE		;12	190

;DISPLAY THE TOP LINE

TOP_MORE_LINES: 					;13	151 (FROM THE DJNZ BELOW)
	PUSH	IY						;15	166
	POP		IY						;14	180
	JP		TOP_DO_SCAN_LINE		;10	190

TOP_DO_SCAN_LINE:
	CALL	TOP_LINE + $8000		;17	207
TOP_AFTER_LINE:
;WHEN WE LAND HERE WE HAVE USED 32 CHARS (4T EACH) + RET = 128 + 10
									;138	138
	DJNZ	TOP_MORE_LINES			;13 	if jump

;ELSE 8 THIS WAY					;8	146
;NOW PREP FOR MOVING WINDOW
;WE ARE GOING TO HAVE 1 BLANK SCAN LINE BETWEEN TOP LINE AND MOVING WINDOW

	PUSH	HL						;11	157	

; STILL ON ALT REGS WHEN WE ARRIVE HERE

	LD		(SP_STORE),SP 			;20	177
	
; i have a 3 value mini stack set up already, since as nothing is 'pushed' during video generation the bytes never change

	LD		SP,VID_STACK+2			;10	187
	
;the values are :-
;FINAL_RET (at the top)
;NXT_SCANL (in the middle)
;NXT_ROW         (at the bottom)

;we start with SP pointing to
;the middle value

;now get alt regs for LIVE video

ALTHL =  $+1
	LD		HL,D_BUFFER + 32		;10	197
	LD		DE,BUFFER_WIDTH			;10	207

; WELL WE MISSED THAT BY A MILE HENCE THE BLANK SCAN LINE
	
	LD		BC,NUMBER_OF_ROWS * 256 + $C9 ;10 10

	EXX								;4	14
	; AND THE MAIN REGS
HLST =	$+1
	Ld		HL,D_BUFFER + $8000		;10	24
	LD		DE,BUFFER_WIDTH			;10	34
	LD		BC,7 * 256 + 6			;10	44
	INC		BC					;6	50

	ld		a,$21					;7 57		game font
	ld		i,a						;9 66
	nop								;4 70
	LD		(JUST_TWO_BYTES),IY		;20	90
	LD		(JUST_TWO_BYTES),IY		;20	110
	LD		(JUST_TWO_BYTES),IY		;20	130
	LD		(JUST_TWO_BYTES),IY		;20	150



;RESET LINE COUNTER
	IN		A,($FE)					;11	161
	OUT		($FF),A 				;11	172

	LD	A,R						;9	181
	EXX								;4	185
	LD		A,(HL)					;7	192
	LD		(HL),C					;7	199
	EXX								;4	203
	JP		(HL);lets do it baby	;4	207

;NOW IT GETS A BIT HAIRY... HANG ON TO YOUR SEAT IF YOU TRY TO FOLLOW THE EXECUTION PATH !      
;after the first scanline is genrated
;a RET instruction occurs and we start the
;video loop for real.


NXT_ROW:
;we end up here after the 8th scanline of each row
;restore the byte that was replaced with a RET
	EXX					;4		(4)
	LD		(HL),A		;7		(11)
;and move to next row, save the new byte and replace with a RET
	ADD		HL,DE		;11		(22)
	LD		A,(HL)		;7		(29)
	LD		(HL),C		;7		(36)
	EXX					;4		(40)
;reload the scanline counter and make video ptr to next row
	LD		B,C			;4		(44)
	ADD		HL,DE		;11		(55)
JUMP_HL1:
	JP		JUMP_HL 	;10		(65)
JUMP_HL:
	JP		(HL)		;4		(69)

;=============================================================

NXT_SCANL:

;we get here on every scan line except the 1ST of each row

	;test if it's the last scanline in row
	DJNZ	NOT_LAST_LINE	;13 OR 8

					;8	(8)
	;THIS ROUTE IS TOOK WHEN WE ARE ON THE LAST
	;SCANLINE OF A ROW, WE NOW CHECK TO SEE IF IT
	;IS THE LAST ROW, OTHERWISE SP IS DECREMENTED
	;4 TIMES (2 NEW VALUES ON STACK)

	EXX							;4	(12)
;THIS B' IS COUNTING ROWS
	DEC		B					;4	(16)
	JR		Z,NO_MORE_ROWS		;12 or 7

MORE_ROWS:
	;when there are more rows to display
	;we decrement the SP 4 times
	;so the next RET will 'return to NXT_ROW
					;7	(23)
	EXX				;4	(27)
	DEC	SP			;6	(33)
	DEC	SP			;6	(39)
	DEC	SP			;6	(45)
	DEC	SP			;6	(51)

	NOP				;4	(55) FOR TIMING
;AND EXCUTE THE LIVE VIDEO
	JP	JUMP_HL 	;10	(65)


NO_MORE_ROWS:
	;NO MORE ROWS AND THIS IS THE LAST SCANLINE
	;SO DON'T RESTORE THE SP...LEFT POINTING AT FINAL_RET

					;16+12	(28)
	EXX				;4		(32)

	;WASTE SOME CYCLES
	LD	($0000),A		;13		(45)

	JP	JUMP_HL1		;10		(55)



NOT_LAST_LINE:
	;NOT THE LAST SCAN LINE ON THIS ROW
	;SO WE ONLY RESTORE 1 VALUE ON STACK
	;and the next ret will 'return' to NXT_SCANL

	;			TOTAL SO FAR		(13)

	DEC	SP			;6		(19)
	DEC	SP			;6		(25)

	;AND WASTE A FEW CYCLES
	JP	WASTE1		;10		(35)
WASTE1:
	JP	WASTE2		;10		(45)
WASTE2:

	JP	JUMP_HL1		;10		(55)



;====================
; and finnally ends up here....
FINAL_RET:						;138 HERE WE HAVE 32*4 + 10 CYCLES USED
	EXX							;4	142
	LD	(HL),A		;RESTORE THE LAST ret	7 149
	EXX						; AN EXTRA 15 CYCLES	
	
 								;4		153
;RESTORE ORIGINAL SP

SP_STORE = $+1
	LD	SP,$0000					;10		163

	;LETS WASTE 207 CYCLES
	LD	BC,12 * 256 + 0 			;10		173
WASTE207:
	DJNZ	WASTE207
				     ;(12*12 + 8) = 152 	(173+152) - 207 =  118

	ld		a,$24				;7	125 ; text font
	ld		i,a					;9	134
	ld		bC,$0800				;10  144

;SAME KIND OF LOOP FOR BOTTOM LINE AS TOP LINE

	INC	BC						;6	150
;RESET LINE COUNTER...
	IN	A,($FE)					;11		161
	OUT	($FF),A					;11		172
;MORE TIMING
	NOP
	NOP

	JP	BOTTOM_DO_SCAN_LINE			;10    190

BOTTOM_MORE_LINES:					;13	   151
	PUSH IY 						;15	   166
	POP  IY 						;14	   180
	JP   BOTTOM_DO_SCAN_LINE			;10	   190

BOTTOM_DO_SCAN_LINE:
	CALL	BOTTOM_LINE + $8000			;17	   207
BOTTOM_AFTER_LINE:
;EXECUTE 32 CHARS + RET = 128 + 10      ;138    138
	DJNZ BOTTOM_MORE_LINES		   ;13 if jump


	EXX				;SWITCH TO ALT REGISTERS

	; RESTORE ALT REGS FROM STACK
	POP	HL
	POP	DE
	POP	BC
	EXX				;SWITCH BACK TO MAIN REGS
					;THEY ARE RESTORES AFTER
	INC	SP
	INC	SP			;LOOSE LAST VALUE ON STACK


VID_COMPLETE:
; FUDGE TO WORK OUT HOW MANY BOTTOM MARGIN LINES WE NEED
	LD	A,35 + (24 - NUMBER_OF_ROWS) * 8
	NEG
;MAKE SURE NEXT nmi DOES THE vSYNC
	LD	IX,$028F
	;JP	$02A1

;@CHARLIE
;IF YOU WANT TO CALL A ROUTINE EVERY 1/50 SECOND
;THEN REPLACE THE JP $02A1 ABOVE WITH THE FOLLOWING
;AS LONG AS WHATEVER YOU DO WILL BE COMPLETE WITHIN
;THE LOWER MARGIN BEFORE vSYNC OCCURS

	EX		AF,AF'
	OUT		($FE),A

	PUSH	IY				;STC (and AYFX) PLAYER USES IY
GO_PLAYER = $+1
	LD		A,0
	AND		A
SOUNDFN = $+1
	CALL	nz,0
	POP		IY

	POP		HL
	POP		DE
	POP		BC
	POP		AF
	;AT THIS PIONT ALL REGISTERS RESTORED AS THEY WERE BEFORE 
	;VIDEO GENERATION TOOK PLACE
	RET


VID_STACK:
	.word	NXT_ROW
	.word	NXT_SCANL
	.word	FINAL_RET

JUST_TWO_BYTES:
	.byte 0,0

TOP_LINE:
	.fill 32,0
	RET

D_BUFFER:
	.incbin "map.bin"
	RET

	.align	32	; to assist in air display calculations
BOTTOM_LINE:
	.fill 32,0
	RET
