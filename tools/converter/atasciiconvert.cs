using System.IO;
using System.Collections.Generic;

namespace converter
{
    static class cvt
    {
        static void Main(string[] args)
        {
            var crlf = new byte[]{0x0d,0x0a};

            foreach (var file in args)
            {
                var content = File.ReadAllBytes(file);
                var converted = new List<byte>();
                foreach(var b in content)
                {
                    if (b == 0x7f) converted.Add(9);
                    else if (b == 0x9b) converted.AddRange(crlf);
                    else converted.Add(b);
                }
                File.WriteAllBytes(Path.ChangeExtension(file, ".txt"), converted.ToArray());
            }
        }
    }
}
