import json
import urllib
import getopt, argparse
import re
from time import sleep

parser = argparse.ArgumentParser(prog='monitorClientsDb.py')
parser.add_argument('-movies', help='movielens 10m movies.dat file', required=True)

opts = vars(parser.parse_args())

api_key = open(".freebase_api_key").read()
service_url = 'https://www.googleapis.com/freebase/v1/mqlread'

c = 0
with open(opts['movies']) as textfile1:
    for line in textfile1:
        line = line.rstrip()
        (id,title,tags) = line.split('::')
        m = re.search(r"([^,]+).*\(([0-9]+)\)$", title)
#        print m.group(1),m.group(2)        
        year = m.group(2)
        yearNext = str(int(year)+1)
        name = m.group(1)
        name = name.strip()
        query = [{'id': None, 'subjects':[], 'genre':[],'directed_by':[],'initial_release_date' : None, 'initial_release_date>' : year,'initial_release_date<' : yearNext, 'name':None, 'name~=': name, 'type': '/film/film',"starring": [{"actor": None,"mid":   None}], "/common/topic/image":[{ "id":None, "optional":True}],'limit':1}]
        params = {'query': json.dumps(query),'key': api_key}
        url = service_url + '?' + urllib.urlencode(params)
        response = json.loads(urllib.urlopen(url).read())
        if 'result' in response and len(response['result']) == 1:
            for film in response['result']:
                film['movielens_id'] = id
                film['movielens_title'] = title
                film['freebase_search_name'] = name
                j = json.dumps(film,sort_keys=True)
                print j
#            print film['name'],film['initial_release_date'],film['directed_by'],film['subjects'],film['genre'],film['starring'][0:2]
        else:
            response['movielens_id'] = id
            response['movielens_title'] = title
            response['freebase_search_name'] = name
            j = json.dumps(response,sort_keys=True)
            print j
        sleep(0.25)






