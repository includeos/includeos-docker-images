# Docker images

## Building the IncludeOS Docker images

```
$ docker build -t includeos/includeos-common:0.10.0.0 -f Dockerfile.common .
$ docker build -t includeos/includeos-build:0.10.0.0 -f Dockerfile.build .
$ docker build -t includeos/includeos-qemu:0.10.0.0 -f Dockerfile.qemu .
$ docker build -t includeos/includeos-grubify:0.10.0.0 -f Dockerfile.grubify .
```

## Using the Docker image to build your service

```
$ cd <my-super-cool-service>
$ mkdir build &6 cd build
$ docker run --rm -v $(dirname $PWD):/service includeos/includeos-build:0.10.0.0
```

## Running a very basic sanity test of your service image

Don't have a hypervisor installed? No problem? Run your service inside QEMU in a Docker container:

```
$ docker run --rm -v $(PWD):/service/build includeos/includeos-qemu:0.10.0.0 <image_name>
```

(If the service is not designed to exit on its own, the container must be stopped with `docker stop`.)

## Adding a GRUB bootloader to your service

On macOS, the `boot -g` option to add a GRUB bootloader is not available. Instead, you can use the `includeos-grubify` Docker image. Build your service, followed by:

```
$ docker run --rm --privileged -v $(dirname $PWD):/service includeos/includeos-grubify:0.10.0.0 /service/build/<image_name>
```
