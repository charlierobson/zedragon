puremap = $2600


	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	;
	; copy the map from its load position in screen ram down to its
	; resting place in the 8k block after the character sets. this
    ; map at 8k is known as the 'pure' map. it is used to reset
    ; the collison map which shadows the display in upper memory. 
	;
initmap:
    ld      hl,D_BUFFER
    ld      de,puremap
    ld      bc,6000
    ldir

    ; reset mines and stalactites in the pure map

    ld      b,minecount
    ld      hl,minetbl

mineloop:
    push    bc

    ld      e,(hl)      ; x char => de
    inc     hl
    ld      d,(hl)
    inc     hl
    ld      a,(hl)      ; y => a
    inc     hl
    push    hl

    ex      de,hl       ; hl = x char
    call    mulby600    ; de = a * 600
    add     hl,de
    ld      de,puremap
    add     hl,de
    ex      de,hl

    pop     hl
    ld      a,(hl)      ; get enemy type
    and     $3f         ; mask off modifier bits
    bit     6,(hl)      ; but remember state of modifier
    inc     hl
    ld      (de),a
    call    nz,drawchain

    pop     bc
    djnz    mineloop

    ; set up the water

    ld      hl,puremap
    ld      bc,600

-:  ld      a,(hl)
    and     a
    jr      nz,rmp0

    ld      a,$bf
    ld      (hl),a

rmp0:
    inc     hl
    dec     bc
    ld      a,b
    or      c
    jr      nz,{-}

    ret




-:  xor     a
    ld      (de),a

undrawchain:
    ld      a,$58           ; de += 600
    add     a,e
    ld      e,a
    ld      a,$02
    adc     a,d
    ld      d,a

    ld      a,(de)          ; if (de) == 0, make (de) = chain character, else done
    cp      CH_CHAIN
    jr      z,{-}

    ret



-:  ld      a,CH_CHAIN      ; draw a chain character into the map
    ld      (de),a

drawchain:
    ld      a,$58           ; de += 600
    add     a,e
    ld      e,a
    ld      a,$02
    adc     a,d
    ld      d,a

    ld      a,(de)
    and     a
    jr      z,{-}

    ret



	;-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
	;
	; copy the pure map up to the mirror above 16k. copy the mirror
	; into the display file. update the display file to show water.
    ;
refreshmap:
    ld      hl,puremap
    ld      de,D_BUFFER+$4000
    ld      bc,6000
    ldir

    ld      hl,puremap
    ld      de,D_BUFFER
    ld      bc,6000
    ldir

    ret


resetmines:
    ld      hl,minetbl
    ld      (minebase),hl

findfirstmine:
    ld      hl,(minebase)
    ld      de,(scrollpos)

-:  push    hl
    ld      a,(hl)
    inc     hl
    ld      h,(hl)
    ld      l,a
    sbc     hl,de
    pop     hl
    ld      (minebase),hl
    ret     nc                  ; hl points to first mine on screen

    inc     hl
    inc     hl
    inc     hl
    inc     hl
    jr      {-}


    ;
    ; return with carry set and hl = pointer to mine if a mine is considered for action
    ;
findmine:
    ld      (consideration),hl
    ld      hl,(scrollpos)
    ld      de,32
    add     hl,de
    ex      de,hl

    ld      hl,(minebase)

-:  push    hl
    ld      a,(hl)
    inc     hl
    ld      h,(hl)
    ld      l,a
    sbc     hl,de
    pop     hl
    ret     nc                  ; no more mines on screen

    ; consider this mine
consideration = $+1
    call    0
    ret     c                   ; this is our mine!

    inc     hl
    inc     hl
    inc     hl
    inc     hl
    jr      {-}


mine = $28
staticmine = $28+$40
stalactite = $27
minecount = 216
minetbl:
    .word    8
    .byte    6,staticmine
    .word    10
    .byte    3,staticmine
    .word    11
    .byte    8,mine
    .word    13
    .byte    8,mine
    .word    14
    .byte    8,mine
    .word    17
    .byte    2,staticmine
    .word    19
    .byte    4,staticmine
    .word    22
    .byte    6,mine
    .word    24
    .byte    6,mine
    .word    25
    .byte    6,mine
    .word    27
    .byte    4,staticmine
    .word    29
    .byte    2,staticmine
    .word    31
    .byte    8,mine
    .word    33
    .byte    8,mine
    .word    35
    .byte    6,mine
    .word    38
    .byte    5,mine
    .word    42
    .byte    1,staticmine
    .word    45
    .byte    1,staticmine
    .word    47
    .byte    2,staticmine
    .word    49
    .byte    8,mine
    .word    51
    .byte    8,mine
    .word    52
    .byte    8,mine
    .word    56
    .byte    7,mine
    .word    57
    .byte    5,staticmine
    .word    59
    .byte    7,mine
    .word    62
    .byte    7,mine
    .word    63
    .byte    7,mine
    .word    64
    .byte    7,mine
    .word    66
    .byte    3,staticmine
    .word    67
    .byte    7,mine
    .word    72
    .byte    5,mine
    .word    73
    .byte    3,staticmine
    .word    75
    .byte    5,mine
    .word    78
    .byte    4,mine
    .word    81
    .byte    1,staticmine
    .word    87
    .byte    2,staticmine
    .word    90
    .byte    6,mine
    .word    92
    .byte    6,mine
    .word    93
    .byte    4,staticmine
    .word    95
    .byte    7,mine
    .word    97
    .byte    3,staticmine
    .word    98
    .byte    8,mine
    .word   100
    .byte    8,mine
    .word   103
    .byte    8,mine
    .word   106
    .byte    9,mine
    .word   107
    .byte    2,staticmine
    .word   109
    .byte    9,mine
    .word   110
    .byte    9,mine
    .word   113
    .byte    8,mine
    .word   114
    .byte    4,staticmine
    .word   118
    .byte    7,mine
    .word   126
    .byte    9,mine
    .word   140
    .byte    8,mine
    .word   156
    .byte    8,staticmine
    .word   157
    .byte    7,staticmine
    .word   162
    .byte    7,mine
    .word   167
    .byte    7,mine
    .word   170
    .byte    8,mine
    .word   174
    .byte    6,mine
    .word   177
    .byte    8,mine
    .word   183
    .byte    6,mine
    .word   185
    .byte    2,staticmine
    .word   187
    .byte    7,mine
    .word   188
    .byte    7,mine
    .word   190
    .byte    4,staticmine
    .word   192
    .byte    8,mine
    .word   194
    .byte    8,mine
    .word   195
    .byte    8,mine
    .word   199
    .byte    6,mine
    .word   206
    .byte    5,mine
    .word   209
    .byte    3,mine
    .word   212
    .byte    1,staticmine
    .word   214
    .byte    1,staticmine
    .word   215
    .byte    2,staticmine
    .word   218
    .byte    7,mine
    .word   221
    .byte    6,mine
    .word   225
    .byte    3,staticmine
    .word   226
    .byte    8,mine
    .word   228
    .byte    6,mine
    .word   230
    .byte    4,mine
    .word   232
    .byte    2,staticmine
    .word   233
    .byte    6,mine
    .word   234
    .byte    4,staticmine
    .word   237
    .byte    3,mine
    .word   238
    .byte    3,mine
    .word   241
    .byte    1,staticmine
    .word   244
    .byte    1,staticmine
    .word   246
    .byte    2,staticmine
    .word   248
    .byte    8,mine
    .word   252
    .byte    6,mine
    .word   253
    .byte    6,mine
    .word   254
    .byte    3,staticmine
    .word   255
    .byte    6,mine
    .word   256
    .byte    4,staticmine
    .word   259
    .byte    8,mine
    .word   261
    .byte    8,mine
    .word   262
    .byte    2,staticmine
    .word   266
    .byte    5,mine
    .word   273
    .byte    1,staticmine
    .word   283
    .byte    2,staticmine
    .word   284
    .byte    2,staticmine
    .word   288
    .byte    8,mine
    .word   289
    .byte    8,staticmine
    .word   290
    .byte    8,staticmine
    .word   291
    .byte    8,staticmine
    .word   292
    .byte    8,staticmine
    .word   298
    .byte    6,staticmine
    .word   299
    .byte    6,staticmine
    .word   300
    .byte    6,staticmine
    .word   307
    .byte    6,mine
    .word   309
    .byte    6,mine
    .word   317
    .byte    7,staticmine
    .word   318
    .byte    7,staticmine
    .word   319
    .byte    7,staticmine
    .word   326
    .byte    9,staticmine
    .word   327
    .byte    9,staticmine
    .word   340
    .byte    4,staticmine
    .word   341
    .byte    4,staticmine
    .word   350
    .byte    7,staticmine
    .word   359
    .byte    2,staticmine
    .word   362
    .byte    9,mine
    .word   365
    .byte    9,mine
    .word   366
    .byte    9,mine
    .word   367
    .byte    9,mine
    .word   368
    .byte    9,mine
    .word   371
    .byte    9,mine
    .word   374
    .byte    9,mine
    .word   375
    .byte    9,mine
    .word   376
    .byte    9,mine
    .word   377
    .byte    9,mine
    .word   380
    .byte    9,mine
    .word   384
    .byte    5,staticmine
    .word   385
    .byte    5,staticmine
    .word   387
    .byte    4,staticmine
    .word   388
    .byte    4,staticmine
    .word   390
    .byte    3,staticmine
    .word   391
    .byte    3,staticmine
    .word   396
    .byte    2,mine
    .word   397
    .byte    1,staticmine
    .word   398
    .byte    2,staticmine
    .word   401
    .byte    7,mine
    .word   404
    .byte    6,mine
    .word   405
    .byte    6,mine
    .word   406
    .byte    2,staticmine
    .word   411
    .byte    2,mine
    .word   413
    .byte    1,staticmine
    .word   417
    .byte    6,mine
    .word   418
    .byte    6,mine
    .word   422
    .byte    5,staticmine
    .word   423
    .byte    8,mine
    .word   425
    .byte    6,mine
    .word   426
    .byte    2,staticmine
    .word   428
    .byte    1,staticmine
    .word   429
    .byte    1,staticmine
    .word   432
    .byte    3,mine
    .word   433
    .byte    2,staticmine
    .word   435
    .byte    8,mine
    .word   436
    .byte    4,staticmine
    .word   437
    .byte    8,mine
    .word   438
    .byte    8,mine
    .word   439
    .byte    5,staticmine
    .word   444
    .byte    8,mine
    .word   448
    .byte    7,mine
    .word   456
    .byte    5,staticmine
    .word   459
    .byte    8,mine
    .word   460
    .byte    8,mine
    .word   469
    .byte    8,mine
    .word   471
    .byte    7,mine
    .word   473
    .byte    6,mine
    .word   475
    .byte    5,mine
    .word   477
    .byte    4,mine
    .word   479
    .byte    3,mine
    .word   481
    .byte    2,mine
    .word   492
    .byte    9,mine
    .word   493
    .byte    3,stalactite
    .word   495
    .byte    4,stalactite
    .word   496
    .byte    9,mine
    .word   497
    .byte    3,stalactite
    .word   501
    .byte    4,stalactite
    .word   502
    .byte    4,stalactite
    .word   504
    .byte    8,mine
    .word   507
    .byte    1,stalactite
    .word   508
    .byte    1,stalactite
    .word   509
    .byte    9,mine
    .word   510
    .byte    5,staticmine
    .word   512
    .byte    2,stalactite
    .word   513
    .byte    9,mine
    .word   515
    .byte    4,stalactite
    .word   516
    .byte    6,staticmine
    .word   518
    .byte    5,staticmine
    .word   520
    .byte    1,stalactite
    .word   521
    .byte    1,stalactite
    .word   522
    .byte    7,mine
    .word   523
    .byte    1,stalactite
    .word   525
    .byte    7,mine
    .word   526
    .byte    5,staticmine
    .word   528
    .byte    3,stalactite
    .word   529
    .byte    7,mine
    .word   532
    .byte    4,stalactite
    .word   533
    .byte    7,mine
    .word   534
    .byte    4,stalactite
    .word   545
    .byte    8,mine
    .word   549
    .byte    5,mine
    .word   552
    .byte    3,mine
    .word   553
    .byte    1,staticmine
    .word   554
    .byte    3,mine
    .word   555
    .byte    3,mine
    .word   559
    .byte    3,staticmine
    .word   562
    .byte    7,mine
    .word   566
    .byte    7,mine
    .word   567
    .byte    6,staticmine
    .word   569
    .byte    7,mine
    .word   570
    .byte    7,mine
    .word   573
    .byte    5,staticmine
    .word   576
    .byte    6,mine
    .word   597
    .byte    5,staticmine
    .word   $dead
