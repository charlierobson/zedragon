void updateEnemies()
{
  int ec = 0;
  for (int x = 0; x < 600; ++x) {
    enemyidx[x] = (byte)0xff;
    for (int y = 0; y < 10; ++y) {
      int etype = enemyType(map[x + (600 * y)]);
      if (etype != -1) {
        if (etype == 1 && y < 9 && ((map[x + (600 * (y+1))] & 0xff) == 0x96 || map[x + (600 * (y-1))] != 0x00))
          etype = 2;

        int ev = (etype << 4) + y;

        enemydat[ec] = (byte)ev;
        enemyidx[x] = (byte)ec;
        ++ec;
      }
    }
  }
  println(ec);
}