import os

def roundup(lower):
    return (lower + 255) & 0xff00

mapstat = os.stat('map.binlz')
tsstat = os.stat('titlescrn.binlz')
hercstat = os.stat('hercules.binlz')

start = 0x2000
end = start + 0x600
#print(hex(start) + " - " + hex(end) + " : udg")
print("UDG = $" + format(start, 'x'));

start = end
end = int(roundup(start + mapstat.st_size))
#print(hex(start) + " - " + hex(end) + " : pure map")
print("PUREMAP = $" + format(start, 'x'));

start = end
end = start + 64*32
#print(hex(start) + " - " + hex(end) + " : ostore (32 objects)")
print("OSTORE = $" + format(start, 'x'));

start = end
end = start + 256
#print(hex(start) + " - " + hex(end) + " : enemydat")
print("enemydat = $" + format(start, 'x'));

start = end
end = start + 3*8*8
#print(hex(start) + " - " + hex(end) + " : prescrolledsubs")
print("subpix = $" + format(start, 'x'));

start = end
end = start + 600
#print(hex(start) + " - " + hex(end) + " : enemyidx")
print("enemyidx = $" + format(start, 'x'));

start = end
end = start + tsstat.st_size
#print(hex(start) + " - " + hex(end) + " : enemyidx")
print("titlescreen = $" + format(start, 'x'));

start = roundup(end)
end = start + 20
print("mul600tab = $" + format(start, 'x'));

start = end
end = start + 32*9
print("txtres = $" + format(start, 'x'));

start = end
end = start + hercstat.st_size
print("hercfont = $" + format(start, 'x'));

start = end
end = start + 160
print("congrattext = $" + format(start, 'x'));

start = end
remaining = 0x4000 - start
print(hex(remaining) + " (" + str(remaining) + ") bytes remaining")

#----------------------------------

start = 0x8000
end = start + 0x8a
#print(hex(start) + " - " + hex(end) + " : mirror map")
print("FREELIST = $" + format(start, 'x'));

start = end
end = start + 6000
#print(hex(start) + " - " + hex(end) + " : mirror map")
print("D_MIRROR = $" + format(start, 'x'));

start = roundup(end)
end = start + 1024
#print(hex(start) + " - " + hex(end) + " : charsets")
print("CHARSETS = $" + format(start, 'x'));

start = roundup(end)
end = start + 512
#print(hex(start) + " - " + hex(end) + " : charsets")
print("DRAWLIST_0 = $" + format(start, 'x'));

start = roundup(end)
end = start + 512
#print(hex(start) + " - " + hex(end) + " : charsets")
print("DRAWLIST_1 = $" + format(start, 'x'));
