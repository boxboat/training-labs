# Labs: Volumes


If you don't have the training-labs directory from a previous lab, clone
it now:

```
cd
git clone https://github.com/boxboat/training-labs
```

## List the Volumes

Are there any volumes defined by default?

```
docker volume ls
```

## Create a Host Volume

**Note on Linux file permissions:**
If you are not familar with Linux file permissions, they appear as a string of
letters at the beginning of each line in a long directory listing (`-l` flag).
The first character indicates the type, `d` for a directory, and `-` for a
regular file. The next three characters are user permissions, followed by three
characters for group permissions, and finally three characters for all users.
Typical permissions are read (`r`), write (`w`), and execute (`x`). If a
permission is removed, there will be a `-` instead of a letter. So the
permission `-rwxr-x---` indicates a file with full access to the owner, no
write access for the group, and no access for everyone else. The user and
group of the file appears in the 3rd and 4th columns of the long listing.

First, create a directory and run a container with that directory mapped as
a host volume (note the `-u 1000:1000` tells docker to run the container with
uid and gid 1000, so the container is not running as root):

```
mkdir ${HOME}/data
cd ${HOME}/data
echo hello host >host.txt
ls -al data
docker container run -it --rm -u 1000:1000 -v "$(pwd):/data" busybox /bin/sh
```

Inside that container, try to view the contents of the directory. What happens
if you try to write to a file in the volume? What user are you inside the
container and what users have access to write to the directory?

```
ls -al /data
cat /data/host.txt
echo hello container >/data/container.txt
id # use this to check your uid
exit
```

Try running the container as root and writing to the file again:

```
docker container run -it --rm -v "$(pwd):/data" busybox /bin/sh
echo hello container >/data/container.txt
ls -al /data
exit
```

## Create a Named Volume

Try creating some volumes in different ways:

```
docker volume create by-hand
docker container run --rm -v dynamic:/data busybox ls -l /data
docker volume ls
```

What files were included in "dynamic" volume? Lets try manually loading some
content into the volume with a "utility container":

```
cd $HOME/training-labs/volume-example
ls -al data
tar -cC data . | docker container run -i --rm -v dynamic:/target busybox tar -xC /target
```

And then lets run the same container as before, but now with the volume
populated:

```
docker container run -it --rm -v dynamic:/data busybox /bin/sh
ls -al /data
echo hello container >/data/container.txt
exit
docker container run --rm -v dynamic:/data busybox ls -al /data
```

Did the data persist across multiple containers?

Backing up a volume can be done with IO redirection and tar similar to the
command to load content into a named volume above:

```
docker container run --rm -v dynamic:/source busybox tar -cC /source . >backup.tar
```

## Initialize a Named Volume From an Image

Take a look at the Dockerfile in the volume-example directory, then build
the image:

```
cd $HOME/training-labs/volume-example
cat Dockerfile
docker image build -t volume-ex:latest .
```

This image creates a user with uid 5000, defaults to using that user, and 
copies content to /image-data with that uid.

Without defining a volume, verify the contents of the image:

```
docker container run --rm volume-ex:latest ls -al /image-data
```

Now run a container with a volume defined:

```
docker container run -it --rm -v vol-ex-data:/image-data volume-ex
ls -l /image-data
echo hello container >/image-data/container.txt
exit
```

Did you have any errors creating files inside the container with the named
volume, even with the change of UID? Where did the initial contents of the
volume come from?

Run another container to verify your changes are still there:

```
docker container run --rm -v vol-ex-data:/image-data volume-ex ls -l /image-data
```

What happens if you mounted a different volume in that location?

```
docker container run --rm -v dynamic:/image-data volume-ex ls -l /image-data
```

Are the contents of the image visible when you mount the other volume?

## Create an Anonymous Volume

Where does docker store the volume defined below?

```
docker container run -v /image-data volume-ex ls -l /image-data
docker container run -v /data busybox touch /data/easily-lost.txt
```

Run the above command a few times. Then have a look at your volume list:

```
docker volume ls
```

If you have multiple anonymous volumes, how can you identify which belong to
each container, and which are safe to delete?

Try to inspect one of the anonymous volumes to see if there's anything to point
you back to the purpose (replace `${volume_name}` with an anonymous volume id):

```
docker volume inspect ${volume_name}
```

# Cleanup any leftover containers

```
docker container prune
```

