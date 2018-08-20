# Labs: Compose

## Example Voting App

Lets try building and running Docker's example voting app:

```
cd
git clone https://github.com/docker/example-voting-app.git
cd example-voting-app
docker-compose up
```

The last command will not return a prompt. You will see it doing the following:

- Downloading base images for each of the microservices
- Building the image for each microservice
- Starting up multiple containers with the proper settings, volumes, and
  networking

You can review the code, and in particular the docker-compose.yml file at:
https://github.com/docker/example-voting-app

Consider all of the commands you would have needed to enter to build these
images, create the networks, and run these containers, including all of the
command line flags, which has been consolidated to a single "up" command with
the "docker-compose.yml" file. 

When it finishes starting the containers, you'll be able to reach the voting
app on port 5000 and the results on port 5001. In the play-with-docker
environment, these ports will appear as links at the top of the screen to the
right of the node IP address.

Without running the `docker-compose up` with the `-d` to detach, you'll need
to "control-c" to stop the project and get your prompt back.

Run the stack once more, but this time in the background:

```
docker-compose up -d
docker-compose ps
docker-compose logs
docker-compose down
docker-compose ps
```


