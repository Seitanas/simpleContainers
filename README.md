# simpleContainers
  
Script is designed to simplify creation and upgrade of Docker containers.

Upgrade process deletes old container and runs new one from updated image, so you will have to upgrade one source image instead of many containers.  
Upgrade process preserves port mapping and persistent storage configuration.

### installation
***simpleContainers requires python3***

    git clone https://github.com/Seitanas/simpleContainers
    pip install docker
  
### creating new container

First you need to create image with a software you need and commit it to image store:

    docker ps -a
    
    CONTAINER ID        IMAGE               COMMAND             CREATED               STATUS              PORTS               NAMES
    12f4b15fd3a0        debian:stretch      "/bin/bash"         15 minutes ago      Up 15 minutes                           awesomeserver_source


    docker commit 12f4b15fd3a0 awesomeserver:current
    docker images
    
    REPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
    awesomeserver       current             5e14bd7a37ec        About a minute ago   272 MB
    debian              stretch             bbcfe8e14329        12 days ago          100 MB

Now we will build a production server image (this image will be used to fire containers).  
Edit `Dockerfile` to fit your needs.  

    docker build -t awesomeserver:prod .
    docker images
    
    REPOSITORY          TAG                 IMAGE ID            CREATED                 SIZE
    awesomeserver       prod                6ad63a1d277f        15 seconds ago         272 MB
    awesomeserver       current             5e14bd7a37ec        4 minutes ago       272 MB
    debian              stretch             bbcfe8e14329        12 days ago         100 MB

Let's fire up one container:

    ./simpleContainers --action=create -n test1 -p 127.0.0.1:12000:80 -v /etc/awesomeserver -i awesomeserver:prod

    docker ps -a
    
    CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS              PORTS                     NAMES
    bb61783696a3        awesomeserver:prod   "/bin/sh -c '/usr/..."   7 seconds ago       Up 6 seconds        127.0.0.1:12000->80/tcp   test1
    
This will create a container, named `test1` from image `awesomeserver:prod` with persisetent storage, named `test`, which will be mapped in container on `/etc/awesomeserver`.
Machine with a running web server should be accessible from host on port 12000. For machine to be accessible on all host IPs, remove `127.0.0.1:` when creating container.


### upgrading container

After committing new, modified image to local store, run:

    docker build -t awesomeserver:prod .
     ./simpleContainers --single --action=upgrade --name=test1
 
 This will remove old container, and fire up new one from updated image.
 Upgrade process without `--single` argument will treat container name with wild-card on the end (test1*) and update all containers with matching name.


### available arguments

    Usage: simpleContainers COMMAND
    
      -a --action=    Choose action for a container (create, upgrade)
      -c --command=   Runs command on container startup
      -h              Prints help
      -i --image=     (required for creating new container) Image name to start container from
      -n --name=      (required) Specify name of container. Will use wildcard in the end of name for upgrade action
      -s --single     used together with --upgrade. Will upgrade only first container which matches --name
      -p --portmap=   Specify ports to be mapped from host to container ([HOSTADDR:]HOSTPORT:CONTAINERPORT)
      -v --volume=    If specified, SimpleContainers will create named volume and mount it inside container
                  on [-v]--volume path. 


