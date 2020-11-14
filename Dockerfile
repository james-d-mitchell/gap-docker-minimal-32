FROM i386/ubuntu:bionic

ENV GAP_VERSION 4.10.2

MAINTAINER James D. Mitchell <jdm3@st-andrews.ac.uk>

RUN    dpkg --add-architecture i386 \
    && apt-get update -qq \
    && apt-get -qq install -y autoconf build-essential m4 libreadline6-dev libncurses5-dev wget \
                              unzip libgmp3-dev cmake gcc-multilib gcc g++ sudo

RUN    adduser --quiet --shell /bin/bash --gecos "GAP user,101,," --disabled-password gap \
    && adduser gap sudo \
    && chown -R gap:gap /home/gap/ \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && cd /home/gap \
    && touch .sudo_as_admin_successful

RUN    mkdir -p /home/gap/inst \
    && cd /home/gap/inst \
    && wget https://www.gap-system.org/pub/gap/gap4core/gap-${GAP_VERSION}-core.zip \
    && unzip gap-${GAP_VERSION}-core.zip \
    && rm gap-${GAP_VERSION}-core.zip \
    && cd gap-${GAP_VERSION} \
    && wget https://www.gap-system.org/Manuals/gap-${GAP_VERSION}-manuals.tar.gz \
    && tar xvzf gap-${GAP_VERSION}-manuals.tar.gz \
    && rm gap-${GAP_VERSION}-manuals.tar.gz \
    && ./configure ABI=32 --with-gmp=system \
    && make \
    && cp bin/gap.sh bin/gap \
    && make bootstrap-pkg-minimal \
    && rm packages-*.tar.gz \
    && chown -R gap:gap /home/gap/inst \
    && wget https://github.com/gap-packages/PackageManager/archive/v1.1.tar.gz \
    && tar xvzf v1.1.tar.gz \
    && rm v1.1.tar.gz \
    && mv PackageManager-1.1 /home/gap/inst/gap-${GAP_VERSION}/pkg 

# Set up new user and home directory in environment.
# Note that WORKDIR will not expand environment variables in docker versions < 1.3.1.
# See docker issue 2637: https://github.com/docker/docker/issues/2637
USER gap
ENV HOME /home/gap
ENV GAP_HOME /home/gap/inst/gap-${GAP_VERSION}
ENV PATH ${GAP_HOME}/bin:${PATH}

# Start at $HOME.
WORKDIR /home/gap

# Start from a BASH shell.
CMD ["bash"]
