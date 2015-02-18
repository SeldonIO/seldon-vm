#!/bin/bash

set -o nounset
set -o errexit

#setup database settings
docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/movielens?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/movielens/db_read'
docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/movielens?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/movielens/db_write'

docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/testclient?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/testclient/db_read'
docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/testclient?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/testclient/db_write'

docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/test1?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/test1/db_read'
docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/test1?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/test1/db_write'

docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/test2?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/test2/db_read'
docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/test2?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/test2/db_write'

docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/test3?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/test3/db_read'
docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/test3?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/test3/db_write'

docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/test4?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/test4/db_read'
docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/test4?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/test4/db_write'

docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/test5?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/test5/db_read'
docker exec consul curl -s -X PUT -d '{"host":"mysql_server","username":"root","password":"mypass","jdbc":"jdbc:mysql://mysql_server:3306/test5?characterEncoding=utf8&user=root&password=mypass"}' 'http://localhost:8500/v1/kv/seldon/test5/db_write'
