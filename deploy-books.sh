#!/bin/bash

SWARM_ID=$(uuidgen | cut -c 1-6)
echo "======>>>>>> SWARM_ID=$SWARM_ID"

./swarm-do-start.sh $SWARM_ID \
    && sh -x ./swarm-do-books-deploy.sh $SWARM_ID \
    && echo "======>>>>>> Books was deployed"
