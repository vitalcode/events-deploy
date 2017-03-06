#!/bin/bash

eval $(docker-machine env master-1)
docker stack deploy --compose-file docker-compose.yml events

docker service create \
    --name events-proxy \
    --restart-condition on-failure \
    --publish mode=host,target=80,published=80 \
    --publish mode=host,target=443,published=443 \
    --network events_events-network \
    --constraint node.role==manager \
    vitalcode/events-proxy