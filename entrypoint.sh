#!/usr/bin/env bash
set -e -o pipefail
: "${SSH_USERNAME:=user}"
: "${SSH_UID:=1000}"
: "${SSH_GID:=1000}"

addgroup --gid "$SSH_GID" "$SSH_USERNAME"
adduser --uid "$SSH_UID" --gid "$SSH_GID" --disabled-password --comment "" --no-create-home "$SSH_USERNAME"
SSH_USER_HOME="/home/$USERNAME"
if [ ! -d "$SSH_USER_HOME" ]; then
    mkdir "$SSH_USER_HOME"
fi

umask 0077
mkdir "$SSH_USER_HOME/.ssh"
if [ -f "$SSH_USER_HOME/.ssh/authorized_keys" ]; then
    echo "SSH authorized keys found."
elif [ -n "$AUTHORIZED_KEYS" ]; then
    echo "Adding SSH authorized keys."
    printf "%s" "$AUTHORIZED_KEYS" > "$SSH_USER_HOME/.ssh/authorized_keys"
else
    echo "SSH authorized keys not found, either set \$AUTHORIZED_KEYS or make sure keys exist at $SSH_USER_HOME/.ssh/authorized_keys."
fi
umask 0022

chown $SSH_UID:$SSH_GID "$SSH_USER_HOME"
chown -R "$SSH_UID":"$SSH_GID" "$SSH_USER_HOME/.ssh"

exec "$@"