FROM opensuse/leap:latest
LABEL hostname="vhalnplci"

RUN mkdir -p etc/pki/ca-trust/source/SAP
COPY patches/usr/local/bin/* /usr/local/bin/
COPY patches/etc/pki/ca-trust/source/SAP/* /etc/pki/ca-trust/source/SAP/

RUN zypper --non-interactive install --replacefiles \
    uuid uuidd hostname wget expect tcsh tar which net-tools iproute2 gzip libaio1 vim iputils catatonit \
    curl python-openssl python-pip && \
    mkdir /var/run/uuidd && \
    chown uuidd /var/run/uuidd 

# COPY patches.tgz /root/
# RUN cd /;tar xzf /root/patches.tgz;rm /root/patches.tgz

# Install PyRFC and run installation
RUN pip install --upgrade pip && \
    cd /var/tmp &&\
    curl -LO https://github.com/SAP/PyRFC/releases/download/1.9.99/pyrfc-1.9.99-cp27-cp27mu-linux_x86_64.whl&& \
    pip install  /var/tmp/pyrfc-1.9.99-cp27-cp27mu-linux_x86_64.whl && \
    rm -f /var/tmp/pyrfc-1.9.99-cp27-cp27mu-linux_x86_64.whl

EXPOSE 8000
EXPOSE 44300
EXPOSE 3300
EXPOSE 3200
