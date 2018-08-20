# Labs: Docker Engine

## View the Engine and Processes

This shows details about the running engine:

```
docker system info
```

Do you see the storage driver in the above output?

We should also see processes running for docker:

```
ps -ef | grep docker
```

Included in the above output should be `dockerd` and `docker-containerd`.
Running containers will have a `docker-containerd-shim` that uses runc.

## Update the Configuration

Check the initial value of the labels:

```
docker system info --format '{{.Labels}}'
```

Edit /etc/docker/daemon.json, adding "labels" to the engine. The result should
look like:

```
{
    "experimental": true,
    "debug": true,
    "log-level": "info",
    "insecure-registries": ["127.0.0.1"],
    "hosts": ["unix:///var/run/docker.sock", "tcp://0.0.0.0:2375"],
    "labels": ["location=cloud","env=pwd"],
    "tls": false,
    "tlscacert": "",
    "tlscert": "",
    "tlskey": ""
}
```

Reload the configuration and check the resulting labels:

```
killall -HUP dockerd
docker system info --format '{{.Labels}}'
```

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



