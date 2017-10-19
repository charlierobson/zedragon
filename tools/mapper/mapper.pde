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

    if ((charb & 0x80) != 0) target.pixels[x + 0 + y] = fg; else target.pixels[x + 0 + y] = bg;
    if ((charb & 0x40) != 0) target.pixels[x + 1 + y] = fg; else target.pixels[x + 1 + y] = bg;
    if ((charb & 0x20) != 0) target.pixels[x + 2 + y] = fg; else target.pixels[x + 2 + y] = bg;
    if ((charb & 0x10) != 0) target.pixels[x + 3 + y] = fg; else target.pixels[x + 3 + y] = bg;
    if ((charb & 0x8) != 0)  target.pixels[x + 4 + y] = fg; else target.pixels[x + 4 + y] = bg;
    if ((charb & 0x4) != 0)  target.pixels[x + 5 + y] = fg; else target.pixels[x + 5 + y] = bg;
    if ((charb & 0x2) != 0)  target.pixels[x + 6 + y] = fg; else target.pixels[x + 6 + y] = bg;
    if ((charb & 0x1) != 0)  target.pixels[x + 7 + y] = fg; else target.pixels[x + 7 + y] = bg;

    y += target.width;
  }
  
  target.updatePixels();
}

byte[] mapdata;
ArrayList<PImage> characterSet;
int lastMouseX;

void setup()
{
  mapdata = loadBytes("map.bin");
  characterSet = new ArrayList<PImage>();

  size(1000,200);
  background(128);

  lastMouseX = mouseX;

  byte[] chardata = loadBytes("sdchars.bin");

  characterSet = new ArrayList<PImage>();
  for (int i = 0; i < 64; ++i) {
    PImage p = new PImage(8,8);
    putchar(p, chardata, i, 0, 0);
    characterSet.add(p);
  }
}

void draw()
{
  for(int y = 0; y < 10; ++y) {
    for (int x = 0; x < 600; ++x ) {
      byte b = mapdata[x+(600*y)];
      image(characterSet.get(b), x * 8, y * 8);
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

  println(delta);
}