# Labs: Swarm Part 2

## Deploy A Cluster With Four Workers

If you have not already, initialize the swarm on node1 of the cluster:

```
docker swarm init --advertise-addr eth0
```

In case the last join token got compromised by a nosey neighbor, lets rotate
the join token for the worker:

```
docker swarm join-token --rotate worker
```

Create four worker nodes in addition to the one manager on node1. This should
leave you with node1 - node5. To create each worker node, first press "+ Add
New Instance" and then past the join command from node1 to nodes 2-5. When
finished, on node1, run:

```
docker node ls
```

And verify you have 1 manager and 4 worker nodes.

## Label the Workers

Set the following labels on each node:

- node2: type=web, region=east
- node3: type=web, region=east
- node4: type=web, region=west
- node5: type=compute, region=west

To set a label, use:

```
docker node update --label-add key=value nodex
```

which would add a label named "key" with value "value" to the node "nodex".

## Configure a Compose File for a Multi-node Swarm Cluster

*If at any point you get stuck in this section, there is an answer key in
[`$HOME/training-labs/answers/swarm`](answers/swarm/).*

Documentation for the compose file format is at:
https://docs.docker.com/compose/compose-file

The development team has created a compose file for their project that works
on a single node, and they now need to scale it up to run in the multi-node
development cluster. If you haven't already checkout the training repo and then
cd to their project:

```
cd
git clone https://github.com/boxboat/training-labs
cd training-labs/swarm-example
```

To deploy their project, they use `./create_config.sh` to setup an external
config, and `./deploy.sh` to start up the stack with an environment variable
setup. This is normally done for them by the CI server.

They need the following changes, many of which can be achieved with entries
in the deploy section of the compose file:

- Traefik, Index, and Visualizer:
  - Only run this on the manager
  - Configure it to start a new instance and wait 60 seconds before stopping
    the old instance
- Nginx:
  - Deploy 6 replicas
  - Configure it to start a new instance and wait 60 seconds before stopping
    the old instance
  - Update 2 instances at a time
  - Only run on the type "web" nodes that we labeled above
  - Spread the containers across multiple regions evenly using the labels set
    above
- Caddy:
  - Deploy 2 replicas to the web nodes in the west region
  - Setup a healthcheck that runs the followning every 60 seconds, with a
    10 second timeout, 10 second startup grace window, and 2 retries on any
    failures:
    ```
    wget -O - -q http://localhost:2015 || exit 1
    ```
- Compute:
  - This is a new service that needs to run the following command in a busybox
    image:
    ```
    /bin/sh -c "while :; do :; done"
    ```
  - Schedule it to run globally, on all nodes with the compute label
  - Configure a CPU resource limit of "0.01" and a memory limit of "10M"
  - Run this service on a new network called "compute" and make that network
    attachable

After making the above changes and deploying your stack, review the containers
in the visualizer to see if they have been correctly scheduled.

# Update a Config

The default index page looks pretty bland. Update the page content (in
index.html) and try to redeploy the stack. You should see an error telling
you it's not possible to change a config (it's immutable). How can you
get your change to apply to the service?

# Rolling Updates

On a worker node, run the following and leave it up for this section (you can
stop it at the end with a control-c):

```
while true; do timeout -t 5 curl -sSL http://127.0.0.1:8888/nginx/config.txt; sleep 5; done
```

Now that you've figured out how to reconfigure the index service with a new
config, make an update to web_config.txt and update the web services to use
this new config. Since this config is externally deployed, you'll need to 
update and rerun `create_config.sh` in addition to updating the compose file
for your change.

After you start the deploy of your change, you should see a rolling update
occur. While the rolling update is running, review the output of
`docker stack ps dev` and the curl command above to see the progress of the
rolling update.

# Reconfigure a Node

The web team feels they have more than enough capacity on the east region and   
have asked to reprovision node3 to be a compute node. Update the label on this
node and observe how that impacts running containers.

# Run an Ad-hoc Container on an Overlay Network

Which of the below commands is successful and why?

```
docker run -it --rm busybox ping -c 1 nginx
docker run -it --rm --net dev_default busybox ping -c 1 nginx
docker run -it --rm --net dev_compute busybox ping -c 1 compute
```

# Promote

Two additional managers are needed for a HA configuration. Promote the two
compute nodes to manager status:

```
docker node promote node3
docker node promote node5
```

Verify you can run management commands like `docker node ls` on each of your
manager nodes.

# Drain, Reconfigure, and Activate a Node

The west coast data center is performing some maintenance. Drain these nodes
in advance of the maintenance:

```
docker node update --availability=drain node4
docker node update --availability=drain node5
```

Verfiy with the visualizer that containers have stopped and migrated off of
these nodes where appropriate. It would now be safe to perform the maintenance.
Once done, you can bring the nodes back into service with:

```
docker node update --availability=active node4
docker node update --availability=active node5
```

Notice which containers get rescheduled and which ones remain running on their
current nodes. For the containers that did not automatically move back to the
available nodes, rebalance the service to force containers to be deployed.

# Stop a Service

The caddy project has an issue and needs to be stopped. Perform the following 
to stop all containers in the service:

```
docker service update --replicas 0 dev_caddy
```

While the caddy service is stopped, deploy the full stack again. Does caddy
remain stopped? How could you more permanently stop caddy?

# Cleanup

You can remove the stack with:

```
docker stack rm dev
```

