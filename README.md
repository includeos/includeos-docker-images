# Docker images

These Docker images let you try out building [IncludeOS](https://github.com/hioa-cs/IncludeOS/) unikernels without having to install the development environment locally on your machine.

## Building the IncludeOS Docker images

```
$ docker build -t includeos/includeos-common:v0.11.0-rc.2.01 -f Dockerfile.common .
$ docker build -t includeos/includeos-build:v0.11.0-rc.2.01 -f Dockerfile.build .
$ docker build -t includeos/includeos-qemu:v0.11.0-rc.2.01 -f Dockerfile.qemu .
$ docker build -t includeos/includeos-grubify:v0.11.0-rc.2.01 -f Dockerfile.grubify .
$ docker build -t includeos/includeos-webserver:v0.11.0-rc.2.01 -f Dockerfile.webserver .
```

## Using the Docker image to build your service

```
$ cd <my-super-cool-service>
$ mkdir build && cd build
$ docker run --rm -v $(dirname $PWD):/service includeos/includeos-build:v0.11.0-rc.2.01
```

## Running a very basic sanity test of your service image

Don't have a hypervisor installed? No problem? Run your service inside QEMU in a Docker container:

```
$ docker run --rm -v $(PWD):/service/build includeos/includeos-qemu:v0.11.0-rc.2.01 <image_name>
```

(If the service is not designed to exit on its own, the container must be stopped with `docker stop`.)

## Adding a GRUB bootloader to your service

On macOS, the `boot -g` option to add a GRUB bootloader is not available. Instead, you can use the `includeos-grubify` Docker image. Build your service, followed by:

```
$ docker run --rm --privileged -v $(dirname $PWD):/service includeos/includeos-grubify:v0.11.0-rc.2.01 /service/build/<image_name>
```

## Building a tiny web server

Do you have some web content that you would like to serve, without having to figure out arcane Apache configuration files? Just go to the folder where your web content is located and build a bootable web server:

```
docker run --rm -v $PWD:/public includeos/includeos-webserver:v0.11.0-rc.2.01
```
