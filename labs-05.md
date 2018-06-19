# Labs: Run

## Error Resolution

Each of the below docker commands has an error. Run the commands to generate
the error, and then see if you can correct the error:

```
mkdir "${HOME}/app data" && cd "${HOME}/app data"
docker container run --rm busybox -it echo hello world
docker container run --rm -v $(pwd):/data busybox ls -l /data
VERSION=latest
docker container run --rm 'busybox:${VERSION}'
```

After correcting each error, you'll be inside a docker container. Use `exit`
to stop the container before trying the next command.

## Namespaces

Compare each of these namespaces:

### PID

Compare the PID numbers inside and outside of the container for the same
process. Can containers see the host processes? Can the host see container
processes?

```
docker container run -d --rm --name tail busybox tail -f /dev/null
ps -ef | grep tail
docker container exec tail ps -ef
docker container rm -f tail
```

What if we use the host namespace for PID?

```
docker container run -it --rm --pid host busybox ps -ef
```

### User

Look back at the PID example. What is the UID inside the container and outside
the container? Do they match?

### Network

Just like with the PID example but with networking commands:

```
docker container run -it --rm busybox ip a
ip a
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



