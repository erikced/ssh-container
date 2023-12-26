#!/usr/bin/env bash
set -e -o pipefail
: "${SSH_USERNAME:=user}"
: "${SSH_UID:=1000}"
: "${SSH_GID:=1000}"

# User creation
echo "Creating user '$SSH_USERNAME' ($SSH_UID:$SSH_GID)."
addgroup --gid "$SSH_GID" "$SSH_USERNAME" > /dev/null
adduser --uid "$SSH_UID" --gid "$SSH_GID" --disabled-password --comment "" --no-create-home "$SSH_USERNAME" > /dev/null
SSH_USER_HOME="/home/$SSH_USERNAME"
if [ ! -d "$SSH_USER_HOME" ]; then
    mkdir "$SSH_USER_HOME"
fi

# Authorized keys
umask 0077
mkdir -p "$SSH_USER_HOME/.ssh"
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

# Host key creation
KEY_DIR=/config
if [[ ! -f $KEY_DIR/ssh_host_rsa_key && ! -f $KEY_DIR/ssh_host_ecdsa_key && ! -f $KEY_DIR/ssh_host_ed25519_key ]]; then
    echo "Creating ssh host keys."
    ssh-keygen -q -N "" -t rsa -b 3072 -f /config/ssh_host_rsa_key
    ssh-keygen -q -N "" -t ecdsa -f /config/ssh_host_ecdsa_key
    ssh-keygen -q -N "" -t ed25519 -f /config/ssh_host_ed25519_key
fi

exec "$@"
