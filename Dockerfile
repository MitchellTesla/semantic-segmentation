FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

ARG git_owner="singnet"
ARG git_repo="semantic-segmentation"
ARG git_branch="master"

ENV SINGNET_DIR=/opt/singnet
ENV SERVICE_NAME=semantic-segmentation

RUN mkdir -p ${SINGNET_DIR}

RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:deadsnakes/ppa && \
      apt-get update && \
      apt-get upgrade -y && \
      apt-get install -y python3.6 python3.6-dev build-essential cmake libgtk2.0-dev python3.6-tk && \
      curl https://bootstrap.pypa.io/get-pip.py | python3.6

RUN apt-get update && \
    apt-get install -y \
    git \
    wget \
    nano \
    curl

# Install snet daemon
RUN SNETD_VERSION=`curl -s https://api.github.com/repos/singnet/snet-daemon/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")'` && \
    cd /tmp && \
    wget https://github.com/singnet/snet-daemon/releases/download/${SNETD_VERSION}/snet-daemon-${SNETD_VERSION}-linux-amd64.tar.gz && \
    tar -xvf snet-daemon-${SNETD_VERSION}-linux-amd64.tar.gz && \
    mv snet-daemon-${SNETD_VERSION}-linux-amd64/snetd /usr/bin/snetd

RUN cd ${SINGNET_DIR} && \
    git submodule update --init -- mask_rcnn && \
    git clone -b ${git_branch} https://github.com/${git_owner}/${git_repo}.git

RUN cd ${SINGNET_DIR}/${SERVICE_NAME} && \
    pip3.6 install -r requirements.txt && \
    sh buildproto.sh && \
    python3.6 fetch_models.py /caches/models

WORKDIR ${SINGNET_DIR}/${SERVICE_NAME}
