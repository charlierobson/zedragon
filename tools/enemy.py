import struct

eindex = bytearray(([255] * 600))
etype = bytearray(600)

offset = 0

with open('..\enemydat-o.bin','r') as f:
    while True:
        chunk = f.read(2)
        if chunk == '':
            break
        x = struct.unpack('h', chunk)[0]
        print(hex(x), hex(offset))
        yt = struct.unpack('b', f.read(1))[0]
        eindex[x] = offset
        etype[offset] = yt
        offset = offset + 1

etype = etype[:offset]
o1 = open('enemyidx.bin','wb')
o1.write(eindex)
o1.close()
o2 = open('enemytbl.bin','wb')
o2.write(etype)
o2.close()
