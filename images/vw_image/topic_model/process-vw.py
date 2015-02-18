#!/usr/bin/python
from rosetta.text.text_processors import SFileFilter, VWFormatter
import getopt, argparse

parser = argparse.ArgumentParser(prog='process-vw.py')
parser.add_argument('-i', help='input raw text token vw lda file', required=True)
parser.add_argument('-id', help='id2token output pkl file', required=True)
parser.add_argument('-f', help='filtered vw file with integer feature ids', required=True)
parser.add_argument('-b', help='file to store bit precision required after compaction', required=True)
opts = vars(parser.parse_args())

sff = SFileFilter(VWFormatter())
sff.load_sfile(opts['i'])

df = sff.to_frame()
df.head()
df.describe()
sff.filter_extremes(doc_freq_min=5, doc_fraction_max=0.8)
sff.compactify()
print "precision required = "+str(sff.bit_precision_required)
sff.save(opts['id'])
sff.filter_sfile(opts['i'], opts['f'])
#write bit precision required
f = open(opts['b'],"w")
f.write(str(sff.bit_precision_required))
f.close()
