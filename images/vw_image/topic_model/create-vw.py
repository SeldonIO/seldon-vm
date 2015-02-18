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
parser.add_argument('-t', help='original tag and cleaned tag map', required=True)
opts = vars(parser.parse_args())

def cleanTag(tag):
    tag = tag.replace(" ","_")
    tag = tag.replace(":","_")
    return tag

def writeVwLda(userid,tagCount):
    print "1 1.0 "+str(userid)+"| ",
    for tag in tagCount:
        if tag and not tag == " ":
            print tag+":"+str(tagCount[tag]),
    print ""


tagMap = {}
lastUser = -1
tagCount = {}
for line in sys.stdin:
    line = line.rstrip()
    (userid,tagOrig,tcount) = line.split(',')
    userid = int(userid)
    tag = cleanTag(tagOrig)
    tagMap[tagOrig] = tag
    if lastUser > -1 and not lastUser == userid:
        if lastUser > 0:
            writeVwLda(lastUser,tagCount)
        numActions = 0
        tagCount = {}
    lastUser = userid
    tagCount[tag] = int(tcount)
writeVwLda(lastUser,tagCount)

f = open(opts['t'],"w")
for k in tagMap:
    f.write(k)
    f.write(",")
    f.write(tagMap[k])
    f.write("\n")
f.close()
