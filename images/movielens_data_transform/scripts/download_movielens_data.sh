#!/bin/bash

set -o nounset
set -o errexit

DATA_FOLDER=/movielens/data

cd ${DATA_FOLDER}

#Get movielens 10m dataset
if [ ! -d "${DATA_FOLDER}/ml-10M100K" ]; then
    wget http://files.grouplens.org/datasets/movielens/ml-10m.zip
    unzip ml-10m.zip
    rm ml-10m.zip
fi

#get hetrec dataset
if [ ! -d "${DATA_FOLDER}/hetrec2011-movielens" ]; then
    mkdir -p /movielens/data/hetrec2011-movielens
    cd /movielens/data/hetrec2011-movielens
    wget http://files.grouplens.org/datasets/hetrec2011/hetrec2011-movielens-2k-v2.zip
    unzip hetrec2011-movielens-2k-v2.zip
    rm hetrec2011-movielens-2k-v2.zip
fi



