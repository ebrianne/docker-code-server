FROM debian:stable-slim

# environment settings
ARG CODE_RELEASE
ARG DEBIAN_FRONTEND="noninteractive"

ENV HOME="/config"
ENV TZ="Europe/Berlin"

RUN apt-get update && apt-get -y install apt-utils locales && \
    apt-get -y install bash curl wget zsh gosu sudo nano tzdata ca-certificates git python3.7 python3-pip && \ 
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*
RUN useradd -u 1000 -U -d /config -s /bin/false code-server && usermod -G code-server code-server
RUN if [ -z ${CODE_RELEASE+x} ]; then \
	CODE_RELEASE=$(curl -sX GET "https://api.github.com/repos/cdr/code-server/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
    fi && \
    CODE_VERSION=$(echo "$CODE_RELEASE" | awk '{print substr($1,2); }') && \
    curl -fsSL https://code-server.dev/install.sh | sh -s -- --prefix=/usr/local --version=${CODE_VERSION}

COPY docker-entrypoint.sh /

ENTRYPOINT [ "./docker-entrypoint.sh" ]

# ports and volumes
EXPOSE 8443