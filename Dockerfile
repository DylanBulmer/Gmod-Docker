# This is a modified version of SteamCMD's Dockerfile.
#  -->  https://github.com/steamcmd/docker/blob/master/dockerfiles/ubuntu-18/Dockerfile


# Set the base image
FROM ubuntu:18.04

# Set environment variables
ENV USER steam
ENV HOME /home/steam

# Set working directory
WORKDIR ${HOME}

# Insert Steam prompt answers
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo steam steam/question select "I AGREE" | debconf-set-selections \
 && echo steam steam/license note '' | debconf-set-selections

# Update the repository and install SteamCMD
ARG DEBIAN_FRONTEND=noninteractive
RUN dpkg --add-architecture i386 \
 && apt-get update -y \
 && apt-get install -y --no-install-recommends ca-certificates locales steamcmd \
 && rm -rf /var/lib/apt/lists/*

# Add unicode support
RUN locale-gen en_US.UTF-8
ENV LANG 'en_US.UTF-8'
ENV LANGUAGE 'en_US:en'

# Create symlink for executable
RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd

# Update SteamCMD and verify latest version
# RUN steamcmd +quit

# Update GMod and verify latest version
RUN steamcmd +login anonymous +force_install_dir ${HOME}/gmod +app_update 4020 validate +quit

# Using config files instead of copying file over.
# COPY ./server.cfg ${HOME}/gmod/garrysmod/cfg/server.cfg

# Update CS:S and verify latest version
RUN steamcmd +login anonymous +force_install_dir ${HOME}/content/css +app_update 232330 validate +quit

# Start server
ENTRYPOINT [ "${HOME}/gmod/srcds_run" ]
EXPOSE 27015
CMD [ \
  "-game garrysmod", \
  "+maxplayers ${MAX_PLAYERS:-12}", \
  "+map ${MAP:-gm_construct}", \
  "+gamemode ${GAMEMODE:-sandbox}", \
  "+host_workshop_collection ${WORKSHOP_COLLECTION}", \
  "-authkey ${AUTH_KEY}" \
]