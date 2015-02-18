#!/usr/bin/python
import sys
import time
import getopt, argparse
from collections import defaultdict
import datetime
from sets import Set
import json
import string

parser = argparse.ArgumentParser(prog='create-vw.py')
parser.add_argument('-p', help='number of vw passes', required=True)
parser.add_argument('-t', help='user topic threshold', required=True)
opts = vars(parser.parse_args())

threshold = float(opts['t'])
passes = int(opts['p'])
firstId = -1
lookForId = True
seenFirstId = 0
for line in sys.stdin:
    line = line.rstrip()
    parts = line.split()
    id = parts[-1]
    if firstId == -1:
        firstId = id
    if lookForId:
        if id == firstId:
            seenFirstId += 1
            if seenFirstId >= passes:
                lookForId = False
    if not lookForId:
        outStr = id
        sum = 0
        for i in range(0,len(parts)-1):
            sum += float(parts[i])
        for i in range(0,len(parts)-1):
            v = float(parts[i])/sum
            if v <0.01:
                v = 0.0
            if v >= threshold:
                outStr += (',%d:%s' % (i+1,float('%.2g' % (v))))
        print outStr
