#!/bin/bash

set -o nounset
set -o errexit

#download the movielens data
echo "downloading movielens 10m dataset and hetrec 2011 data"
/movielens/scripts/download_movielens_data.sh
# copy freebase data
cp /freebase_data/freebase.json /movielens/data

# create the item meta data csv
echo "create item meta data csv"
python /movielens/scripts/combine_item_data_sources.py -movielens-tags /movielens/data/ml-10M100K/tags.dat -freebase-movies /movielens/data/freebase.json -hetrec-movies /movielens/data/hetrec2011-movielens/movies.dat -movielens-movies /movielens/data/ml-10M100K/movies.dat -csv /movielens/seldon/movielens_items.csv -item-attr-json /movielens/seldon/movielens_items.json

#create the user csv (no demographic data so just the ids)
echo "create user meta data csv"
cat <(echo "id") <(cat /movielens/data/ml-10M100K/ratings.dat | awk -F'::' '{print $1}' | sort -n | uniq) > /movielens/seldon/movielens_users.csv

#create actions csv file in correct format
echo "create actions csv"
echo "user_id,item_id,value,time" > /movielens/seldon/movielens_actions.csv
cat /movielens/data/ml-10M100K/ratings.dat | awk -F"::" 'BEGIN{OFS=","}{print $1,$2,$3,$4}' >>  /movielens/seldon/movielens_actions.csv


