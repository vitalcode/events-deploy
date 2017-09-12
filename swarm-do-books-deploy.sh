#!/bin/bash

PREFIX=$1
MASTER_NODE=${PREFIX}-master-1

eval $(docker-machine env $MASTER_NODE)
docker stack deploy --compose-file docker-compose-books.yml books

#docker service create \
#    --name events-proxy \
#    --restart-condition on-failure \
#    --publish mode=host,target=80,published=80 \
#    --publish mode=host,target=443,published=443 \
#    --network events_events-network \
#    --constraint node.role==manager \
#    vitalcode/events-proxy