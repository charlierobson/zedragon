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

  PImage pg = createImage(192, 8,RGB);

  size(384,16);

  background(190);
  
  pg.loadPixels();
  for (int i = 0; i < pg.pixels.length; i++) {
    pg.pixels[i] = color(255); 
  }

  int b = 0;
  for (int i = 0; i < 8; ++i)
  {
    putchar(pg, chardata,   0,   0+b, 0);
    putchar(pg, chardata,   0,   8+b, 0);
    putchar(pg, chardata,   0,  16+b, 0);
    putchar(pg, chardata, 126, 0+i+b, 0);
    putchar(pg, chardata, 127, 8+i+b, 0);
    b += 24;
  }

  PGraphics pg2;
  pg2 = createGraphics(192,8);
  pg2.beginDraw();
  pg2.background(255);
  pg2.stroke(0);
  pg2.image(pg,0,0);
  pg2.noFill();

  pg2.rect(0*24,0,23,7);
  pg2.rect(1*24,0,23,7);
  pg2.rect(2*24,0,23,7);
  pg2.rect(3*24,0,23,7);
  pg2.rect(4*24,0,23,7);
  pg2.rect(5*24,0,23,7);
  pg2.rect(6*24,0,23,7);
  pg2.rect(7*24,0,23,7);

  pg2.endDraw();

  pg2.loadPixels();

  byte[] bytes = new byte[8*24];
  
  int bx = 0;
  for (int i = 0; i < 24; ++i)
  {
    for(int y = 0; y < 8; ++y)
    {
      int mask = 128;
      bytes[bx+y] = 0;
      for(int x = 0; x < 8; ++x)
      {
        Boolean pix = pg2.pixels[bx + x + (y*pg.width)] != color(0);
        if (pix)
        {
          bytes[bx+y] |= mask;
        }
        mask /= 2;
      }
    }

    bx = bx + 8;
  }

  image(pg2, 0, 0, pg.width * 2, pg.height * 2);

  saveBytes("subs.bin", bytes);
}

void draw()
{
}