Deploys elasticsearch cluster to local docker swarm.

### Run docker swarm, using docker-in-docker approch

`./swarm-start.sh`

Docker swarm Visualiser is accessible on `http://localhost:8000/`

### Deploy elasticsearch service

`./swarm-deploy.sh`

The elasticsearch service will now be listening on `http://localhost:9200/`

### Add additional node to docker swam cluster (just to test service elasticity)

`./swarm-add-node.sh`

Another node will be added to the cluster. Elasticsearch is deployed as a global service and will be automatically deployed on the new node.

### To remove swarm cluster

`./swarm-stop.sh`
