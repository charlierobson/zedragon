linenum = 0
for line in open('converted\disk2\dispdata', 'r'):
    linenum = linenum + 1
    if (linenum < 245):
        continue

    print ';' + line.strip()
    lines = line.replace('\t',' ').replace(',',' ').strip().split()
    numbers = [int(s) for s in lines if s.isdigit()]
    if len(numbers) < 8:
        continue

    for n in numbers:
        print '\t.byte\t\t' + '%{0:08b}'.format(n)

linenum = 0
for line in open('converted\disk2\dispdata', 'r'):
    linenum = linenum + 1
    if (linenum < 110 or linenum > 240):
        continue

    print ';' + line.strip()
    lines = line.replace('\t',' ').replace(',',' ').strip().split()
    numbers = [int(s) ^ 255 for s in lines if s.isdigit()]
    if len(numbers) < 8:
        continue

    for n in numbers:
        print '\t.byte\t\t' + '%{0:08b}'.format(n)
