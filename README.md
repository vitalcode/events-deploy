Deploys elasticsearch cluster to local docker swarm.

### Run docker swarm, using docker-in-docker approch

`./swarm-start.sh`

Docker swarm Visualiser is accessible on [http://localhost:8000/](http://localhost:8000/).

### Deploy elasticsearch service

`./swarm-deploy.sh`

The elasticsearch service will now be listening on [http://localhost:9200/](http://localhost:9200/).

A web front end for an elasticsearch cluster [elasticsearch-head](https://github.com/mobz/elasticsearch-head), is available on [http://localhost:9200/_plugin/head/](http://localhost:9200/_plugin/head/).


### Add additional node to docker swam cluster (to test service elasticity)

`./swarm-add-node.sh`

Another node will be added to the cluster. Elasticsearch is deployed as a global service and will be automatically deployed on the new node.

### To remove swarm cluster

`./swarm-stop.sh`
