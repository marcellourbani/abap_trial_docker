FROM opensuse/leap:latest
RUN zypper --non-interactive install --replacefiles uuid uuidd hostname wget expect unrar tcsh tar which net-tools iproute2 gzip libaio1
RUN zypper --non-interactive install --replacefiles vim iputils
RUN mkdir /run/uuidd && chown uuidd /var/run/uuidd && /usr/sbin/uuidd
COPY install.expect /usr/local/bin
COPY ABAP_Trial /var/tmp/ABAP_Trial

RUN HOSTNAME=`uname -n`;\
    sed "s/\($HOSTNAME\)/vhcalnplci/" /etc/hosts > /tmp/hosts ;\
    cat /tmp/hosts > /etc/hosts; rm /tmp/hosts;\
    echo vhcalnplci >/etc/hostname;\
    hostname vhcalnplci;\
    /usr/local/bin/install.expect --password "S3cr3tP@ssw0rd" --accept-SAP-developer-license;\
    su - npladm -c "stopsap ALL"
EXPOSE 8000
EXPOSE 44300
EXPOSE 4237
EXPOSE 3300
EXPOSE 3200
