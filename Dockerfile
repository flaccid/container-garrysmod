FROM debian:11
ENV DEBIAN_FRONTEND=noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN=true
ENV STEAM_APP_ID=4020
ENV STEAM_INSTALL_DIR=/home/steam
ENV STEAM_TOKEN="123456abcdef"
RUN apt-get -y update && \
    apt-get -y install locales locales-all software-properties-common && \
    add-apt-repository non-free && \
    dpkg --add-architecture i386 && \
    apt-get -y update && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    apt-get -y install steamcmd bash libsdl2-2.0-0:i386 libtinfo5:i386 lib32z1 lib32ncurses6 && \
    rm -rf /var/lib/apt/lists/* && \
    adduser --gecos "" --disabled-password steam && \
    locale-gen en_US en_US.UTF-8 && \
    dpkg-reconfigure locales
USER steam
RUN touch /home/steam/.steam && \
    /usr/games/steamcmd +quit && \
    /usr/games/steamcmd +force_install_dir $STEAM_INSTALL_DIR +login anonymous +app_update "$STEAM_APP_ID" validate +quit && \
    echo "STDERR ERRORS: $(cat /home/steam/Steam/logs/stderr.txt)" && \
    rm /home/steam/Steam/logs/stderr.txt
EXPOSE 27015/tcp
WORKDIR /home/steam
ENTRYPOINT ./srcds_run -game garrysmod +maxplayers 12 +map gm_flatgrass +sv_setsteamaccount $STEAM_TOKEN
