#!/usr/bin/python
import sys
import time
import getopt, argparse
from collections import defaultdict
import datetime
from sets import Set
import json
import string

parser = argparse.ArgumentParser(prog='remapTags.py')
parser.add_argument('-t', help='original tag and cleaned tag csv file', required=True)
opts = vars(parser.parse_args())

tagMap = {}
with open(opts['t']) as f:
    for line in f:
        line = line.rstrip();
        (clean,vwtag) = line.split(',')
        tagMap[vwtag] = clean

for line in sys.stdin:
    line = line.rstrip()
    (topic,tag,weight) = line.split(',')
    tagClean = tagMap[tag]
    print topic+","+tagClean+","+weight

