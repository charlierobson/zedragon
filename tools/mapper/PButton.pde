public class CharButton extends ActiveElement
{
  int charNum;

  CharButton (int cn, float x, float y)
  {
    super(x, y, 15, 15);
    charNum = cn;
  }

  void mousePressed()
  {
    selectCharacter(charNum);
  }

  void draw () 
  {
    if (hover) {
      noFill();
      stroke(color(0, 255, 0));
      rect(x-1, y-1, 16+1, 16+1);
    }
    image(characterSet.get(charNum), x, y, 16, 16);
  }
}


public class MMButton extends ActiveElement
{
  String label;
  int mapMod;

  MMButton(String _label, int _mapMod, float x, float y, float w, float h)
  {
    super(x, y, w, h);
    label = _label;
    mapMod = _mapMod;
  }

  // one possible callback, automatically called 
  // by manager when button clicked

  void mousePressed () 
  {
    scrollpos += mapMod;
    fineScroll = scrollpos * 16;
    if (scrollpos < 0) scrollpos = 0;
    if (scrollpos > 600 - xtiles) scrollpos = 600 - xtiles;
  }

  void draw () 
  {
    if ( hover ) stroke( 255 );
    else noStroke();

    fill( 200 );
    rect(x, y, width, height);
    fill(0);
    textAlign(CENTER, CENTER);
    text(label, x + width / 2, y + height / 2);
  }
}

public class ModeButton extends ActiveElement
{
  String label;
  int mode;
  boolean on;

  ModeButton(String _label, int _mode, float x, float y, float w, float h)
  {
    super(x, y, w, h);
    label = _label;
    mode = _mode;
  }

  void mousePressed () 
  {
    setMode(mode);
  }

  void draw () 
  {
    if ( hover ) stroke( 255 );
    else noStroke();

    fill( 200 );
    rect(x, y, width, height);
    fill(0);
    textAlign(CENTER, CENTER);
    text(label, x + width / 2, y + height / 2);
  }
}