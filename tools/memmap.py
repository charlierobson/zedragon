start = 0x808A
end = start + 6000
print(hex(start) + " - " + hex(end) + " : mirror map")
start = 0x9800
end = start + 16*64
print(hex(start) + " - " + hex(end) + " : ostore")

start = 0x2000
end = start + 1536
print(hex(start) + " - " + hex(end) + " : charsets")
start = 0x2600
end = start + 6000
print(hex(start) + " - " + hex(end) + " : pure map")
