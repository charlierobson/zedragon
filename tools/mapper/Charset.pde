byte[] getCharsetBytes()
{
  byte[] newChars = new byte[0xc0 * 8];

  for (int i =0; i < 0xc0; ++i) {
    PImage p = characterSet.get(i);
    p.loadPixels();
    for(int y = 0; y < 8; ++y) {
      int mask = 0x80;
      int bval = 0;
      for(int x = 0; x < 8; ++x) {
        if (p.pixels[x + y * 8] == color(0)) {
          bval += mask;
        }
        mask /= 2;
      }
      if (i > 63 && i < 128) {
        bval ^= 0xff;
      }
      newChars[y + i * 8] = (byte)(bval & 0xff);
    }
  }

  return newChars;
}


void putchar(PImage target, byte[] charset, int c, int x, int y)
{
  target.loadPixels();

  color fg = color(0);
  color bg = color(255);

  y *= target.width;

  for (int c2 = 0; c2 < 8; c2++) {
    byte charb = charset[c * 8 + c2];
    if (c > 63 && c < 128) charb ^= 255;

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