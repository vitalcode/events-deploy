#!/bin/bash

# Check if DIGITAL_OCEAN_TOKEN is set
[ -z ${DIGITAL_OCEAN_TOKEN} ] && echo ">>>>> DIGITAL_OCEAN_TOKEN is unset" && exit 1
echo "===== Building swarm: "

[ -z ${DIGITAL_OCEAN_REGION} ] && DIGITAL_OCEAN_REGION=lon1
echo "===== for [${DIGITAL_OCEAN_REGION}] region"

[ -z ${SWARM_NUM_MASTER} ] && SWARM_NUM_MASTER=1
[ -z ${SWARM_MEMORY_MASTER} ] && SWARM_MEMORY_MASTER=2gb
echo "===== with [${SWARM_NUM_MASTER}] [${SWARM_MEMORY_MASTER}] master nodes"

[ -z ${SWARM_NUM_WORKER} ] && SWARM_NUM_WORKER=1
[ -z ${SWARM_MEMORY_WORKER} ] && SWARM_MEMORY_WORKER=2gb
echo "===== with [${SWARM_NUM_WORKER}] [${SWARM_MEMORY_WORKER}] worker nodes"

# Set docker-machine options
MASTER_OPTIONS="--driver digitalocean 
                --digitalocean-access-token=${DIGITAL_OCEAN_TOKEN} 
                --digitalocean-region=${DIGITAL_OCEAN_REGION} 
                --digitalocean-size=${SWARM_MEMORY_MASTER}
                --swarm-experimental"
                
WORKER_OPTIONS="--driver digitalocean 
                --digitalocean-access-token=${DIGITAL_OCEAN_TOKEN} 
                --digitalocean-region=${DIGITAL_OCEAN_REGION} 
                --digitalocean-size=${SWARM_MEMORY_WORKER}
                --swarm-experimental"

# Create master node
docker-machine create ${MASTER_OPTIONS} master-1
eval $(docker-machine env master-1)

# get swarm master ip
SWARM_MASTER_IP=$(docker-machine ip master-1)
echo "===== Swarm master IP: [${SWARM_MASTER_IP}]"

# initialise swarm
docker swarm init --listen-addr=${SWARM_MASTER_IP}:2733 --advertise-addr=${SWARM_MASTER_IP}:2733

# get worker join token
SWARM_TOKEN_WORKER=$(docker swarm join-token -q worker)
echo "===== Swarm worker join token: [${SWARM_TOKEN_WORKER}]"

# Run swarm visualizer on master node
eval $(docker-machine env master-1)
echo "===== Run Local Swarm Visualizer"
docker rm --force swarm_visualizer > /dev/null 2>&1
docker run -it -d --name swarm_visualizer \
  -p 8000:8080 -e HOST=localhost \
  -v /var/run/docker.sock:/var/run/docker.sock \
  manomarks/visualizer:beta


# Create workers node and join the swarm
for i in $(seq "${SWARM_NUM_WORKER}"); do
  docker-machine create ${WORKER_OPTIONS} worker-${i}
  eval $(docker-machine env worker-${i})
  docker swarm join --token ${SWARM_TOKEN_WORKER} ${SWARM_MASTER_IP}:2733
done

# Show swarm cluster
eval $(docker-machine env master-1)
echo "===== Local Swarm Cluster"
docker node ls

