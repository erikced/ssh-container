FROM debian:trixie-slim@sha256:77ba0164de17b88dd0bf6cdc8f65569e6e5fa6cd256562998b62553134a00ef0
RUN apt-get update \
    && apt-get install --yes --no-install-recommends openssh-server wget \
    && apt-get clean \
    && rm /etc/ssh/ssh_host*_key* \
    && sed -i \
        -e 's/^#\?PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' \
        /etc/ssh/sshd_config \
    && echo "HostKey /config/ssh_host_rsa_key" >> /etc/ssh/sshd_config \
    && echo "HostKey /config/ssh_host_ecdsa_key" >> /etc/ssh/sshd_config \
    && echo "HostKey /config/ssh_host_ed25519_key" >> /etc/ssh/sshd_config \
    && umask 0022 \
    && mkdir -p /config
COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/sbin/sshd", "-D", "-e" ]
