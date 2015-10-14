FROM alpine:edge

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LC_ALL=en_US.UTF-8                                                       
ENV LANG=en_US.UTF-8                                                         
ENV LANGUAGE=en_US.UTF-8

# Here we use several hacks collected from https://github.com/gliderlabs/docker-alpine/issues/11:
# 1. install GLibc (which is not the cleanest solution at all) 
# 2. hotfix /etc/nsswitch.conf, which is apperently required by glibc and is not used in Alpine Linux

RUN apk --update add bash ca-certificates && \
    cd /tmp && \
    wget "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk" \
         "https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-bin-2.21-r2.apk" && \
    apk add --allow-untrusted glibc-2.21-r2.apk glibc-bin-2.21-r2.apk && \
    /usr/glibc/usr/bin/ldconfig /lib /usr/glibc/usr/lib && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    wget "http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh" && \
    bash ./Miniconda3-latest-Linux-x86_64.sh -b -p /opt/conda && \
    rm /tmp/* /var/cache/apk/*

ENV PATH /opt/conda/bin:$PATH

RUN echo 'export PATH=/opt/conda/bin:$PATH' >> /etc/profile.d/conda.sh && \
    conda update --all --yes && \
    conda install pip virtualenv --yes

COPY miniconda.sh /usr/local/bin/
RUN adduser -D conda
RUN chmod +x /usr/local/bin/miniconda.sh

WORKDIR /home/conda
USER conda

ENTRYPOINT ["/usr/local/bin/miniconda.sh"]
