# Labs: Swarm Part 1

## Create a Swarm Manager

On node1:

```
docker swarm init
```

If you have multiple network interfaces, you'll see an error directing you to
specify which interface to advertise. In the play-with-docker environment, that
looks like:

```
docker swarm init --advertise-addr eth0
```

## Create Swarm Workers

The "init" command above will output a command to run on other nodes to join
them to the swarm. Make sure you have three nodes using the "+ Add New
Instance" button in the play-with-docker interface (use alt-enter to exit full
screen if you've done that) and join them now. If you lose your join token, you
can show it again with:

```
docker swarm join-token worker
```

After running the join command on each of the new workers, try to run a swarm
command there:

```
docker node ls
```

Does the worker have access? Switch back to node 1 and run the same command on
the manager.

## Example Voting App

If you do not have the example voting app checked out from lab 8, do that now:

```
cd
git clone https://github.com/docker/example-voting-app.git
```

Lets run the same voting app from the compose example, but now in swarm mode:

```
cd $HOME/example-voting-app
docker stack deploy -c docker-stack.yml vote
```

View the progress of the app being deployed with:

```
docker stack ps vote
```

We can also list the services

```
docker service ls
```

## Updating the Service

There's only a single vote result replica, lets scale this up manually:

```
docker service update --replicas 2 vote_result
```

The development team has a new set of images for us to use. This will change
the voting options from cats and dogs to Java and .Net. Edit the
"docker-stack.yml" and change "before" to "after" in the "vote" and "result"
service image names. Once done, you can deploy the stack again with:

```
docker stack deploy -c docker-stack.yml vote
docker stack ps vote
```

Run the `stack ps` command until the changes have been applied. How many result
replicas are there now? Refresh the voting pages on ports 5000 and 5001 to see
the new options. If you have time, update your stack file to indicate the
desired number of replicas for the result service and redeploy the stack to
apply your change.

## Experience an Outage

Open the visualizer on port 8080, then switch to node 3 and delete the node.

What does docker do with the containers that were previously running on node 3?
Can you still access the voting app web pages?

Node 3 isn't going to come back, lets remove it from the swarm from node 1:

```
docker node rm node3
```

Create a new node to replace it, and join it to the swarm. Once done, check if
any continers have deployed to the new node 3. To force docker to rebalance
a replicated service, you can run:

```
docker service update --force vote_vote
```

## Cleanup

To delete the stack, run:

```
docker stack rm vote
```

