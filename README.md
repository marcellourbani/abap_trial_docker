# SAP netweaver docker image scripts

These scripts create a SAP NetWeaver ABAP Developer Edition Docker image, and allow you to run it in a container

A docker image is a blueprint for a container, which is a self contained application. It looks like a dedicated virtual machine but it's not, and uses much less resources compared to a VM like this excellent [Vagrant script by
Alexander Tsybulsky](https://github.com/sbcgua/sap-nw-abap-vagrant)

Tested on linux (arch). Once an image is created should be possible to run it in

This is heavily based on [Jakub Filak's Dockerfile](https://github.com/filak-sap/sap-nw-abap-docker), which didn't work out of the box on my arch box

## Requirements

For the installation:

- a linux machine or VM for the build process, with Docker installed
- enough map areas
  SAP needs 1000000, where the default is 65365. This must be set on the system, either by running

  ```bash
  sudo sysctl -w vm.max_map_count=1000000
  ```

  or, better, by adding setting vm.max_map_count=1000000 to your config file (depends on your linux distribution I use /etc/sysctl.d/99-sysctl.conf on arch linux, could also create a new file only dor that , say /etc/sysctl.d/98-abap.conf )

- lots of disk space. Once installed it should take around 80 Gb (46 for the image, a bit less for the container) but during the build it can require more than 100
- a decent amount of free RAM, say 4 gb

For running the container:

- a Docker system (linux is probably best, but should work on )
- enough map areas (see above)
- some spare RAM. Not sure how much, I guess between 2 and 4 Gb. When idle this uses about 2.5 Gb, but I expect this to increase when you run stuff

## Installation

- Download the installation files
  - Go to the [SAP trials download page](https://developers.sap.com/trials-downloads.html)
  - search for "7.52 SP04"
  - accept the licence and download the 11 rar archives
  - extract them in folder ABAP_Trial
- run script createimage (this will take several minutes):

  ```bash
  sudo ./createimage
  ```

- if everything works fine, you will end up with a docker image **abapdevedition**
- start a container again this will take a while to start as it will copy the whole database from the image

  ```bash
  sudo ./runcontainer
  ```

Yor new container will be called abaptrial, and will map the required ports to your local system ports. From here you can continue as any other [AS ABAP installation](https://blogs.sap.com/2017/09/04/newbies-guide-installing-abap-as-751-sp02-on-linux) from point E

## Usage

To connect to your new SAP instance

- SAPGui: open saplogon and create a new server connection with:
  - Application server: your docker server IP address
  - System number 00
  - SID NPL
- Eclipse: use the connection defined in saplogon
- Visual studio code: Create a connection like this in your configuration file:

  ```JSON
  "abapfs.remote": {
    "NPL": {
      "url": "https://myserverIP:44300",
      "username": "developer",
      "password": "",
      "client": "001",
      "allowSelfSigned": true
    }
  }
  ```

## Management

- start the instance

  ```bash
  sudo docker start abaptrial
  ```

- stop the instance (will try to do it nicely by stopping the server, and then kill it after 20 minutes)

  ```bash
  sudo docker stop abaptrial
  ```

- delete the container (warning, **all the data will be lost**)

  ```bash
  sudo docker rm abaptrial
  ```

- check the start/stop logs (as they are generated)

  ```bash
  sudo docker logs -f abaptrial
  ```

  Press Ctrl+C to stop watching them

## Technical details

This works by creating a temporary image, then running a container to install AS ABAP and save the final image

This is not idedeal, we would want a Dockerfile to do all the work in one stage, but mixes poorly with SAP installation process:

- Docker sets a dynamic hostname at start
- The installer wants a stable hostname and domain

Jakub Filak handles this with a custom library that allows mocking the hostname. I do it by setting the hostname and domainat installation/container start patching the configuration files at startup

This allows to put the installation files in a volume which speeds up the installation process (the total time is probably longer for this one, but it usually fails faster) and should end up in a slimmer image without the installation files
As the whole process is scripted, I don't think this si a big deal

Also, I start the process using [catatonit](https://github.com/openSUSE/catatonit), which allows to run an unprivileged container
