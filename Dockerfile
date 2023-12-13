FROM debian:bookworm-slim
RUN apt-get update \
    && apt-get install --yes --no-install-recommends openssh-server \
    && apt-get clean \
    && sed -i \
        -e 's/^#\?PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' \
        /etc/ssh/sshd_config \
    && umask 0077 \
    && mkdir /run/sshd \
    && umask 0022
COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "/usr/sbin/sshd", "-D", "-e" ]