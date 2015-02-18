import sys, getopt, argparse

parser = argparse.ArgumentParser(prog='prune_words')
parser.add_argument('-d', help='dimension', required=True)
opts = vars(parser.parse_args())

dim = int(opts['d'])

print "-vectortype REAL -dimension "+str(dim)
for line in sys.stdin:
    line = line.rstrip()
    parts = line.split(',')
    print "|".join(parts)


