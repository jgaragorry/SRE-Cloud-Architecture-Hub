FROM ubuntu:22.04
RUN apt-get update && apt-get install -y openssh-server python3
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
# Línea crítica corregida para el path de SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config || true
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd
# Crear carpeta .ssh y copiar tu llave pública (debes tener el archivo .pub en la carpeta del repo)
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh
COPY id_workshop.pub /root/.ssh/authorized_keys
RUN chmod 600 /root/.ssh/authorized_keys
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
