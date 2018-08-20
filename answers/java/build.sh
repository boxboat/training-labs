#!/bin/sh

docker build -t springboot-ex \
  --build-arg JAVA_VER=8 \
  --build-arg JAVA_DIST=alpine \
  --build-arg MVN_DEP_CACHE=$(date +%Y%d%m) \
  .

