# Labs: Run

## Error Resolution

The three "docker" commands below each have an error. Run the commands to
generate the error, and then see if you can correct the error:

```
mkdir "${HOME}/app data"
cd "${HOME}/app data"
touch hostdata.txt
VERSION=latest
docker container run --rm busybox -it echo success
docker container run --rm -v $(pwd):/data busybox ls -al /data
docker container run --rm 'busybox:${VERSION}' echo success
```

Many of these errors rely on understanding the Linux bash shell, if you get
stuck, continue on and we'll review after the lab.

## Namespaces

Compare each of these namespaces:

### PID

Compare the PID numbers inside and outside of the container for the same
process. Can containers see the host processes? Can the host see container
processes?

```
# start a container that will stay running in the background
docker container run -d --rm --name busytail busybox tail -f /dev/null
# can you see the container process on the host
ps -ef | grep tail
# does the pid match inside the container
docker container exec busytail ps -ef
# compare to all processes on the host
ps -ef
# cleanup
docker container rm -f busytail
```

What if we use the host namespace for PID? Can the container see the host
processes? (Note the `ps` pid will be different since you run the command
multiple times, and you will see additional container processes running while
the docker container is running.)

```
docker container run -it --rm --pid host busybox ps -ef
ps -ef
```

### User

Look back at the first PID example. What is the UID inside the container and
outside the container? Do they match?

### Network

Just like with the PID example but with networking commands:

```
# run a container with default namespacing, note the IP addresses and interfaces
docker container run -it --rm busybox ip a
# same command on the host
ip a
# same command in a container with the host network namespace
docker container run -it --rm --net host busybox ip a
```

### Filesystem

Just like with the PID example but with filesystem commands:

```
docker container run -it --rm busybox mount
mount
```

## CPU Resource Limits

Try running a pair of infinite loops and then compare their stats:

```
docker container run -d --rm --cpus 0.01 --name "1pct" busybox \
  /bin/sh -c "while :; do :; done"
docker container run -d --rm --cpus 0.05 --name "5pct" busybox \
  /bin/sh -c "while :; do :; done"
docker container stats --no-stream
docker rm -f 1pct 5pct
```

You can rerun the stats command a few times to see if it changes, or run
without the `--no-stream` flag to get a continuously updating display until
you cancel it with "control-c".

## Memory Resource Limits

**Note, this exercise should be skipped on the web based docker environment that
uses docker-in-docker. If you have docker on your laptop, see if you can get it
to work there.**

Now that you've seen how much memory the container needed, lets try limiting
that memory and also see what happens if we run a program that uses too much
memory:

```
docker container run -d --cpus 0.01 -m 4m --name "good" busybox \
  dd if=/dev/zero of=/dev/null bs=2M
docker container run -d --cpus 0.01 -m 4m --name "bad" busybox \
  dd if=/dev/zero of=/dev/null bs=10M
docker container stats --no-stream
```

The above "dd" command is holding several MB of "zeros" in memory before
writing them out to the /dev/null bit bucket. Each container will be limited to
1 percent of the CPU.

You may need to give the "bad" container a short bit to exhaust its memory
limit. Rerun the stats command until "bad" is no longer listed. Then inspect
the container state to see why the container exited:

```
docker container inspect --format '{{json .State}}' bad | jq .
docker container rm -f good bad
```

When a container is killed by docker's memory limit, rather than the OS itself,
you will see "OOMKilled" set to true in the state. If the entire docker host
runs out of memory, the Linux kernel will take action and kill the process,
which docker will interpret as your container abnormally exiting.



