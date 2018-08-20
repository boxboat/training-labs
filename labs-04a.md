# Labs: Build - Part 1

## Build a static binary

Clone the training repo:

```
cd
git clone https://github.com/boxboat/training-labs
cd training-labs/go-example
```

View the Dockerfile and hello.go. This is an extremely simple "hello world"
go image. Run a build:

```
docker image build -t my-hello:static .
```

Test this app out:

```
docker container run -it --rm my-hello:static
```

## Retag an Image

Lets tag the image with a version number instead of the generic "static" tag:

```
docker image tag my-hello:static my-hello:v1
```

## Updating an Image

Try editing the hello.go file and rerunning the container to see the image is
unchanged. Rebuild the image with another tag "my-hello:v2", and run the old and
new versions to see how easy it is to change between running versions.

View the history of your old and new images with:

```
docker image history my-hello:v1
docker image history my-hello:v2
```

Where do the layers diverge between the old and new images? Note that the newer
layers are shown at the top of the history. Compare the image id and creation
date for each line of the history.

## Compare the Images

```
docker image ls golang
docker image ls my-hello
```

Compare the image ID for the static and v1 images, they should be identical.
Compare the disk space between the golang base image we used and the resulting
my-hello image. This size is a sum of all the layers, so most of the disk space
is actually shared.

