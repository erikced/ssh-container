FROM debian:bookworm-slim@sha256:b1211f6d19afd012477bd34fdcabb6b663d680e0f4b0537da6e6b0fd057a3ec3
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
    && umask 0077 \
    && mkdir /run/sshd \
    && umask 0022 \
    && mkdir -p /config
COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/sbin/sshd", "-D", "-e" ]
