#!/bin/sh

export stack_name=dev
docker stack deploy -c docker-compose.yml ${stack_name}

