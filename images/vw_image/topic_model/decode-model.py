#!/usr/bin/python
from rosetta.text.vw_helpers import LDAResults
import getopt, argparse

parser = argparse.ArgumentParser(prog='decode-model')
parser.add_argument('-t', help='vw topics file', required=True)
parser.add_argument('-p', help='vw predictions file', required=True)
parser.add_argument('-idx', help='topics idx file', required=True)
parser.add_argument('-num_topics', help='number of topics', required=True)
parser.add_argument('-min_token_prob', help='min token probability to output to topics probabilities ', required=True)
parser.add_argument('-topics_out', help='topic probabilities output csv file', required=True)
#parser.add_argument('-docs_out', help='document probabilities output csv file', required=True)
opts = vars(parser.parse_args())


min_token_prob = float(opts['min_token_prob'])

lda = LDAResults(opts['t'], opts['p'], opts['idx'],
                 num_topics=int(opts['num_topics']))

# create topic ids
topic_num=1
topicIds = {}
for topic_name in lda.pr_topic.index:
    topicIds[topic_name] = topic_num
    topic_num += 1

#f = open(opts['docs_out'],"w")
#for doc_id in lda.pr_doc.index:
#    sorted_topic = lda.pr_topic_g_doc[doc_id]
#    for (index,value) in sorted_topic.iteritems():
#        f.write(str(doc_id)+","+str(topicIds[index])+","+str(value)+"\n")
#f.close()

f = open(opts['topics_out'],"w")
for topic_name in lda.pr_topic.index:
    sorted_topic = lda.pr_token_g_topic[topic_name].order(ascending=False)
    for (index,value) in sorted_topic.iteritems():
        if value > min_token_prob:
            f.write(str(topicIds[topic_name])+","+index+","+str(value)+"\n")
f.close()
