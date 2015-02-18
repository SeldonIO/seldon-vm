FROM ubuntu:trusty

ENV HOME /root

ADD apps /apps

VOLUME ["/seldon-models"]

ADD movielens_demo /seldon-models/movielens_demo

# Define default command.
CMD ["/apps/bin/keep_alive"]

