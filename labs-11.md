# Labs: Security

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



