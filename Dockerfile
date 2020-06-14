FROM ubuntu:20.04

ARG USERNAME=dev
ARG PUID=1000
ARG PGID=1000
ARG MACHINE=imx6dl-riotboard
ARG DISTRO=fslc-xwayland
ARG HTTP_FILE_PORT_INTERNAL=8080
ARG HTTP_FILE_PORT_EXTERNAL=8080
ARG HTTP_HOSTNAME_INTERNAL=0.0.0.0
ARG HTTP_HOSTNAME_EXTERNAL=127.0.0.1
ARG BUILD_LOG="build_log_"
ARG DEBIAN_FRONTEND=noninteractive
ARG BUILD_NXP_BSP=0
ARG BUILD_NXP_BSP_BRANCH=master
ARG BUILD_NXP_IMAGE=0

ENV TZ=Europe/London

RUN apt-get update && apt-get install -y tzdata gawk wget git-core diffstat unzip \
            texinfo gcc-multilib build-essential chrpath socat cpio python \
            python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping \
            python3-git xterm locales \
            vim bash-completion screen qemu-user-static qemu-utils kpartx curl nodejs npm xz-utils

RUN groupadd -g ${PGID} ${USERNAME} \
            && useradd -u ${PUID} -g ${USERNAME} -d /home/${USERNAME} ${USERNAME} \
            && mkdir -p /home/${USERNAME} \
            && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}

RUN locale-gen en_US.UTF-8

ENV LANG en_US.UTF-8
ENV MACHINE ${MACHINE}
ENV DISTRO ${DISTRO}
ENV USERNAME ${USERNAME}
ENV HTTP_FILE_PORT_INTERNAL ${HTTP_FILE_PORT_INTERNAL}
ENV HTTP_FILE_PORT_EXTERNAL ${HTTP_FILE_PORT_EXTERNAL}
ENV HTTP_HOSTNAME_INTERNAL ${HTTP_HOSTNAME_INTERNAL}
ENV HTTP_HOSTNAME_EXTERNAL ${HTTP_HOSTNAME_EXTERNAL}
ENV BUILD_LOG ${BUILD_LOG}
ENV BUILD_NXP_BSP ${BUILD_NXP_BSP}
ENV BUILD_NXP_IMAGE ${BUILD_NXP_IMAGE}
ENV BUILD_NXP_BSP_BRANCH ${BUILD_NXP_BSP_BRANCH}

ADD scripts /home/${USERNAME}
COPY ./scripts/bashrc /home/${USERNAME}/.bashrc
RUN chmod 777 /home/${USERNAME}/*

EXPOSE ${HTTP_FILE_PORT_INTERNAL}
RUN npm cache clean -f
RUN npm install -g n
RUN n stable
RUN npm install http-server -g

USER ${USERNAME}
WORKDIR /home/${USERNAME}

ENTRYPOINT ["/home/dev/docker-entrypoint.sh"]
CMD ["/home/dev/run_build_steps.sh"]

