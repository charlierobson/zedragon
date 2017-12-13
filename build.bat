@set EO_SD=C:\Users\Developer\Desktop\retro\EightyOneV1.8\ZXpand_SD_Card
@copy /y tools\mapper\data\* .

@lz48 -i titlescrn.bin -o titlescrn.binlz
@lz48 -i charset.bin -o charset.binlz
@lz48 -i map.bin -o map.binlz
@lz48 -i hercules.bin -o hercules.binlz

@python tools/memmap.py > memmap.asm

brass zedragon.asm zedragon.p -s -l listing.html

@copy zedragon.p %EO_SD%\menu.p
@copy zedragon.p.sym %EO_SD%\menu.p.sym
