using System;
using System.IO;

namespace converter
{
    static class cvt
    {
        static void Main(string[] args)
        {
            foreach(var b in File.ReadAllBytes(args[0]))
            {
                if (b == 0x7f) Console.Write((char)9);
                else if (b == 0x9b)
                {
                    Console.Write((char)0x0d);
                    Console.Write((char)0x0a);
                }
                else Console.Write((char)b);
            }
        }
    }
}
