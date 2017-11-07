void putchar(PImage target, byte[] charset, int c, int x, int y)
{
  target.loadPixels();

  color fg = color(0);
  color bg = color(255);

  y *= target.width;

  for (int c2 = 0; c2 < 8; c2++)
  {
    byte charb = charset[c * 8 + c2];
    if (c > 63) charb ^= 255;

    if ((charb & 0x80) != 0) target.pixels[x + 0 + y] = fg; 
    else target.pixels[x + 0 + y] = bg;
    if ((charb & 0x40) != 0) target.pixels[x + 1 + y] = fg; 
    else target.pixels[x + 1 + y] = bg;
    if ((charb & 0x20) != 0) target.pixels[x + 2 + y] = fg; 
    else target.pixels[x + 2 + y] = bg;
    if ((charb & 0x10) != 0) target.pixels[x + 3 + y] = fg; 
    else target.pixels[x + 3 + y] = bg;
    if ((charb & 0x8) != 0)  target.pixels[x + 4 + y] = fg; 
    else target.pixels[x + 4 + y] = bg;
    if ((charb & 0x4) != 0)  target.pixels[x + 5 + y] = fg; 
    else target.pixels[x + 5 + y] = bg;
    if ((charb & 0x2) != 0)  target.pixels[x + 6 + y] = fg; 
    else target.pixels[x + 6 + y] = bg;
    if ((charb & 0x1) != 0)  target.pixels[x + 7 + y] = fg; 
    else target.pixels[x + 7 + y] = bg;

    y += target.width;
  }

  target.updatePixels();
}



byte[] map;
byte[] enemyidx = new byte[600];
byte[] enemydat = new byte[256];

ArrayList<PImage> characterSet;

int lastMouseX;
int scrollpos;
int fineScroll;
int xtiles;
int xc, yc, cx, cy;
int selectedTile = 0;


void setup()
{
  map = loadBytes("map.bin");
  characterSet = new ArrayList<PImage>();

  size(1000, 500);
  background(128);

  scrollpos = 0;
  xtiles = width / 16;
  lastMouseX = mouseX;

  byte[] chardata = loadBytes("charset.bin");

  characterSet = new ArrayList<PImage>();
  for (int i = 0; i < 128; ++i) {
    PImage p = new PImage(8, 8);
    putchar(p, chardata, i, 0, 0);
    characterSet.add(p);
  }

  noFill();
}

void draw()
{
  background(128);
  for (int y = 0; y < 10; ++y) {
    for (int x = 0; x < xtiles; ++x ) {
      image(characterSet.get(getMap(x, y)), x * 16, y * 16, 16, 16);
    }
  }

  for (int y = 0; y < 8; ++y) {
    for (int x = 0; x < 16; ++x ) {
      image(characterSet.get(x + (16 * y)), 8 + x * 32, 168 + y * 32, 16, 16);
    }
  }

  xc = mouseX / 16;
  yc = mouseY / 16;

  stroke(((millis() & 512) == 512) ? color(255, 0, 0) : color(0, 255, 0));

  if (yc < 10) {
    rect(xc * 16, yc * 16, 15, 15);
    text("Cursor over : $" + hex(getMap(xc, yc), 2), 600,200,200,17);
    image(characterSet.get(getMap(xc, yc)), 720, 200, 16, 16);
  }
  if (yc > 10 && yc < 26 && xc < 32)
  {
    cx = xc / 2;
    cy = (yc - 10) / 2;

    stroke(color(0, 255, 0));
    rect(cx * 32 + 7, 160 + cy * 32 + 7, 17, 17);
    text("Cursor over : $" + hex(cx + cy * 16, 2), 600,200,200,17);
    image(characterSet.get(cx + cy * 16), 720, 200, 16, 16);
  }

  text("Selected: " + hex(selectedTile,2), 600, 178,200,17);
  image(characterSet.get(selectedTile), 720, 178, 16, 16);

  int y = mouseY / 16;
  if (y < 10)
    text("x = " + ((mouseX / 16) + scrollpos) + ", y = " + ((mouseY / 16)) + ".", 600, 232);
   else
    text("x = " + ((mouseX / 16) + scrollpos) + ".", 600, 232);
}

int enemyType(int c)
{
  if (c == 0x27) return 0; // stal
  if (c == 0x2f) return 1; // mine
  if (c == 0x1f) return 3; // depth
  if (c == 0x30) return 4; // shooter

  return -1;
}

void setMap(int x, int y, int c)
{
  int ec = 0;

  if (c > 63) c += 64;
  map[scrollpos + x + (600 * y)] = (byte)c;

  for (x = 0; x < 600; ++x) {
    enemyidx[x] = (byte)0xff;
    for (y = 0; y < 10; ++y) {
      int etype = enemyType(map[x + (600 * y)]);
      if (etype != -1) {
        if(etype == 1 && y < 9 && (map[x + (600 * (y+1))] == 0x32 || map[x + (600 * (y-1))] != 0x00))
          etype = 2;
          
        int ev = (etype << 4) + y;

        enemydat[ec] = (byte)ev;
        enemyidx[x] = (byte)ec;
        ++ec;
      }
    }
  }

  saveBytes("data/map.bin", map);
  saveBytes("data/enemyidx.bin", enemyidx);
  saveBytes("data/enemydat.bin", enemydat);
  
  println(ec);
}

int getMap(int x, int y)
{
  int c = map[scrollpos + x + (600 * y)] & 0xff;
  if (c > 127) c -= 64;
  return (int)c;
}

void mouseClicked() {
  if (mouseButton == LEFT) {
    if (yc > 9) {
      selectedTile = cx + 16 * cy;
    } else {
      setMap(xc, yc, selectedTile);
    }
  } else {
    if (yc > 9) {
      selectedTile = cx + 16 * cy;
    } else {
      selectedTile = getMap(xc, yc);
    }
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