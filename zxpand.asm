golow:
    ld      bc,$e007
    ld      a,$b2
    out     (c),a
    ret

;;loader:
;;    ld      DE,songnameend-1
;;    ld      a,(de)
;;    or      128
;;    ld      (de),a
;;    ld      de,songname
;;    xor     a
;;    jp      $1ff8
;;
;;songname:
;;	.asc	"TITLE.STC;32768"
;;songnameend: