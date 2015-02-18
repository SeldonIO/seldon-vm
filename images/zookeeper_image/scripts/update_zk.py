#!/usr/bin/python
from kazoo.client import KazooClient
import sys

zk = KazooClient(hosts='127.0.0.1:2181')
zk.start()

for line in sys.stdin:
    line = line.rstrip()
    (command,node,data) = line.split(",")
    if command == "set":
        if zk.exists(node):
            zk.set(node,data)
        else:
            zk.create(node,data,makepath=True)
    elif command == "append":
        if zk.exists(node):
            dataExisting, stat = zk.get(node)
            if len(dataExisting) > 0:
                parts = dataExisting.split(",")
                try:
                    parts.index(data)
                except ValueError:
                    dataNew = dataExisting + "," + data
                    zk.set(node,dataNew)
            else:
                zk.set(node,data)
        else:
            zk.create(node,data,makepath=True)

zk.stop()
