FROM ubuntu:xenial as base

RUN apt-get update && apt-get -y install \
    git \
    lsb-release \
    net-tools \
    wget \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Triggers new build if there are changes to head
ADD https://api.github.com/repos/hioa-cs/IncludeOS/git/refs/heads/dev version.json

# TAG can be specified when building with --build-arg TAG=...
ARG TAG=v0.12.0-rc.3
RUN echo "cloning $TAG"
RUN cd ~ && pwd && \
  git clone https://github.com/hioa-cs/IncludeOS.git && \
  cd IncludeOS && \
  git checkout $TAG && \
  git submodule update --init --recursive && \
  git fetch --tags

RUN cd ~ && pwd && \
  cd IncludeOS && \
  ./install.sh -n

###########################
FROM ubuntu:xenial as build

RUN apt-get update && apt-get -y install \
    clang-5.0 \
    cmake \
    nasm \
    curl \
    python-pip \
    && rm -rf /var/lib/apt/lists/* \
    && pip install pystache antlr4-python2-runtime

# Add fixuid to change permissions for bind-mounts. Set uid to same as host with -u <uid>:<guid>
RUN addgroup --gid 1000 docker && \
    adduser --uid 1000 --ingroup docker --home /home/docker --shell /bin/sh --disabled-password --gecos "" docker
RUN USER=docker && \
    GROUP=docker && \
    curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.3/fixuid-0.3-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

COPY --from=base /usr/local/includeos /usr/local/includeos/
COPY --from=base /root/IncludeOS/etc/install_dependencies_linux.sh .
COPY entrypoint.sh .
ENTRYPOINT ["/entrypoint.sh"]

WORKDIR /service
CMD mkdir -p build && \
  cd build && \
  cp $(find /usr/local/includeos -name chainloader) /service/build/chainloader && \
  cmake .. && \
  make

#############################
FROM ubuntu:xenial as grubify

RUN apt-get update && apt-get -y install \
  dosfstools \
  grub-pc \
  curl \
  sudo

COPY --from=base /usr/local/includeos/scripts/grubify.sh /home/ubuntu/IncludeOS_install/includeos/scripts/grubify.sh

RUN addgroup --gid 1000 docker && \
    adduser --uid 1000 --ingroup docker --home /home/docker --shell /bin/sh --disabled-password --gecos "" docker && \
    usermod -aG sudo docker && \
    sed -i.bkp -e \
      's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
      /etc/sudoers

RUN USER=docker && \
    GROUP=docker && \
    curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.3/fixuid-0.3-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

WORKDIR /service
ENTRYPOINT ["fixuid", "/home/ubuntu/IncludeOS_install/includeos/scripts/grubify.sh"]
