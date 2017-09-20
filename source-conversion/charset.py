idx = 0
linenum = 0
for line in open('converted\disk2\dispdata', 'r'):
    linenum = linenum + 1
    if (linenum < 110):
        continue

    lines = line.replace('\t',' ').replace(',',' ').strip().split()
    numbers = [int(s) for s in lines if s.isdigit()]
    if len(numbers) < 8:
        continue

    idx = idx + 1
    if idx > 64:
        numbers = [n ^ 255 for n in numbers]

    print '\t; ' + repr(idx)
    for n in numbers:
        print '\t.byte\t\t' + '%{0:08b}'.format(n)
