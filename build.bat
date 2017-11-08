
@set EO_SD=C:\Users\Developer\Desktop\retro\EightyOneV1.8\ZXpand_SD_Card
@lz48 -i charset.bin -o charset.binlz
@lz48 -i map.bin -o map.binlz

brass zedragon.asm zedragon.p -s -l listing.html

@copy zedragon.p %EO_SD%\menu.p
@copy zedragon.p.sym %EO_SD%\menu.p.sym
