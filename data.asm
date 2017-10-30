    .asciimap ' ', '_', {*}-' '

CH_CHAIN = $32
CH_EXPLODEBASE = $39

scoreline:
	.asc    "SCORE: 000000  HI: 000000  ^_: 4"
        	;--------========--------========

airline:
	.asc    "AIR: -------------------------- "
    		;--------========--------========

titlecredidx:
    .byte   0
titlecreds:
    ;        --------========--------========
    .asc    "     PROGRAMMING: SIRMORRIS     "
    .asc    "CUSTOM DISPLAY ROUTINE: ANDY REA"
    .asc    " TITLE TUNE: REAR ADMIRAL MOGGY "
    .asc    "   STC MUSIC PLAYER: ANDY REA   "
    .asc    "   AYFX DRIVER:  ALEX SEMENOV   "
    .asc    "ORIGINAL CODE/GFX:  RUSS WETMORE"
    .asc    "      P R E S S    F I R E      "


;;	.asciimap 'A','Z', {*}-'A'+$26
;;	.asciimap '0','9', {*}-'0'+$1c
;;	.asciimap '.', $1b
;;	.asciimap ';', $19


titletune:
	.incbin	"title.stc"

sfx:
	.incbin	"zedragon.afb"

LAST_J:
	.byte	0

; btb = bit test byte = 2nd byte of bit N,a instruction
btb0 = %01000111
btb1 = %01001111
btb2 = %01010111
btb3 = %01011111
btb4 = %01100111
btb5 = %01101111
btb6 = %01110111
btb7 = %01111111

; -----  4  3  2  1  0
;                       
; $FE -  V, C, X, Z, SH   0
; $FD -  G, F, D, S, A    1
; $FB -  T, R, E, W, Q    2
; $F7 -  5, 4, 3, 2, 1    3
; $EF -  6, 7, 8, 9, 0    4
; $DF -  Y, U, I, O, P    5
; $BF -  H, J, K, L, NL   6
; $7F -  B, N, M, ., SP   7
;
; joystick bit test opcode fragment,
; key row offset 0-7,
; key mask,
; input impulse

inputstates:
    .byte	btb7,2,%00000001,0        ; up      (Q)
    .byte	btb6,1,%00000001,0        ; down    (A)
    .byte	btb5,7,%00001000,0        ; left    (N)
    .byte	btb4,7,%00000100,0        ; right   (M)
    .byte	btb3,7,%00000001,0        ; fire    (SP)
    .byte	btb0,3,%00000001,0        ; advance (1)
    .byte	btb0,0,$00000101,0        ; quit    (SH-X)

; calculate actual input impulse addresses
up    = inputstates + 3
down  = inputstates + 7
left  = inputstates + 11
right = inputstates + 15
fire  = inputstates + 19
advance = inputstates + 23
quit  = inputstates + 27

scrolltick:
	.byte	0
scrollpos:
    .word   0
scrolled:
    .byte   0

gameframe:
    .word   0

subx:
    .byte   0
suby:
    .byte   0
subaddress:
    .word   0
oldsubaddress:
    .word   0
bgchardata:
	.byte	0,0,0,0,0,0
basecharptr:
    .word   0

lives:
    .byte   0

minebase:
    .word   0

mul600:
    .word   0,600,1200,1800,2400,3000,3600,4200,4800,5400

collision:
    .byte   0
subrowoff:
    .byte   0
subcoloff:
    .byte   0
bulletX:
    .word   0
bulletHitX:
    .word   0

ocount:
    .byte   0

restartPoint:
    .word   0

    ; Restart scroll and sub positions
dofs:
    .word   $0000
	.byte	0,6

    .word   $004a
	.byte	72,6

    .word   $00aa
	.byte	64,16

    .word   $010b
	.byte	72,16

    .word   $0181
	.byte	56,6

    .word   $021a
	.byte	80,6

    .word   $ffff

airupdatecounter:
    .byte   0
airlevel:
    .byte   0

titlescreen:
	.byte		$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$bf,$1e,$1f,$bf,$0a,$11,$01,$01,$01,$01
	.byte		$00,$00,$00,$07,$01,$01,$07,$01,$09,$0f,$01,$15,$00,$00,$00,$00,$00,$00,$0f,$01,$01,$01,$01,$01
	.byte		$00,$00,$00,$01,$1a,$00,$01,$18,$01,$01,$18,$01,$00,$00,$00,$00,$00,$00,$1d,$30,$0d,$01,$01,$01
	.byte		$00,$00,$00,$12,$1b,$09,$01,$19,$10,$01,$19,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$01,$01
	.byte		$00,$00,$00,$01,$01,$0b,$0d,$01,$01,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$12,$1b
	.byte		$00,$00,$00,$01,$01,$09,$01,$01,$09,$0f,$01,$15,$07,$01,$01,$07,$01,$09,$01,$1c,$01,$00,$00,$00
	.byte		$00,$00,$00,$01,$08,$01,$01,$18,$01,$01,$18,$01,$01,$06,$00,$01,$06,$01,$01,$15,$01,$00,$00,$00
	.byte		$00,$00,$00,$01,$0a,$01,$01,$01,$19,$01,$19,$01,$01,$0c,$01,$01,$0a,$01,$01,$1d,$01,$00,$00,$03
	.byte		$11,$13,$1a,$01,$01,$0b,$01,$05,$09,$01,$00,$01,$0d,$01,$0b,$0d,$01,$0b,$01,$14,$01,$18,$11,$01

shooterframe:
	.byte		0
shooteranimation:
	.byte		$5a,$4e,$46,$42,$62,$72

waterframe:
	.byte		0
wateranimation:
	.byte		%11101110,%11001100,%01101111,%11001111,%11101110,%11010011,%11101011,%11001100

flagframe:
	.byte		0
flaganimation:
	.byte		$1e,$de, $1e,$dc, $1c,$dc, $1c,$de


CH_MINE = $2f
CH_STATICMINE = $2f+$40
CH_STALACTITE = $27
minecount = 216
minetbl:
    .word    8
    .byte    6,CH_STATICMINE
    .word    10
    .byte    3,CH_STATICMINE
    .word    11
    .byte    8,CH_MINE
    .word    13
    .byte    8,CH_MINE
    .word    14
    .byte    8,CH_MINE
    .word    17
    .byte    2,CH_STATICMINE
    .word    19
    .byte    4,CH_STATICMINE
    .word    22
    .byte    6,CH_MINE
    .word    24
    .byte    6,CH_MINE
    .word    25
    .byte    6,CH_MINE
    .word    27
    .byte    4,CH_STATICMINE
    .word    29
    .byte    2,CH_STATICMINE
    .word    31
    .byte    8,CH_MINE
    .word    33
    .byte    8,CH_MINE
    .word    35
    .byte    6,CH_MINE
    .word    38
    .byte    5,CH_MINE
    .word    42
    .byte    1,CH_STATICMINE
    .word    45
    .byte    1,CH_STATICMINE
    .word    47
    .byte    2,CH_STATICMINE
    .word    49
    .byte    8,CH_MINE
    .word    51
    .byte    8,CH_MINE
    .word    52
    .byte    8,CH_MINE
    .word    56
    .byte    7,CH_MINE
    .word    57
    .byte    5,CH_STATICMINE
    .word    59
    .byte    7,CH_MINE
    .word    62
    .byte    7,CH_MINE
    .word    63
    .byte    7,CH_MINE
    .word    64
    .byte    7,CH_MINE
    .word    66
    .byte    3,CH_STATICMINE
    .word    67
    .byte    7,CH_MINE
    .word    72
    .byte    5,CH_MINE
    .word    73
    .byte    3,CH_STATICMINE
    .word    75
    .byte    5,CH_MINE
    .word    78
    .byte    4,CH_MINE
    .word    81
    .byte    1,CH_STATICMINE
    .word    87
    .byte    2,CH_STATICMINE
    .word    90
    .byte    6,CH_MINE
    .word    92
    .byte    6,CH_MINE
    .word    93
    .byte    4,CH_STATICMINE
    .word    95
    .byte    7,CH_MINE
    .word    97
    .byte    3,CH_STATICMINE
    .word    98
    .byte    8,CH_MINE
    .word   100
    .byte    8,CH_MINE
    .word   103
    .byte    8,CH_MINE
    .word   106
    .byte    9,CH_MINE
    .word   107
    .byte    2,CH_STATICMINE
    .word   109
    .byte    9,CH_MINE
    .word   110
    .byte    9,CH_MINE
    .word   113
    .byte    8,CH_MINE
    .word   114
    .byte    4,CH_STATICMINE
    .word   118
    .byte    7,CH_MINE
    .word   126
    .byte    9,CH_MINE
    .word   140
    .byte    8,CH_MINE
    .word   156
    .byte    8,CH_STATICMINE
    .word   157
    .byte    7,CH_STATICMINE
    .word   162
    .byte    7,CH_MINE
    .word   167
    .byte    7,CH_MINE
    .word   170
    .byte    8,CH_MINE
    .word   174
    .byte    6,CH_MINE
    .word   177
    .byte    8,CH_MINE
    .word   183
    .byte    6,CH_MINE
    .word   185
    .byte    2,CH_STATICMINE
    .word   187
    .byte    7,CH_MINE
    .word   188
    .byte    7,CH_MINE
    .word   190
    .byte    4,CH_STATICMINE
    .word   192
    .byte    8,CH_MINE
    .word   194
    .byte    8,CH_MINE
    .word   195
    .byte    8,CH_MINE
    .word   199
    .byte    6,CH_MINE
    .word   206
    .byte    5,CH_MINE
    .word   209
    .byte    3,CH_MINE
    .word   212
    .byte    1,CH_STATICMINE
    .word   214
    .byte    1,CH_STATICMINE
    .word   215
    .byte    2,CH_STATICMINE
    .word   218
    .byte    7,CH_MINE
    .word   221
    .byte    6,CH_MINE
    .word   225
    .byte    3,CH_STATICMINE
    .word   226
    .byte    8,CH_MINE
    .word   228
    .byte    6,CH_MINE
    .word   230
    .byte    4,CH_MINE
    .word   232
    .byte    2,CH_STATICMINE
    .word   233
    .byte    6,CH_MINE
    .word   234
    .byte    4,CH_STATICMINE
    .word   237
    .byte    3,CH_MINE
    .word   238
    .byte    3,CH_MINE
    .word   241
    .byte    1,CH_STATICMINE
    .word   244
    .byte    1,CH_STATICMINE
    .word   246
    .byte    2,CH_STATICMINE
    .word   248
    .byte    8,CH_MINE
    .word   252
    .byte    6,CH_MINE
    .word   253
    .byte    6,CH_MINE
    .word   254
    .byte    3,CH_STATICMINE
    .word   255
    .byte    6,CH_MINE
    .word   256
    .byte    4,CH_STATICMINE
    .word   259
    .byte    8,CH_MINE
    .word   261
    .byte    8,CH_MINE
    .word   262
    .byte    2,CH_STATICMINE
    .word   266
    .byte    5,CH_MINE
    .word   273
    .byte    1,CH_STATICMINE
    .word   283
    .byte    2,CH_STATICMINE
    .word   284
    .byte    2,CH_STATICMINE
    .word   288
    .byte    8,CH_MINE
    .word   289
    .byte    8,CH_STATICMINE
    .word   290
    .byte    8,CH_STATICMINE
    .word   291
    .byte    8,CH_STATICMINE
    .word   292
    .byte    8,CH_STATICMINE
    .word   298
    .byte    6,CH_STATICMINE
    .word   299
    .byte    6,CH_STATICMINE
    .word   300
    .byte    6,CH_STATICMINE
    .word   307
    .byte    6,CH_MINE
    .word   309
    .byte    6,CH_MINE
    .word   317
    .byte    7,CH_STATICMINE
    .word   318
    .byte    7,CH_STATICMINE
    .word   319
    .byte    7,CH_STATICMINE
    .word   326
    .byte    9,CH_STATICMINE
    .word   327
    .byte    9,CH_STATICMINE
    .word   340
    .byte    4,CH_STATICMINE
    .word   341
    .byte    4,CH_STATICMINE
    .word   350
    .byte    7,CH_STATICMINE
    .word   359
    .byte    2,CH_STATICMINE
    .word   362
    .byte    9,CH_MINE
    .word   365
    .byte    9,CH_MINE
    .word   366
    .byte    9,CH_MINE
    .word   367
    .byte    9,CH_MINE
    .word   368
    .byte    9,CH_MINE
    .word   371
    .byte    9,CH_MINE
    .word   374
    .byte    9,CH_MINE
    .word   375
    .byte    9,CH_MINE
    .word   376
    .byte    9,CH_MINE
    .word   377
    .byte    9,CH_MINE
    .word   380
    .byte    9,CH_MINE
    .word   384
    .byte    5,CH_STATICMINE
    .word   385
    .byte    5,CH_STATICMINE
    .word   387
    .byte    4,CH_STATICMINE
    .word   388
    .byte    4,CH_STATICMINE
    .word   390
    .byte    3,CH_STATICMINE
    .word   391
    .byte    3,CH_STATICMINE
    .word   396
    .byte    2,CH_MINE
    .word   397
    .byte    1,CH_STATICMINE
    .word   398
    .byte    2,CH_STATICMINE
    .word   401
    .byte    7,CH_MINE
    .word   404
    .byte    6,CH_MINE
    .word   405
    .byte    6,CH_MINE
    .word   406
    .byte    2,CH_STATICMINE
    .word   411
    .byte    2,CH_MINE
    .word   413
    .byte    1,CH_STATICMINE
    .word   417
    .byte    6,CH_MINE
    .word   418
    .byte    6,CH_MINE
    .word   422
    .byte    5,CH_STATICMINE
    .word   423
    .byte    8,CH_MINE
    .word   425
    .byte    6,CH_MINE
    .word   426
    .byte    2,CH_STATICMINE
    .word   428
    .byte    1,CH_STATICMINE
    .word   429
    .byte    1,CH_STATICMINE
    .word   432
    .byte    3,CH_MINE
    .word   433
    .byte    2,CH_STATICMINE
    .word   435
    .byte    8,CH_MINE
    .word   436
    .byte    4,CH_STATICMINE
    .word   437
    .byte    8,CH_MINE
    .word   438
    .byte    8,CH_MINE
    .word   439
    .byte    5,CH_STATICMINE
    .word   444
    .byte    8,CH_MINE
    .word   448
    .byte    7,CH_MINE
    .word   456
    .byte    5,CH_STATICMINE
    .word   459
    .byte    8,CH_MINE
    .word   460
    .byte    8,CH_MINE
    .word   469
    .byte    8,CH_MINE
    .word   471
    .byte    7,CH_MINE
    .word   473
    .byte    6,CH_MINE
    .word   475
    .byte    5,CH_MINE
    .word   477
    .byte    4,CH_MINE
    .word   479
    .byte    3,CH_MINE
    .word   481
    .byte    2,CH_MINE
    .word   492
    .byte    9,CH_MINE
    .word   493
    .byte    3,CH_STALACTITE
    .word   495
    .byte    4,CH_STALACTITE
    .word   496
    .byte    9,CH_MINE
    .word   497
    .byte    3,CH_STALACTITE
    .word   501
    .byte    4,CH_STALACTITE
    .word   502
    .byte    4,CH_STALACTITE
    .word   504
    .byte    8,CH_MINE
    .word   507
    .byte    1,CH_STALACTITE
    .word   508
    .byte    1,CH_STALACTITE
    .word   509
    .byte    9,CH_MINE
    .word   510
    .byte    5,CH_STATICMINE
    .word   512
    .byte    2,CH_STALACTITE
    .word   513
    .byte    9,CH_MINE
    .word   515
    .byte    4,CH_STALACTITE
    .word   516
    .byte    6,CH_STATICMINE
    .word   518
    .byte    5,CH_STATICMINE
    .word   520
    .byte    1,CH_STALACTITE
    .word   521
    .byte    1,CH_STALACTITE
    .word   522
    .byte    7,CH_MINE
    .word   523
    .byte    1,CH_STALACTITE
    .word   525
    .byte    7,CH_MINE
    .word   526
    .byte    5,CH_STATICMINE
    .word   528
    .byte    3,CH_STALACTITE
    .word   529
    .byte    7,CH_MINE
    .word   532
    .byte    4,CH_STALACTITE
    .word   533
    .byte    7,CH_MINE
    .word   534
    .byte    4,CH_STALACTITE
    .word   545
    .byte    8,CH_MINE
    .word   549
    .byte    5,CH_MINE
    .word   552
    .byte    3,CH_MINE
    .word   553
    .byte    1,CH_STATICMINE
    .word   554
    .byte    3,CH_MINE
    .word   555
    .byte    3,CH_MINE
    .word   559
    .byte    3,CH_STATICMINE
    .word   562
    .byte    7,CH_MINE
    .word   566
    .byte    7,CH_MINE
    .word   567
    .byte    6,CH_STATICMINE
    .word   569
    .byte    7,CH_MINE
    .word   570
    .byte    7,CH_MINE
    .word   573
    .byte    5,CH_STATICMINE
    .word   576
    .byte    6,CH_MINE
    .word   597
    .byte    5,CH_STATICMINE
    .word   $dead

    .align 16
charsets:
    .incbin "charset.bin"

