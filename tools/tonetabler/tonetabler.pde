void setup()
{
  ArrayList<Integer> tt = new ArrayList<Integer>();
 
  double fclock = 3500000.0 / 2.0;
  //double fclock = 1.7734 * 1000000; // spectrum clock
  //double fclock =  3579545/2;  // colour clock as specified in ay docs

  Table t = loadTable("noteinfo.csv", "header");
  for(TableRow row : t.rows())
  {
    String name = row.getString("name");
    double ft = row.getDouble("frequency");
    int ct = (int)Math.ceil(fclock / (16.0 * ft));
    println(name + "\t" + ft + "\t" + Integer.toString(ct,16));
    tt.add(ct);
  }

  int n = 0;
  for(int i : tt)
  {
    if (n % 12 == 0) print("\n .word\t");
    String h = "0000" + Integer.toString(i,16);
    h = h.substring(h.length() - 4);
    print("$" + h);
    ++n;
    if (n % 12 != 0) print(",");
  }
}