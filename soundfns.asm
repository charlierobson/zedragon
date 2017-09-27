enabletitlesound:
    call    INIT_STC
    ld      hl,PLAY_STC
    ld      (SOUNDFN),hl
    ld      hl,GO_PLAYER
    inc     (hl)
    ret

enablegamesound:
    ld      hl,sfx
    call    INIT_AFX
    ld      hl,AFXFRAME
    ld      (SOUNDFN),hl
    ld      hl,GO_PLAYER
    inc     (hl)
    ret

silencesound:
    ld      hl,GO_PLAYER
    dec     (hl)
    jp      MUTE_AY
