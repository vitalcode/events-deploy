#!/bin/bash

docker swarm leave --force > /dev/null 2>&1

docker rm -f -v $(docker ps -aq) > /dev/null 2>&1

docker network rm $(docker network ls -q) > /dev/null 2>&1

