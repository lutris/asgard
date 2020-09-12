# Docker image used to run old Linux games such as the ones released by Loki or
# Linux Game Publishing.
FROM i386/ubuntu:16.04

# Install system dependencies needed by old games.
#
# libdrm-radeon1 breaks Mesa for Radeon cards, at least for GPU models that
# didn't exist back when the base system was released.

RUN \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
        libasound2-data \
        libasound2 \
        libasound2-plugins \
        libgtk2.0-0 \
        libcanberra-gtk-module \
        libnss3 \
        libgl1-mesa-glx \
        x11-xkb-utils \
        x11-xserver-utils \
        libxft2 \
        libopenal1 \
        libesd0 \
        libsdl1.2debian \
        libsdl-mixer1.2 \
        libsdl2-2.0-0 \
        libsdl-ttf2.0-0 \
        libsdl-sound1.2 \
        libsdl-image1.2 \
        libxml2 && \
  rm -rf /var/lib/apt/lists/*

# Some games break while printing the current list of GL extensions. This
# setting only expose extension made before a given year.
ENV MESA_EXTENSION_MAX_YEAR=2000

# Symlink libGL to a known location for old games.
RUN ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/libGL.so
#
# Run as a regular user
ENV USER=loki
RUN useradd -ms /bin/bash $USER
RUN usermod --uid 1000 "$USER"
RUN groupmod --gid 1000 "$USER"

# Copy a subset of the "Loki compat libs" to a standard location.
# This has only been useful for Civ:CTP so far.
COPY lib/* /usr/lib/
COPY ./game /home/loki/game
COPY ./bashrc /home/loki/.bashrc

RUN chown 1000:1000 -R /home/loki/game
USER $USER

WORKDIR /home/loki
CMD ["bash"]
