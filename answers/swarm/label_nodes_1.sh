#!/bin/sh

docker node update --label-add type=web --label-add region=east node2
docker node update --label-add type=web --label-add region=east node3
docker node update --label-add type=web --label-add region=west node4
docker node update --label-add type=compute --label-add region=west node5

