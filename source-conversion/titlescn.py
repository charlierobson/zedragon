import string

def ishexdigit(char):
    return char in string.hexdigits

def ishexstring(strng):
    return filter(ishexdigit, strng) == strng


linenum = 0
collection = []

for line in open('converted\disk4\dispdata', 'r'):
    linenum = linenum + 1
    if (linenum < 30 or linenum > 85):
        continue

    lines = line.replace('\t',' ').replace(',',' ').replace('$', ' ').replace('db  ',' ').strip().split()
    numbers = [int(s, 16) for s in lines if ishexstring(s)]

    if line.startswith('fr'):
        if len(collection) == 22:
            collection.append([0,0])
        if len(collection) == 24:
            print '\t.byte\t\t' + ','.join(['${0:02x}'.format(x & 31) for x in collection])
            collection = []

    for n in numbers:
        if n == 0xdb:
            continue;
        collection.append(n)
