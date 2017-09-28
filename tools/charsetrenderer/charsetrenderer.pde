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


void setup()
{
  byte[] chardata = loadBytes("sdchars.bin");

  PImage pg = createImage(33*8, 17*8,RGB);
  pg.loadPixels();
  for (int i = 0; i < pg.pixels.length; i++) {
    pg.pixels[i] = color(220); 
  }

  for(int c = 0; c < 128; c++)
  {
    putchar(pg, chardata, c, 8 + 16 * (c & 15), 8 + 16 * (c / 16));
  }

  size(560,304);
  background(190);
  image(pg, 16, 16, pg.width * 2, pg.height * 2);

  fill(0,50,100);
  for(int c = 0; c < 128; c++)
  {
    text(hex(c&15, 2), 32 + 32 * (c & 15), 12);
    text(hex(c/16, 2), 0, 44 + 32 * (c / 16));
  }
  save("sd-chars.png");
}

void draw()
{
}