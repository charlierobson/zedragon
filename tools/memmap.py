import os

def x(value):
    return format(value, 'x')

def roundup100(lower):
    return (lower + 255) & 0xff00

def roundup10(lower):
    return ((lower + 15) / 16) * 16

mapstat = os.stat('map.binlz')
tsstat = os.stat('titlescrn.binlz')
hercstat = os.stat('hercules.binlz')
txtresstat = os.stat('txtres.bin')

start = 0x2000
end = start + 0x600
print("UDG = $" + x(start))

start = roundup10(end)
end = start + 256
print("enemydat = $" + x(start))

start = roundup10(end)
end = start + 64*32
print("OSTORE = $" + x(start))

start = roundup10(end)
end = start + (3*8*8)
print("subpix = $" + x(start))

start = roundup10(end)
end = start + mapstat.st_size
print("PUREMAP = $" + x(start))

start = roundup10(end)
end = start + 600
print("enemyidx = $" + x(start))

start = roundup10(end)
end = start + 20
print("mul600tab = $" + x(start))

start = roundup10(end)
end = start + tsstat.st_size
print("titlescreen = $" + x(start))

start = roundup10(end)
end = start + txtresstat.st_size
print("txtres = $" + x(start))

start = roundup10(end)
end = start + hercstat.st_size
print("ttfont = $" + x(start))

start = roundup10(end)
end = start + 190
print("congrattext = $" + x(start))

start = roundup10(end)
remaining = 0x4000 - start
print("; spare @ $" + x(remaining) + " " + str(remaining) + " bytes remaining")
print

#----------------------------------


start = 0x8000
end = start + 48
print("inputsid = $" + x(start))
print("inputstates = $" + x(start + 4))

start = end
end = start + 64
print("FREELIST = $" + x(start))

start = 0x808a
end = start + 6000
print("D_MIRROR = $" + x(start))

start = roundup100(end)
end = start + 1024
print("CHARSETS = $" + x(start))

start = roundup100(end)
end = start + 512
print("DRAWLIST_0 = $" + x(start))

start = roundup100(end)
end = start + 512
print("DRAWLIST_1 = $" + x(start))
