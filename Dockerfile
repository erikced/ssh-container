FROM debian:bookworm-slim@sha256:1537a6a1cbc4b4fd401da800ee9480207e7dc1f23560c21259f681db56768f63
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
