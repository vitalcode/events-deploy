#!/bin/bash

INDEX=4

# get join token
SWARM_TOKEN=$(docker swarm join-token -q worker)

# get Swarm master IP (Docker for Mac xhyve VM IP)
SWARM_MASTER=$(docker info --format "{{.Swarm.NodeAddr}}")
echo "Swarm master IP: ${SWARM_MASTER}"
sleep 10

# remove node from cluster if exists
docker node rm --force $(docker node ls --filter "name=worker-${INDEX}" -q) > /dev/null 2>&1
# remove worker contianer with same name if exists
docker rm --force $(docker ps -q --filter "name=worker-${INDEX}") > /dev/null 2>&1
# run new worker container
docker run -d --privileged --name worker-${INDEX} --hostname=worker-${INDEX} \
-p ${INDEX}2375:2375 \
-p ${INDEX}5000:5000 \
-p ${INDEX}5001:5001 \
-p ${INDEX}5601:5601 \
docker:1.13-rc-dind --registry-mirror http://${SWARM_MASTER}:4000
# add worker container to the cluster
docker --host=localhost:${INDEX}2375 swarm join --token ${SWARM_TOKEN} ${SWARM_MASTER}:2377

# show swarm cluster
printf "\nLocal Swarm Cluster\n===================\n"

docker node ls
