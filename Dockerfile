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
        libaudiofile1 \
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
# Do the same for Nvidia
ENV __GL_ExtensionStringVersion=17700

# Symlink libGL to a known location for old games.
RUN ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/libGL.so
# Symlink libaudiofile.so to a known location for Heavy Gear 2.
RUN ln -s /usr/lib/i386-linux-gnu/libaudiofile.so.1 /usr/lib/libaudiofile.so.0

# Copy a subset of the "Loki compat libs" to a standard location.
# This has only been useful for Civ:CTP so far.
COPY lib/* /usr/lib/

# Run as a regular user
ARG USER_UID
ARG USER_GID
ENV USER=loki
RUN useradd -ms /bin/bash $USER
RUN usermod --uid $USER_UID "$USER"
RUN groupmod --gid $USER_GID "$USER"
WORKDIR /home/loki
COPY ./build /home/loki/game
COPY ./start.sh /home/loki/start.sh
RUN cat /etc/skel/.bashrc start.sh > .bashrc
RUN chown $USER_UID:$USER_GID -R /home/loki/
USER $USER

CMD ["bash"]
