# ATG CRS Database Quickstart

This guide describes how to create a dockerized Oracle Database 12.2.0.1 for use with ATG CRS.

## Download Oracle Database 12c Release 2 (12.2.0.1.0) - Standard Edition 2 and Enterprise Edition

- Go to [Oracle Database Software Downloads](http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index-092322.html)
- Accept the license agreement
- In the section "(12.2.0.1.0) - Standard Edition 2 and Enterprise Edition" download the "Linux x86-64" file (File 1 - 3.2 GB)

## Download Oracle SQL Developer

You will also need a way to connect to the database.  I recommend [Oracle SQL Developer](http://www.oracle.com/technetwork/developer-tools/sql-developer/downloads/index.html).

## Clone the Oracle "docker-images" repo

Clone the [Oracle docker-images repository](https://github.com/oracle/docker-images).  This is a repository maintained by Oracle that allows you to build your own Oracle Database docker images.

## Build the database image

This process creates a docker image that knows how to initialize the oracle database the first time it starts up.  You need to change into the 12.2.0.1 build directory in the oracle docker-images project and move your Oracle Database 12.2.0.1 installer into that directory.  Then run the Enterprise Edition build:

```
$ cd .../docker-images/OracleDatabase/dockerfiles/12.2.0.1
$ mv <your download dir>/linuxx64_12201_database.zip .
$ docker build -f Dockerfile.ee -t oracle/database:12.2.0.1-ee . 
```

That should produce the docker image oracle/database with a tag of 12.2.0.1-ee:

```
$ docker images
REPOSITORY                    TAG                 IMAGE ID            CREATED              SIZE
oracle/database               12.2.0.1-ee         c0b06d4c2527        About a minute ago   13.3GB
```

Yes, it's 13 gigs, and no, you can't make it any smaller.

## Run a container based on the image you just built

Now it's time to run your own personal container with the database in it. This process will continue the setup process where the installation process in the previous step left off. 

Change back into the project directory where this README is located.  When you run the container, docker mounts this directory into the container's filesystem at a location where the oracle setup scripts know to look for initialization scripts of type *.sql and *.sh.  Those scripts are run to 1) create the crs schemas and 2) import the crs data into those schemas.  This process is only run once when the container is created.  Stopping/starting the container only starts and stops the database.  The command below starts the container in the foreground.  If you want to run it as a daemon, add `-d -it` to the docker command.

```
$ cd .../Atg11Demo/db12c
$ docker run --name <an easy to remember container name, e.g. 'crsdb'> \
-p 1521:1521 -p 5500:5500 \
-e ORACLE_PWD=<your preferred password here> \
-v <full path to Atg11Demo project directory>/Atg11Demo/scripts/db12c:/opt/oracle/scripts/setup \
oracle/database:12.2.0.1-ee
```

You should see the database files being copied.  Towards the end, you should see:

```
Executing user defined scripts
/opt/oracle/runUserScripts.sh: running /opt/oracle/scripts/setup/01_create_users.sql

... (lots of output) ...

DONE: Executing user defined scripts

The Oracle base remains unchanged with value /opt/oracle
#########################
DATABASE IS READY TO USE!
#########################
```

## Test your connection

Using SQLDeveloper, create a connection to the database:

```
username: system
password: <the password you specified in 'docker run'>
hostname: localhost
port: 1521
SID: ORCLCDB 
```

Upon successful connection, run the following SQL:

```
select * from C##CRS_CATA.DCS_SKU;
```

You should see a bunch of CRS skus.  The database is now ready for connections from an ATG CRS installation.

## Stopping and starting your container

If you've been following this guide to the letter, your docker container should be running in the foreground. Press control-C to stop it.  When it stops you can verify that it's not running by doing:

```
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
$ 
```

You can see your stopped container:

```
$ docker ps -a
CONTAINER ID        IMAGE                         COMMAND                  CREATED             STATUS                           PORTS   NAMES
<some hash>        oracle/database:12.2.0.1-ee   "/bin/sh -c 'exec $O…"   22 minutes ago      Exited (130) About a minute ago          crsdb
```

Because you gave your container a name (you did, didn't you?) you can easily restart it:

```
$ docker start crsdb
crsdb
$ docker logs -f crsdb

... (contents of logfile) ...

```

And bring it down again with:

```
$ docker stop crsdb
crsdb
$
```
