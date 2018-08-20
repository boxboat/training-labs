# Labs: Registry

## Start A Registry

This will run your own local registry server. It does not have any TLS
configured, and does not have any authorization, so this should only
be done in a lab:

```
cd
mkdir registry
docker image pull busybox:latest
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

## Pulling to a New Node

Add another host in the docker environment by clicking "+ Add New Instance" in
the web interface. From the node2 instance, first save the IP for node1.
Replace this IP with your own node1 IP address (check `hostname -i` on node1):

```
node1_ip=10.0.0.4
```

Now on node2, try pulling the image from the registry:

```
docker image pull ${node1_ip}:5000/busybox:latest
```

Docker will give you an error indicating that the server needs to be configured
with HTTPS (TLS). Why does this work for localhost? Check the docker engine's
configuration for registries:

```
docker info --format '{{.RegistryConfig.InsecureRegistryCIDRs}}'
```

Now that we are no longer talking to localhost, we need to configure TLS. Go 
back to node1 and clone the repo if you haven't already:

```
cd
git clone https://github.com/boxboat/training-labs
```

Then have a look at the registry example:

```
cd ~/training-labs/registry-example
cat docker-compose.yml
```

There are two services being created here, one is the registry server with some
TLS key settings. Lets remove the currently running registry server, create
the TLS certificates with openssl, and then start the new registry server:

```
docker container stop registry
docker container rm registry
./setup-certs.sh
docker-compose up -d
```

Since this is a new registry server, we need to push our image to it again:

```
docker image push localhost:5000/busybox:latest
```

Now return to node2 and try pulling the image again (adjust the IP to match
node1):

```
docker image pull ${node1_ip}:5000/busybox:latest
```

Did you get an error about the certificate being signed by an unknown 
authority? We created our own CA for this test, and we need to let docker
know it can trust that CA. Run the following on node2, adjusting the IP address
to match that of node1:

```
mkdir -p /etc/docker/certs.d/${node1_ip}\:5000
curl -sSL ${node1_ip}:5080/ca.pem >/etc/docker/certs.d/${node1_ip}\:5000/ca.crt
```

We used the nginx server running in the above compose file to host the CA
certificate, making it easy to copy to the other hosts. The 
`/etc/docker/certs.d` directory contains sub-directories for each registry
server you want to configure docker to trust, and needs to include the port
number in that directory name. The file inside each sub-directory needs to be
"ca.crt".

One last time, lets try pulling the image to node2:

```
docker image pull ${node1_ip}:5000/busybox:latest
```

## Push to Docker Hub

If you have time, login to Docker Hub, create a public repository, and try
tagging and pushing one of your images to that repository. Then try to
pull that same image to another node. The commands for that look like:

```
docker image tag busybox:latest ${your_user_id}/training:latest
docker login
docker image push ${your_user_id}/training:latest
```

and on another node:

```
docker image pull ${your_user_id}/training:latest
docker container run -it --rm ${your_user_id}/training:latest echo hello world
```

