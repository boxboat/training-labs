# Labs: Container Intro

## Hello World

Start your own lab environment and run the following:

```
docker container run hello-world
```

## Run an Interactive Container

Start a container based on the debian image:

```
docker container run -it debian
```

What kernel is this image using?

```
uname -v
```

Check for other signs of the OS:

```
cat /etc/debian_version
apt --version
```

Exit the container and compare the kernel to the docker host:

```
exit
uname -v
```

Lets try another base image:

```
docker container run -it centos
```

Compare versions in this container to the debian container:

```
uname -v
cat /etc/debian_version
apt --version
```

Notice that the Debian commands and paths don't work, lets try the CentOS
equivalents:

```
cat /etc/redhat-release
yum --version
```

Create a sample file:

```
touch /demo.txt
ls -l /demo.txt
```

Exit the container and restart from the same image:

```
exit
docker container run -it centos
ls -l /demo.txt
exit
```

Notice how the container restarts from a clean state each time.



