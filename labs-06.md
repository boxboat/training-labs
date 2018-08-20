# Labs: Networking

## Namespacing

Docker includes some default networks out of the box:

```
docker network ls
docker network inspect bridge
```

Compare running a container on the different networks:

```
# first examine the host network interfaces
ip a
# run a container with the default bridge
docker container run --rm busybox ip a
# run a container with no network
docker container run --rm --net none busybox ip a
# run a container without network namespacing, using the host interfaces
docker container run --rm --net host busybox ip a
```

## Publish a Port

Run a container that is reachable from outside of your docker host:

```
docker run -d -p 8080:80 --name app1 nginx:latest
```

Verify you can reach the container locally:

```
curl -sSL http://127.0.0.1:8080/
```

When using play-with-docker the published port should be visible as a link near
the node IP. This may take a few minutes to appear. If you have full screened
your terminal, you'll need to exit full screen by pressing Alt-Enter.

## Create a Network

Create a docker network with the default bridge driver:

```
docker network ls
docker network create web
docker network ls
```

What networks exist on a default install?

Try to connect to nginx on the new network:

```
docker run -it --rm --net web nicolaka/netshoot curl -sSL http://app1/
```

Was the "curl" command able to locate the "app1" host? Lets try adding the
app1 container to the same network. Normally this would be done when creating
the container, but docker allows us to connect and disconnect anytime:

```
docker network connect web app1
docker run -it --rm --net web nicolaka/netshoot curl -sSL http://app1/
```

## Verify the Listening Ports

Using the same netshoot image, lets connect to the network namespace of app1
and verify what interfaces and ports it is configured to listen on:

```
docker run -it --rm --net container:app1 nicolaka/netshoot netstat -lnt
```

You should see a local address of `0.0.0.0:80` indicating app1 is listening
on all interfaces, using port 80 inside the container.

## Network Aliases

Create a second nginx container with an alias matching the first container:

```
docker run -d --net web --name app2 \
 --network-alias app1 --network-alias app-us-east nginx
```

Now compare DNS lookups on the two names:

```
docker run -it --rm --net web nicolaka/netshoot nslookup app2
docker run -it --rm --net web nicolaka/netshoot nslookup app1
docker run -it --rm --net web nicolaka/netshoot nslookup app-us-east
```

The DNS entry for app1 will show two containers. Run the same lookup several
times to see the IP addresses rotating in order.

Network aliases allow access to the same container with different names, or
round-robin access to multiple containers. It is atypical to run containers like
this, but it is often used by tools like compose when replicating multiple
instances of the same service as we will see later.

## Internal Networks

Create a network with the internal option (some commands may fail):

```
docker network create --internal private
docker network inspect private
docker container run -d --net private -p 8090:80 --name backend nginx
docker container run -it --rm --net private nicolaka/netshoot ping -c 1 8.8.8.8
docker container run -it --rm --net private nicolaka/netshoot ping -c 1 backend
docker container run -it --rm --net private nicolaka/netshoot curl http://backend/
curl -sSL http://127.0.0.1:8090/
```

From the internal network, can you ping out to the internet (8.8.8.8)? Can you
ping and connect to other containers on the same network? Does publishing a
port work?

## Cleanup

To remove any containers that are still running, use:

```
docker container rm -f $(docker container ls -aq)
```


