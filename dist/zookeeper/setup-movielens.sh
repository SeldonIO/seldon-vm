#!/bin/bash

set -o nounset
set -o errexit

#setup core nodes
docker exec zookeeper_server_container bash -c '/opt/zookeeper/bin/zkCli.sh < <(echo "create /clients blank")'
docker exec zookeeper_server_container bash -c '/opt/zookeeper/bin/zkCli.sh < <(echo "create /movielens blank")'

#setup semvec
docker exec zookeeper_server_container bash -c '/opt/zookeeper/bin/zkCli.sh < <(echo "create /clients/svtext movielens")'
docker exec zookeeper_server_container bash -c '/opt/zookeeper/bin/zkCli.sh < <(echo "create /movielens/svtext local://seldon-models/movielens_demo/semvec")'

#setup word2vec
docker exec zookeeper_server_container bash -c '/opt/zookeeper/bin/zkCli.sh < <(echo "create /clients/word2vec movielens")'
docker exec zookeeper_server_container bash -c '/opt/zookeeper/bin/zkCli.sh < <(echo "create /movielens/word2vec local://seldon-models/movielens_demo/word2vec")'

#setup mf
docker exec zookeeper_server_container bash -c '/opt/zookeeper/bin/zkCli.sh < <(echo "create /clients/mf movielens")'
docker exec zookeeper_server_container bash -c '/opt/zookeeper/bin/zkCli.sh < <(echo "create /movielens/mf local://seldon-models/movielens_demo/mf")'

#setup topics
docker exec zookeeper_server_container bash -c '/opt/zookeeper/bin/zkCli.sh < <(echo "create /clients/topics movielens")'
docker exec zookeeper_server_container bash -c '/opt/zookeeper/bin/zkCli.sh < <(echo "create /movielens/topics local://seldon-models/movielens_demo/topics")'
