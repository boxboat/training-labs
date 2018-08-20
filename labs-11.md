# Labs: Security

## Namespaces

Containers run processes different namespaces. We've already seen filesystem
and network namespaces. Lets look at the PID namespace:

```
docker container run --name pinger -d busybox ping 8.8.8.8
ps -ef | grep ping
docker container exec pinger ps -ef
```

If you get an error about "pinger" already being used, stop and remove
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

Did any of these commands work (other than exit)? Reboot may not give you an
error, but you'll notice if you reboot the server.

## Read Only Filesystem

Try creating a container with a read-only root filesystem, and a data directory
that is a tmpfs:

```
docker container run -it --rm --read-only --tmpfs /data:noexec,nosuid busybox
```

From inside the container, try to create a new command in /bin or delete an
existing command. Also check if /data lets you store malicious binaries:

```
touch /bin/evilcmd
rm /bin/mount
cp /bin/ls /data/evilcmd
/data/evilcmd
ls -al /data
```



