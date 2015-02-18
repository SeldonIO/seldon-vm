SHELL := /bin/bash

CLIENT=unknown
SCRIPTS_FOLDER=..
BIT_PRECISION=`cat bit_precision.txt`
NUM_DOCS=`wc -l lda_filtered.vw | awk '{print $$1}'`
VW_PASSES=2
LDA_TOPICS=200
YESTERDAY=`echo $$(($$(date --date='1 days ago' +%s) / 86400))`
TOPIC_THRESHOLD=0.05
INPUT=/seldon-data/${CLIENT}/user_tag_count/${YESTERDAY}
OUTPUT=/seldon-data/${CLIENT}/topics/${YESTERDAY}
TYPE=local

data/data_loaded.aws:
	aws s3 cp --region eu-west-1 --recursive s3:/${INPUT} data
	touch data/data_loaded.aws

data/data_loaded.local:
	mkdir -p data
	cp ${INPUT}/* data
	touch data/data_loaded.local

lda.vw:data/data_loaded.${TYPE}
	cat data/part-* | ${SCRIPTS_FOLDER}/create-vw.py -t tagmap.csv > lda.vw

lda_filtered.vw sff_file.pkl bit_precision.txt:lda.vw
	${SCRIPTS_FOLDER}/process-vw.py -i lda.vw -id sff_file.pkl -f lda_filtered.vw -b bit_precision.txt

prediction.dat topics.dat:lda_filtered.vw
	rm -f cache.file
	vw --cache_file cache.file -d lda_filtered.vw --lda ${LDA_TOPICS} --lda_D ${NUM_DOCS}  -p prediction.dat --readable_model topics.dat --passes ${VW_PASSES} --bit_precision ${BIT_PRECISION}

prediction.dat.dummy:prediction.dat
	head -n 1 prediction.dat > prediction.dat.dummy

topics_pr.csv:topics.dat prediction.dat.dummy
	${SCRIPTS_FOLDER}/decode-model.py -t topics.dat -p prediction.dat.dummy -idx sff_file.pkl -num_topics ${LDA_TOPICS} -topics_out topics_pr.csv  -min_token_prob 0.0001

topics.csv:topics_pr.csv tagmap.csv
	cat topics_pr.csv | ${SCRIPTS_FOLDER}/remapTags.py -t tagmap.csv > topics.csv

user_pr.csv:prediction.dat
	cat prediction.dat | ${SCRIPTS_FOLDER}/processPredictions.py -p ${VW_PASSES} -t ${TOPIC_THRESHOLD} > user_pr.csv

uploaded.aws:data/data_loaded.aws user_pr.csv topics.csv
	aws s3 cp --region eu-west-1 user_pr.csv s3://${OUTPUT}/users.csv
	aws s3 cp --region eu-west-1 topics.csv s3://${OUTPUT}/topics.csv
	touch uploaded.aws

uploaded.local:data/data_loaded.local user_pr.csv topics.csv
	mkdir -p ${OUTPUT}
	cp user_pr.csv ${OUTPUT}/users.csv
	cp topics.csv ${OUTPUT}/topics.csv
	touch uploaded.local

clean:
	rm -f lda.vw  lda_filtered.vw sff_file.pkl bit_precision.txt cache.file
	rm -f prediction.dat topics.dat topics_pr.csv user_pr.csv 	
	rm -f data/*
	rm -f prediction.dat.dummy
	rm -f tagmap.csv
	rm -f topics.csv
	rm -f uploaded
