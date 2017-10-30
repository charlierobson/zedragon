import struct

eindex = bytearray(([255] * 600))
etype = bytearray(600)

offset = 0

with open('enemydat-o.bin','r') as f:
    while True:
        chunk = f.read(2)
        if chunk == '':
            break
        x = struct.unpack('h', chunk)[0]
        yt = struct.unpack('b', f.read(1))[0]
        ismine = (yt & 0x10) == 0x10
        isstatic = (yt & 0x20) == 0x20
        yt &= 0x0f
        if (ismine):
            yt |= 0x80
        if (isstatic):
            yt |= 0x40
        eindex[x] = offset
        etype[offset] = yt
        print(hex(x), hex(offset), hex(etype[offset]))
        offset = offset + 1

etype = etype[:offset]
o1 = open('enemyidx.bin','wb')
o1.write(eindex)
o1.close()
o2 = open('enemytbl.bin','wb')
o2.write(etype)
o2.close()
