# Labs: Docker Engine

## View the Engine and Processes

This shows details about the running engine:

```
docker info
```

Do you see the storage driver in the above output?

We should also see processes running for docker:

```
ps -ef | grep docker
```

Included in the above output should be `dockerd` and `docker-containerd`.
Running containers will have a `docker-containerd-shim` that uses runc.

## Inspect the Layers of an Image

```
docker pull nginx:latest
docker image history --no-trunc \
  --format '{{.CreatedAt}}: {{.CreatedBy}}' nginx:latest
```

The layers are listed from the most recent to the oldest/lowest layers.
The "ADD" command loads to tgz file to setup a base OS. The "#(nop)" layers
are setting metadata without running a command. Lets pull another image and
look at its layers:

```
docker pull debian:stretch-slim
docker image history --no-trunc debian:stretch-slim
```

If you look carefully, you'll see the lowest layers of the nginx image
match that of the debian:stretch-slim image. This shows both the layered
filesystem but also the extending of one image from another image.

## Networks

Docker includes some default networks out of the box:

```
docker network ls
docker network inspect bridge
```

Run a container using the default bridge network, and compare that to
the networks on the host:

```
ip a
docker container run --rm busybox ip a
```

## Namespaces

Containers run processes different namespaces. We've already seen filesystem
and network namespaces. Lets look at the PID namespace:

```
docker container run --name pinger -d busybox ping 8.8.8.8
ps -ef | grep ping
docker exec pinger ps -ef
```

Did you get an error about "pinger" already being used? First stop and remove
that container before reusing the name.

Compare the PID inside vs outside the container. The host can see the container
but the container cannot see the host. Cleanup this container:

```
docker container stop pinger
docker container rm pinger
```

## Security

Lets try running a few commands to break out of our container. First, start
up a new container and verify your user id:

```
docker container run -it --rm busybox /bin/sh
whoami
```

Now try each of the following commands to see what is possible as the root
user inside the container:

```
date -s "1999-12-31 23:59:00"
hostname hacked
ip link set eth0 down
mount -t proc proc /mnt
echo 1 >/proc/sys/net/ipv4/ip_forward
reboot
exit
```

Did any of these commands work (other than exit)?


