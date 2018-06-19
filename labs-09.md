# Labs: Registry

## Start A Registry

This will run your own local registry server. It does not have any TLS
configured, and does not have any authorization, so this should only
be done in a lab:

```
cd
mkdir registry
docker container run -d -p 5000:5000 --restart=unless-stopped --name registry \
  -v "$(pwd)/registry:/var/lib/registry" registry:2
```

## Tag and Push and Image

Creating a new reference to an image is needed to push that image. Then we can
push that image to the registry we created locally:

```
docker image tag busybox:latest localhost:5000/busybox:latest
docker image push localhost:5000/busybox:latest
```

Now try deleting that tag and pulling the image again:

```
docker image rm localhost:5000/busybox:latest
docker image pull localhost:5000/busybox:latest
```

With TLS configured, docker would allow you to pull that image to other hosts.

## Push to Docker Hub

If you have time, login to Docker Hub, create a public repository, and try
tagging and pushing one of your images to that repository. Then try to
pull that same image to another node. The commands for that look like:

```
docker image tag busybox:latest ${your_user_id}/training:latest
docker image push ${your_user_id}/training:latest
```

and on another node:

```
docker image pull ${your_user_id}/training:latest
docker container run -it --rm ${your_user_id}/training:latest echo hello world
```

