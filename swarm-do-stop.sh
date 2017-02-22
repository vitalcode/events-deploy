#!/bin/bash

# Show swarm cluster
eval $(docker-machine env master-1)
echo "===== Local Swarm Cluster"
docker node ls

[ -z ${SWARM_NUM_MASTER} ] && SWARM_NUM_MASTER=1
echo "===== with [${SWARM_NUM_MASTER}] master nodes"

[ -z ${SWARM_NUM_WORKER} ] && SWARM_NUM_WORKER=1
echo "===== with [${SWARM_NUM_WORKER}] worker nodes"

# Remove master nodes
docker-machine stop master-1
docker-machine rm -f master-1

# Remove all worker nodes
for i in $(seq "${SWARM_NUM_WORKER}"); do
  docker-machine stop worker-${i}
  docker-machine rm -f worker-${i}
done


