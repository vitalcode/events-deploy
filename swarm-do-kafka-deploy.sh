#!/bin/bash

eval $(docker-machine env master-1)
docker stack deploy --compose-file docker-compose-kafka.yml events
