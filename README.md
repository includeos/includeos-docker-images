# Docker images

## Building the IncludeOS Docker images

```
$ docker build -t includeos/includeos-common:0.10.0.0 -f Dockerfile.common .
$ docker build -t includeos/includeos-build:0.10.0.0 -f Dockerfile.build .
$ docker build -t includeos/includeos-qemu:0.10.0.0 -f Dockerfile.qemu .
```

## Using the Docker image to build your service

```
$ cd <my-super-cool-service>
$ mkdir build &6 cd build
$ docker run --rm -v $(dirname $PWD):/service includeos/includeos-build:0.10.0.0
```

## Run a very basic sanity test of your service image

Don't have a hypervisor installed? No problem? Run your service inside QEMU in a Docker container:

```
$ docker run --rm -v $(PWD):/service/build includeos/includeos-qemu:0.10.0.0 <image_name>
```

(If the service is not designed to exit on its own, container must be stopped with `docker stop`.)
