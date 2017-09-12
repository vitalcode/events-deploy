#!/bin/bash

# Check if DIGITAL_OCEAN_TOKEN is set
[ -z ${DIGITAL_OCEAN_TOKEN} ] && echo ">>>>> DIGITAL_OCEAN_TOKEN is unset" && exit 1
echo "===== Building swarm: "

[ -z ${DIGITAL_OCEAN_REGION} ] && DIGITAL_OCEAN_REGION=lon1
echo "===== for [${DIGITAL_OCEAN_REGION}] region"

[ -z ${SWARM_NUM_MASTER} ] && SWARM_NUM_MASTER=1
[ -z ${SWARM_MEMORY_MASTER} ] && SWARM_MEMORY_MASTER=4gb
echo "===== with [${SWARM_NUM_MASTER}] [${SWARM_MEMORY_MASTER}] master nodes"

[ -z ${SWARM_NUM_WORKER} ] && SWARM_NUM_WORKER=1
[ -z ${SWARM_MEMORY_WORKER} ] && SWARM_MEMORY_WORKER=4gb
echo "===== with [${SWARM_NUM_WORKER}] [${SWARM_MEMORY_WORKER}] worker nodes"

# Unique prefix
PREFIX=$1

# Set docker-machine options
MASTER_OPTIONS="--driver digitalocean 
                --digitalocean-access-token=${DIGITAL_OCEAN_TOKEN} 
                --digitalocean-region=${DIGITAL_OCEAN_REGION} 
                --digitalocean-size=${SWARM_MEMORY_MASTER}
                --engine-opt experimental=true
                --swarm-experimental"
                
WORKER_OPTIONS="--driver digitalocean 
                --digitalocean-access-token=${DIGITAL_OCEAN_TOKEN} 
                --digitalocean-region=${DIGITAL_OCEAN_REGION} 
                --digitalocean-size=${SWARM_MEMORY_WORKER}
                --engine-opt experimental=true
                --swarm-experimental"

# Create master node
MASTER_NODE=${PREFIX}-master-1
docker-machine create ${MASTER_OPTIONS} ${MASTER_NODE}
docker-machine ssh ${MASTER_NODE} sysctl -w vm.max_map_count=262144
eval $(docker-machine env ${MASTER_NODE})

# get swarm master ip
SWARM_MASTER_IP=$(docker-machine ip ${MASTER_NODE})
echo "===== Swarm master IP: [${SWARM_MASTER_IP}]"

# initialise swarm
docker swarm init --listen-addr=${SWARM_MASTER_IP}:2733 --advertise-addr=${SWARM_MASTER_IP}:2733

# get worker join token
SWARM_TOKEN_WORKER=$(docker swarm join-token -q worker)
echo "===== Swarm worker join token: [${SWARM_TOKEN_WORKER}]"

# Create workers node and join the swarm
for i in $(seq "${SWARM_NUM_WORKER}"); do
  WORKER_NODE=${PREFIX}-worker-${i}
  docker-machine create ${WORKER_OPTIONS} ${WORKER_NODE}
  docker-machine ssh ${WORKER_NODE} sysctl -w vm.max_map_count=262144
  eval $(docker-machine env ${WORKER_NODE})
  docker swarm join --token ${SWARM_TOKEN_WORKER} ${SWARM_MASTER_IP}:2733
done

# Show swarm cluster
eval $(docker-machine env ${MASTER_NODE})
echo "===== Local Swarm Cluster"
docker node ls

