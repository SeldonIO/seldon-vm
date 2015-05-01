#!/usr/bin/env python

import sys
import argparse
import random

def getOpts():
    parser = argparse.ArgumentParser()
    parser.add_argument('--sample-percent', type=int, dest='sample_percent', help="the sample rate to use (1 - 100)", required=True)
    parser.add_argument('--random-seed', type=str, dest='random_seed', default=None, help="use seed for consistent samples")
    parser.add_argument('args', nargs=argparse.REMAINDER) # catch rest (non-options) as args
    opts = vars(parser.parse_args())
    return opts

def process_line(opts, line):
    sample_percent=opts['sample_percent']
    if random.randint(1,100) <= sample_percent:
        sys.stdout.write(line)

def process_file(opts, f):
    for line in f:
        process_line(opts, line)

def validate_opts(opts):
    sample_percent=opts['sample_percent']
    if (sample_percent < 1) or (sample_percent > 100):
        raise ValueError("sample_percent %s is invalid, needs to be 1 - 100" % sample_percent)

def checkSeed(opts):
    random_seed=opts['random_seed']
    if random_seed != None:
        random.seed(random_seed)

def main():
    opts = getOpts()
    validate_opts(opts)
    checkSeed(opts)
    if len(opts['args']) > 0:
        for filename in opts['args']:
            f = open(filename)
            process_file(opts, f)
            f.close()
    else:
        process_file(opts, sys.stdin)

if __name__ == "__main__":
    main()

