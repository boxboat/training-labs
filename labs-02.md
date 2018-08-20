# Labs: Managing Containers

## List the Images

```
docker image ls
```

What images are already on the docker host? These were automatically pulled
from previous `docker container run` commands.

## Pull Another Image

```
docker image pull busybox:latest
```

What would have happened if we left off the ":latest" tag?

## List Only The Pulled Image

```
docker image ls busybox:latest
```

## Formatting the Output

```
docker image ls --format 'table {{.ID}}\t{{.Size}}'
```

## Start a Container in the Background

```
docker container run -d nginx
```

## List Containers

```
docker container ls
```

That shows the "nginx", but what if we also show stopped containers:

```
docker container ls -a
```

## Restart a Container

Find the older "centos" container that's been stopped above, and restart it
(note that newer containers are at the top of the list):

```
docker container restart ${container_id}
```

See if you can find the "/demo.txt" file that we created in the last lab:

```
docker container exec ${container_id} ls -l /
```

## View Container Logs

```
docker container logs ${container_id}
```

You should see the output from when the container was run, but not the commands
that launched with `docker container exec`.

What if we had lots of logs? Lets start a container that will generate
lots of lines of output:

```
docker container run -d --name pinger busybox ping 8.8.8.8
```

Let it run for 5 seconds, and then run:

```
docker container logs --since 5s pinger
```

Notice how we used a container name to avoid needing to lookup the id.

## Cleanup

First, verify that your container is running:

```
docker container ls
```

Now stop any running containers:

```
docker container stop ${container_id}
```

This may take 10 seconds, why?

Now delete each of the exited containers:

```
docker container rm ${container_id}
```



