# zedragon
Conversion of Russ Wetmore's classic Atari game Sea Dragon for the Sinclair ZX81 suitably equipped with 32K RAM, AY/YM sound and UDG.§

## How to play

Avoid contact with enemies or the environment. Don't run out of air. Surface regularly to refill your tanks.

ZXpand joystick or the following keys move your sub:

|Key|Direction|
|----|----|
| Q | Up |
| A | Down |
| N | Left |
| M | Right |

Space fires. Hold fire while moving to slow the sub's movement for tight spots.

---
### Additional Hardware Requirements

RAM at 8-40K : Chroma / ZXPand / ZXpand+
UDG : UDG-For-ZXpand / CHR$128 mod (128 character mode)

Joystick : Kempston / Chroma / ZXpand+ / ZXpand-AY
Sound : ZonX / Mr.X / ZXpand+ / ZXpand-AY

---
### TODO
* ~~lasers~~
* ~~stalactites~~
* ~~shooters~~
* ~~depth charges~~
* ~~pixel movement torpedos~~
* ~~score~~
* ~~final boss~~
* ~~"laser" sounds~~
* ~~sub moves off after boss death~~
* ~~zxpand detection~~
* ~~tackle slowdown~~
  * ~~stop enemies after ship has passed~~
  * ~~cap number of enemies by disallowing mines when more than X objects active~~
* ~~congrats / teletyper?~~
* ~~move on to restart~~
* ~~game over screen~~
* ~~only allow skipping zones to ones visited~~
* ~~pause~~
* ~~hiscore / max zone saving~~
* ~~ship control, for tight spot maneuvering~~
* ~~extra lives~~

### IN PROGRESS

### ONGOING
* map cleanup
* improve sound effects

### BUGS
* ~~ship parts left behind when reversing~~
* ~~explosion parts left behind sometimes~~
* ~~crash when ship goes into line 9~~
* ~~chain sometimes doesn't fall~~
* ~~laser graphically interferes with bullet~~
* ~~sub collisions broken~~
* ~~enemies can fall below line 10~~
* ~~torpedo passes through mine sometimes~~
* ~~sub exploding on line 9 crashes the game~~
* controls get stuck sometimes
  * not sure if this is a ZXpand issue, nature of input fns is that they *will* clear if left alone...

### NICE TO HAVE
* control customisation
* other udg boards
* chroma
* sound on/off
* game over music