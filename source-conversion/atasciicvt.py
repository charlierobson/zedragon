import sys

for line in open(sys.argv[1], 'r'):
	print line.replace('\x7f','\t').replace('\x9b','\n').strip()
