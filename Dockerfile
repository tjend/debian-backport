FROM docker.io/debian:bullseye

RUN \
  # configure backports repo
  echo 'deb http://deb.debian.org/debian bullseye-backports main' \
    > /etc/apt/sources.list.d/backports.list && \
  apt-get update && \
  #
  # install build tools
  apt-get --assume-yes --target-release bullseye-backports install \
    debian-keyring \
    devscripts \
    equivs \
    packaging-dev \
    vim-tiny && \
  #
  # configure unstable repo
  echo 'deb-src http://deb.debian.org/debian unstable main' \
    > /etc/apt/sources.list.d/unstable-source.list && \
  apt-get update
