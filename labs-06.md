# Labs: Networking

## Publish a Port

Run a container that is reachable from outside of your docker host:

```
docker run -d -p 8080:80 --name nginx nginx:latest
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
docker run -it --rm --net web nicolaka/netshoot curl -sSL http://nginx/
```

Was the "curl" command able to locate the "nginx" host? Lets try adding the
nginx container to the same network. Normally this would be done when creating
the container, but docker allows us to connect and disconnect anytime:

```
docker network connect web nginx
docker run -it --rm --net web nicolaka/netshoot curl -sSL http://nginx/
```

## Verify the Listening Ports

Using the same netshoot image, lets connect to the network namespace of nginx
and verify what interfaces and ports it is configured to listen on:

```
docker run -it --rm --net container:nginx nicolaka/netshoot netstat -lnt
```

You should see a local address of `0.0.0.0:80` indicating nginx is listening
on all interfaces, using port 80 inside the container.

## Network Aliases

Create a second nginx container with an alias matching the first container:

```
docker run -d --net web --name nginx2 \
 --network-alias nginx --network-alias nginx-us-east nginx
```

Now compare DNS lookups on the two names:

```
docker run -it --rm --net web nicolaka/netshoot nslookup nginx2
docker run -it --rm --net web nicolaka/netshoot nslookup nginx
docker run -it --rm --net web nicolaka/netshoot nslookup nginx-us-east
```

The DNS entry for nginx will show two containers. Run the same lookup several
times to see the IP addresses rotating in order.

Network aliases allow access to the same container with different names, or
round-robin access to multiple containers. It is atypical to run containers like
this, but it is often used by tools like compose when replicating multiple
instances of the same service as we will see later.

## Cleanup

To remove any containers that are still running, use:

```
docker container ls -aq | xargs docker container rm -f
```


