#!/bin/bash

set -ex

mkdir -p /config/{extensions,data,workspace,.ssh}

PUID=${PUID:-1000}
PGID=${PGID:-1000}

groupmod -o -g "$PGID" code-server
usermod -o -u "$PUID" code-server

chown -R code-server:code-server /config

if [ -z "$1" || "$1" == "code-server" ]; then
    if [ -n "${SUDO_PASSWORD}" ] || [ -n "${SUDO_PASSWORD_HASH}" ]; then
        echo "setting up sudo access"
        if ! grep -q 'code-server' /etc/sudoers; then
            echo "adding code-server to sudoers"
            echo "code-server ALL=(ALL:ALL) ALL" >> /etc/sudoers
        fi
        if [ -n "${SUDO_PASSWORD_HASH}" ]; then
            echo "setting sudo password using sudo password hash"
            sed -i "s|^code-server:\!:|code-server:${SUDO_PASSWORD_HASH}:|" /etc/shadow
        else
            echo "setting sudo password using SUDO_PASSWORD env var"
            echo -e "${SUDO_PASSWORD}\n${SUDO_PASSWORD}" | passwd code-server
        fi
    fi

    if [ -n "${PASSWORD}" ]; then
        AUTH="password"
    else
        AUTH="none"
        echo "starting with no password"
    fi

    if [ -z ${PROXY_DOMAIN+x} ]; then
    PROXY_DOMAIN_ARG=""
    else 
    PROXY_DOMAIN_ARG="--proxy-domain=${PROXY_DOMAIN}"
    fi

    exec gosu code-server code-server --bind-addr 0.0.0.0:8443 --user-data-dir /config/data --extensions-dir /config/extensions --disable-telemetry --auth "${AUTH}" "${PROXY_DOMAIN_ARG}" /config/workspace
fi

echo "Executing $@"
exec gosu code-server "$@"

