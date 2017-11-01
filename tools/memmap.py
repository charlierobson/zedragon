import os

def roundup(lower):
    return (lower + 255) & 0xff00

mapstat = os.stat('map.binlz')

print("---------------------------")
start = 0x808A
end = start + 6000
print(hex(start) + " - " + hex(end) + " : mirror map")

start = roundup(end)
end = start + 16*64
print(hex(start) + " - " + hex(end) + " : ostore")

start = end
end = start + 1024
print(hex(start) + " - " + hex(end) + " : charsets")

print("---------------------------")

start = 0x2000
end = start + 0x600
print(hex(start) + " - " + hex(end) + " : udg")

start = end
end = int(roundup(start + mapstat.st_size))
print(hex(start) + " - " + hex(end) + " : pure map")

start = end
remaining = 0x4000 - start
print(hex(remaining) + " (" + str(remaining) + ") bytes remaining")

print("---------------------------")
