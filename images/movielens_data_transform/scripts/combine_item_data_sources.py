import time
import datetime
import sys
import getopt, argparse
from collections import defaultdict
import unicodedata
import operator
import json
import unicodecsv

def remove_control_characters(s):
    return "".join(ch for ch in s if unicodedata.category(ch)[0]!="C")

def stripped(x):
    return "".join([i for i in x if 31 < ord(i) < 127])

parser = argparse.ArgumentParser(prog='combine_item_data_sources.py')
parser.add_argument('-movielens-movies', help='Movielens 10 million movies file', required=True)
parser.add_argument('-movielens-tags', help='Movielens 10 million tags file', required=True)
parser.add_argument('-hetrec-movies', help='Hetrec 2011 movies file', required=True)
parser.add_argument('-freebase-movies', help='Freebase movies file', required=True)
parser.add_argument('-csv', help='csv file to write to', required=True)
parser.add_argument('-item-attr-json', help='json file to write item attributes', required=True)

opts = vars(parser.parse_args())

num_freebase_genres = 1
num_top_movielens_tags = 2

tagMap = {}
topTags = {}
actorMap = {}
directorMap = {}
imgUrl = {}
titleMap = {}

attrs = [("string","title",titleMap),("string","img_url",imgUrl),("text","top_tags",topTags),("text","movielens_tags_full",tagMap),("string","actors",actorMap),("string","directors",directorMap)]

# write out attribute types
with open(opts['item_attr_json'], 'w') as jsonFile:
    j = {}
    j["type_id"] = 1
    j["type_name"] = "movie"
    attrList = []
    for (atype,name,amap) in attrs:
        attrJson = {}
        attrJson['name'] = name
        attrJson['value_type'] = atype
        attrList.append(attrJson)
    j["type_attrs"] = attrList
    topj = {}
    tyList = []
    tyList.append(j)
    topj["types"] = tyList
    jstr = json.dumps(topj,sort_keys=True)
    jsonFile.write(jstr)
    jsonFile.close()


#
# Load Movielens tags and keep top ones
#

ignoreTags = set()
ignoreTags.add("less_than_300_ratings")

# add tags to item_map_text

with open(opts['movielens_tags']) as textfile1:
    for line in textfile1:
        line = line.rstrip()
        (user,item,tag,time) = line.split('::')
        item = int(item)
        tag = tag.replace("\"","'")
        tag = tag.replace(",","")
        tag = tag.replace("\\n","")
        tag = stripped(tag)
        tag = tag.lower()
        tag = tag.strip()
        tag = tag.replace(" ","_")
        if not (tag in ignoreTags or "nudity" in tag):
            if item in tagMap:
                tagMap[item][tag] = tagMap[item][tag] + 1
            else:
                tagMap[item] = defaultdict(int)
                tagMap[item][tag] = 1

# Get top tags and change map to array of tags
for key in tagMap:
    map = tagMap[key]
    sorted_x = sorted(map.items(), key=operator.itemgetter(1))
    sorted_x = sorted_x[::-1]
    topList = sorted_x[0:num_top_movielens_tags]
    tags= [str(i[0]) for i in topList]
    tagMap[key] = [str(i[0]) for i in sorted_x]
    topTags[key] = tags

# add data from freebase
with open(opts['freebase_movies']) as textfile1:
    for line in textfile1:
        line = line.rstrip()
        j = json.loads(line)
        if not ('result' in j or 'error' in j):
            id = j["movielens_id"]
            id = int(id)
            genres = j['genre'][0:num_freebase_genres]
            if len(genres) > 0:
                for genre in genres:
                    if id in topTags:
                        topTags[id].append(genre.lower())
                    else:
                        topTags[id] = [genre.lower()]
            starring = j['starring']
            if starring:
                actors = []
                c = 0
                for star in starring:
                    actor = star['actor']
                    if actor:
                        actor = actor.replace("'","").replace("\"","").lower().replace(" ","_")
                        actors.append(actor)
                        c += 1
                        if c >= 3:
                            break
                if len(actors) > 0:
                    actorMap[id] = actors
                    if id in topTags:
                        topTags[id] = topTags[id] + actors
                    else:
                        topTags[id] = actors
            directed_by = j['directed_by']
            directors = []
            if directed_by and len(directed_by) > 0:
                if not type(directed_by) is list:
                    directed_by = [directed_by]
                for director in directed_by:
                    directors.append(director.replace("'","").replace("\"","").lower().replace(" ","_"))
                directorMap[id] = directors
                if id in topTags:
                    topTags[id] = topTags[id] + directors
                else:
                    topTags[id] = directors
            subjects_raw = j['subjects']
            subjects = []
            if len(subjects_raw) > 0:
                for subject in subjects_raw:
                    subjects.append(subject.replace("'","").replace("\"","").lower().replace(" ","_"))
                if id in topTags:
                    topTags[id] = topTags[id] + subjects
                else:
                    topTags[id] = subjects

first = True
with open(opts['hetrec_movies']) as textfile1:
    for line in textfile1:
        if first:
            first = False
            continue
        line = line.rstrip()
        (id,title,imdbID,spanishTitle,imdbPictureURL,year,rtID,rtAllCriticsRating,rtAllCriticsNumReviews,rtAllCriticsNumFresh,rtAllCriticsNumRotten,rtAllCriticsScore,rtTopCriticsRating,rtTopCriticsNumReviews,rtTopCriticsNumFresh,rtTopCriticsNumRotten,rtTopCriticsScore,rtAudienceRating,rtAudienceNumRatings,rtAudienceScore,rtPictureURL) = line.split('\t')
        id = int(id)
        imgUrl[id] = [imdbPictureURL]


with open(opts['movielens_movies']) as textfile1:
    for line in textfile1:
        line = line.rstrip()
        (id,title,tags) = line.split('::')
        id = int(id)
        titleMap[id] = [title]

def addFeature(fmap,id,name,dmap):
    if id in dmap:
        v = ",".join(dmap[id])
        fmap[name] = v


with open(opts['csv'], 'w') as csvfile:
    fieldnames = ["id","name"] + [str(i[1]) for i in attrs]
    writer = unicodecsv.DictWriter(csvfile,encoding='utf-8',fieldnames=fieldnames)
    writer.writeheader()
    with open(opts['movielens_movies']) as textfile1:
        for line in textfile1:
            line = line.rstrip()
            (id,title,tags) = line.split('::')
            id = int(id)
            features = {}
            features['id'] = id
            features['name'] = title
            for (atype,name,amap) in attrs:
                addFeature(features,id,name,amap)
            writer.writerow(features)

