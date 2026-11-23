FROM cyberbotics/webots:R2020b-ubuntu20.04
ENV DEBIAN_FRONTEND=noninteractive

# Image contains old cache entries that break updates
RUN rm -f /etc/apt/sources.list.d/cuda*.list /etc/apt/sources.list.d/nvidia-ml.list
RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    ca-certificates \
    ssh \
    git \
    xz-utils \
    unzip \
    gdb \
    make \
    cmake \
    pkg-config \
    valgrind \
    graphviz \
    doxygen \
    curl \
    build-essential \
    python3 python3-pip \
    gnat gprbuild
RUN rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 983 hostgroup

COPY alr /usr/local/bin/alr
ENV PATH="/root/.alire/bin:${PATH}"
RUN alr toolchain --select gnat_external gprbuild

ENV DEBIAN_FRONTEND=

WORKDIR /workspace