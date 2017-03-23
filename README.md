# Docker images

## Building the IncludeOS Docker images

```
$ docker build -t includeos/includeos-common:0.10.0.0 -f Dockerfile.common .
$ docker build -t includeos/includeos-build:0.10.0.0 -f Dockerfile.build .
```

## Using the Docker image to build your service

```
$ cd <my-super-cool-service>
$ mkdir build &6 cd build
$ docker run --rm -v $(dirname $PWD):/service includeos/includeos-build:0.10.0.0
```
