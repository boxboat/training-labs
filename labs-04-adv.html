# Labs: Advanced Build

## Examine your build context

Change to a directory with some content and run the following:

```
docker image build -t test-context -f - . <<EOF
FROM busybox
COPY . /build-context
WORKDIR /build-context
CMD find .
EOF
```

Run the image to see the result:

```
docker container run --rm test-context:latest
```

Try configuring a `.dockerignore` file to exclude some content from the
directory from being added to the image.

Try making the lines above into a Dockerfile with a different name to avoid
impacting other docker builds, and exclude this Dockerfile from being added
to your build. What command do you need to run to do the build now?

## Build a Python App

Build the example python application. If you haven't already cloned the
labs repo into your Docker environment, you can do that with:

```
cd
git clone https://github.com/boxboat/training-labs
```

Run the build:

```
cd training-labs/python-example
docker image build -t python-app:dev .
```

Start the container:

```
docker container run -d --name python-app -p 9000:80 python-app:dev
```

Hit the URL on the web page or run a "curl" command to verify it works:

```
curl http://127.0.0.1:9000/
```

Edit the python app (app.py), changing the welcome message and reload the page
(or rerun the curl). Did the message change? Why not? Does it work if you 
restart the container?

```
docker container restart python-app
```

Run a second container with a host volume mount to see how that lets us develop:

```
docker container run -d --name python-app2 -p 9001:80 -v "$(pwd):/usr/src/app" python-app:dev
```

Did that pickup the change? What happens if you make further changes to the
app.py file? For checking this container, make sure you are using port 9001:

```
curl http://127.0.0.1:9001/
```

Cleanup the containers when done:

```
docker container rm -f python-app python-app2
```


