    .asciimap ' ', '_', {*}-' '

;scoreline = txtres
    .asc    "SCORE:00000  HI:00000  Z:1  ^_:4"
    ;        --------========--------========

;airline = txtres + $20
    .asc    "AIR: -------------------------- "
    ;        --------========--------========

;titlecreds = txtres + $40
    ;        --------========--------========
    .asc    "     PROGRAMMING: SIRMORRIS     "
    .asc    "CUSTOM DISPLAY ROUTINE: ANDY REA"
    .asc    " TITLE TUNE: REAR ADMIRAL MOGGY "
    .asc    "   STC MUSIC PLAYER: ANDY REA   "
    .asc    "   AYFX DRIVER:  ALEX SEMENOV   "
    .asc    "    ATARI GFX:  RUSS WETMORE    "
;zxpdistxt =  txtres + $110
    .asc    "        ZXPAND: DISABLED        "

;pressfire =  txtres + $120
    .asc    "      P R E S S    F I R E      "
    ;        --------========--------========

;pausedtext = txtres + $140
    .asc    "             PAUSED             "
    ;        --------========--------========

    .asciimap 0, 255, {*}-'@'
    .asciimap ' ', ' ', 0
    .asciimap '.', '.', $1e
    .asciimap '!', '!', $3c

;failedtext =  txtres + $160
    .asc    "         MISSION FAILED}        "
    ;        --------========--------========

;congrattext = txtres + $180
    ;        --------========--------========
    .asc    "    Congratulations Captain!~"
    .asc    "~"
    .asc    "The biggest threat to our planet~"
    .asc    "is defeated. We are safe again.~"
    .asc    "~"
    .asc    "You will receive the highest~"
    .asc    "honour our country can give...~"
    .asc    "~"
    .asc    "      ...ANOTHER MISSION!!~}"
    ;        --------========--------========
