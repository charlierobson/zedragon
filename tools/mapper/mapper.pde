import de.bezier.guido.*;


String mapName = "map.bin";
//String mapName = "titlescrn.bin";

int mode;
byte[] map;
byte[] enemyidx = new byte[600];
byte[] enemydat = new byte[256];

ArrayList<PImage> characterSet;
ArrayList<PImage> characterSetE;

int lastMouseX;
int scrollpos;
int fineScroll;
int xtiles;
int xc, yc, cx, cy;
int selectedTile = 0;


byte charToMap(byte c)
{
  if (c > 63) c += 64;
  return c;
}

byte mapToChar(byte c)
{
  if (c > 127) c -= 64;
  return c;
}

void selectCharacter(int charNum)
{
  if (mode == 1) {
    byte mchar = charToMap((byte)charNum);
    byte msel = charToMap((byte)selectedTile);

    for(int i = 0 ; i < 6000; ++ i) {
      if(map[i] == mchar) {
        map[i] = charToMap(msel);
      } else if(map[i] == msel) {
        map[i] = mchar;
      }
    }

    PImage temp = characterSet.get(charNum);
    characterSet.set(charNum, characterSet.get(selectedTile));
    characterSet.set(selectedTile, temp);
  } else if (mode == 3) {
    characterSet.set(charNum, characterSet.get(selectedTile));
  }
  selectedTile = charNum;
  mode = 0;
}

void setMode(int m)
{
  // toggle/cancel
  if (m == mode) {
    mode = 0;
    return;
  }

  mode = m;
}

void setup()
{
  size(1024, 500);
  background(128);

  scrollpos = 0;
  xtiles = width / 16;
  lastMouseX = mouseX;

  byte[] chardata = loadBytes("charset.bin");
  characterSet = new ArrayList<PImage>();
  characterSetE = new ArrayList<PImage>();

  for (int i = 0; i < 0xc0; ++i) {
    PImage p = new PImage(8, 8);
    putchar(p, chardata, i, 0, 0, color(0,0,0));
    characterSet.add(p);
    p = new PImage(8, 8);
    putchar(p, chardata, i, 0, 0, color(240,0,0));
    characterSetE.add(p);
  }

  map = loadBytes(mapName);
  updateEnemies();

  //

  Interactive.make( this );

  for (int y = 0; y < 8; ++y) {
    for (int x = 0; x < 16; ++x ) {
      new CharButton(x + (16 * y), 8 + x * 32, 168 + y * 32);
    }
  }

  new MMButton("<<", -xtiles, 600, 300, 100, 25);
  new MMButton(">>", xtiles, 720, 300, 100, 25);
  new ModeButton("CharSwap", 1, 600, 350, 100, 25);
  new ModeButton("CharCopy", 3, 600, 400, 100, 25);

  noFill();
}

void draw()
{
  background(128);

  for (int x = 0; x < xtiles; ++x) {
    for (int y = 0; y < 10; ++y) {
      image(characterSet.get(getMap(x, y)), x * 16, y * 16, 16, 16);
    }
  }

  xc = mouseX / 16;
  yc = mouseY / 16;

  textAlign(LEFT, CENTER);

  if (yc < 10) {
    noFill();
    stroke(((millis() & 512) == 512) ? color(255, 0, 0) : color(0, 255, 0));
    rect(xc * 16, yc * 16, 15, 15);

    text("Cursor over : $" + hex(getMap(xc, yc), 2), 600, 200, 200, 17);
    image(characterSet.get(getMap(xc, yc)), 720, 200, 16, 16);
  }

  text("Selected: $" + hex(charToMap((byte)selectedTile), 2), 600, 178, 200, 17);
  image(characterSet.get(selectedTile), 720, 178, 16, 16);

  text("Mode: " + mode, 720, 350);

  if (yc < 10) {
    text("x = " + (xc + scrollpos) + ", y = " + yc + "  ($"+hex(xc + scrollpos,2)+", $"+hex(yc,2)+")", 600, 232);
  }

  for(int i = scrollpos; i < scrollpos + xtiles; ++i) {
    int ei = enemyidx[i] & 0xff;
    if (ei != 0xff) {
      int ed = enemydat[ei] & 0xff;
      byte y = (byte)(ed & 0x0f);
      byte t = (byte)((ed>>4) & 0x0f);


      if(t == 0) image(characterSetE.get(0x4f), (i - scrollpos) * 16, y * 16, 16, 16);
      if(t == 1 || t == 2) image(characterSetE.get(0x47), (i - scrollpos) * 16, y * 16, 16, 16);
      if(t == 3) image(characterSetE.get(0x33), (i - scrollpos) * 16, y * 16, 16, 16);
      if(t == 4) image(characterSetE.get(0x30), (i - scrollpos) * 16, y * 16, 16, 16);
      if(t == 5) image(characterSetE.get(0x31), (i - scrollpos) * 16, y * 16, 16, 16);
      if(t == 6) image(characterSetE.get(0x3f), (i - scrollpos) * 16, y * 16, 16, 16);
      if(t == 7) image(characterSetE.get(0x3d), (i - scrollpos) * 16, y * 16, 16, 16);
      
    }
  }
}

int enemyType(int c)
{
  c &= 0xff;
  if (c == 0x8f) return 0; // stal
  if (c == 0x87) return 1; // mine
  if (c == 0x33) return 3; // depth
  if (c == 0x30) return 4; // shooter
  if (c == 0x31) return 5; // laser
  if (c == 0x3f) return 6; // boss switch
  if (c == 0x3d) return 7; // boss

  return -1;
}

void setMap(int x, int y, int c)
{
  if (c > 63) c += 64;
  map[scrollpos + x + (600 * y)] = (byte)c;

  updateEnemies();

  saveBytes("data/"+mapName, map);
  saveBytes("data/enemyidx.bin", enemyidx);
  saveBytes("data/enemydat.bin", enemydat);
  saveBytes("data/charset.bin", getCharsetBytes());
}

int getMap(int x, int y)
{
  x = constrain(x, 0, xtiles);
  y = constrain(y, 0, 10);
  
  int c = map[scrollpos + x + (600 * y)] & 0xff;
  if (c > 127) c -= 64;
  return (int)c;
}

void mouseClicked() {
  if (yc > 9) return;

  if (mouseButton == LEFT) {
    setMap(xc, yc, selectedTile);
  } else {
    selectedTile = getMap(xc, yc);
  }
}

void mousePressed() {
  lastMouseX = mouseX;
}

void mouseDragged() 
{
  int delta = lastMouseX - mouseX;
  lastMouseX = mouseX;

  fineScroll += delta;
  scrollpos = fineScroll / 16;

  if (scrollpos < 0) scrollpos = 0;
  if (scrollpos > 600 - xtiles) scrollpos = 600 - xtiles;
}