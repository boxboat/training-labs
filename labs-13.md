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

## Build a Java Spring Boot App

Switch to the java-example directory and review the project from the Spring
Boot project:

```
cd $HOME/training-labs/java-example
```

*Note: If you get stumped, there is a training-labs/answers/java directory
with the final files from the lab. See how far you can get before looking up
the answers there.*

They have a Dockerfile but need help with the following:

- Avoid creating anonymous volumes every time the container is run
- Use a multi-stage build to create the jar in a jdk stage, and run in another
- Ignore changes to anything but the src directory and pom.xml

After discussing with the developers, they have the following requirements:

- Build using the `openjdk:8-jdk-alpine` image. If possible, they'd like to be
  able to easily change versions of the base images.
- To build the app, they want to use Maven. This isn't installed in the jdk
  image, but the following command will add it in Alpine:
  `apk add --no-cache maven`
- To build the app with maven, the developers want to run the following:
  `mvn package -Dmaven.test.skip=true`
- Maven will output a jar file in: `target/gs-spring-boot-docker-0.1.0.jar`
- To run the final container, they want to use the `openjdk:8-jre-alpine`
  image.
- The final build image should be named `springboot-ex:latest`.

*Get an image to build from the above requirements before continuing.*

Unfortunately the developers have left for their lunchbreak and forgot to tell
you what port their application should be listening on. Try starting up the
container in the background (`-d`), and then attach a second container to the
same network namespace. Use the `nicolaka/netshoot` image for this to run the
command `netstat -lnt` to show the listening ports. Once you know the ports 
being used, document this in the Dockerfile with an `EXPOSE` line.

Make the developers life easier to including a docker-compose.yml. It should
have the following:

- Use at least version "3.6" for the syntax.
  - You may need to upgrade docker-compose to support this file version. Use
    `pip install docker-compose==1.22.0` to upgrade to the 1.22.0 release.
- Specify the image name, the CI server will be building the image for us,
  so no need to specify the build command in the docker-compose.yml, but you
  could make a `build.sh` script for the developers local machine.
- Configure `/tmp` as a "tmpfs" volume.
- Publish the port we exposed earlier.

Try making some changes to the `src/main/java/hello/Application.java` file
and verify that the changes are visible when rebuilding and deploying
a new container.

*Finish the above before continuing.*

The developers are concerned about how long the builds are
taking when they only have minor source code changes. They want to run
`mvn dependency:go-offline` which only depends on the `pom.xml` file to
download all of the dependencies. This can be run before the package command.
See if you can find a way to speed up the builds, and if possible, give the
CI team a way to download a new cache every day.


