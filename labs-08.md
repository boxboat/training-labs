# Labs: Compose

## Example Voting App

Lets try building and running Docker's example voting app:

```
cd
git clone https://github.com/docker/example-voting-app.git
cd example-voting-app
docker-compose up
```

Once it's finished starting, you should be able to click the link to port
5000 to cast your vote, and view the voting results on port 5001.

Without running the `docker-compose up` with the `-d` to detach, you'll need
to "control-c" to stop the project and get your prompt back.

Review the docker-compose.yml file. This application consists of mulitple
networks, volumes attached to several of the containers, and applications
running different languages or programs, all talking to each other. Consider
all of the `docker container run` commands and arguments needed to recreate
what the one `docker-compose up` did.

Run the stack once more, but this time in the background:

```
docker-compose up -d
docker-compose ps
docker-compose logs
docker-compose down
docker-compose ps
```


