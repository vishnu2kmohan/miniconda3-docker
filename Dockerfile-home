# debian:9.4 - linux; amd64
# https://github.com/docker-library/repo-info/blob/master/repos/debian/tag-details.md#debian94---linux-amd64
FROM debian@sha256:316ebb92ca66bb8ddc79249fb29872bece4be384cb61b5344fac4e84ca4ed2b2

ARG BUILD_DATE
ARG CODENAME="stretch"
ARG CONDA_VERSION="4.5.1"
ARG CONDA_DIR="/opt/conda"
ARG CONDA_INSTALLER="Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh"
ARG CONDA_MD5="0c28787e3126238df24c5d4858bd0744"
ARG CONDA_URL="https://repo.continuum.io/miniconda"
ARG DISTRO="debian"
ARG DEBCONF_NONINTERACTIVE_SEEN="true"
ARG DEBIAN_FRONTEND="noninteractive"
ARG GPG_KEYSERVER="hkps://zimmermann.mayfirst.org"
ARG HOME=/root
ARG LANG="en_US.UTF-8"
ARG LANGUAGE="en_US.UTF-8"
ARG LC_ALL="en_US.UTF-8"
ARG REPO="http://cdn-fastly.deb.debian.org"
ARG TINI_GPG_KEY="6380DC428747F6C393FEACA59A84159D7001A4E5"
ARG TINI_URL="https://github.com/krallin/tini/releases/download"
ARG TINI_VERSION="v0.18.0"
ARG VCS_REF

LABEL maintainer="Vishnu Mohan <vishnu@mesosphere.com>" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.name="Miniconda" \
      org.label-schema.description="A mini version of Anaconda that includes just conda, its dependencies and Python" \
      org.label-schema.url="https://conda.io" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vcs-url="https://github.com/vishnu2kmohan/miniconda3-docker" \
      org.label-schema.version="${CONDA_VERSION}" \
      org.label-schema.schema-version="1.0"

ENV CODENAME=${CODENAME:-"stretch"} \
    CONDA_DIR=${CONDA_DIR:-"/opt/conda"} \
    DEBCONF_NONINTERACTIVE_SEEN=${DEBCONF_NONINTERACTIVE_SEEN:-"true"} \
    DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-"noninteractive"} \
    DISTRO=${DISTRO:-"debian"} \
    GPG_KEYSERVER=${GPG_KEYSERVER:-"hkps://zimmermann.mayfirst.org"} \
    HOME=${HOME:-"/root"} \
    LANG=${LANG:-"en_US.UTF-8"} \
    LANGUAGE=${LANGUAGE:-"en_US.UTF-8"} \
    LC_ALL=${LC_ALL:-"en_US.UTF-8"} \
    PATH="${CONDA_DIR}/bin:${PATH}" \
    SHELL="/bin/bash"

RUN echo "deb ${REPO}/${DISTRO} ${CODENAME} main" \
         >> /etc/apt/sources.list \
    echo "deb ${REPO}/${DISTRO}-security ${CODENAME}/updates main" \
         >> /etc/apt/sources.list \
    && apt-get update -yq --fix-missing \
    && apt-get install -yq --no-install-recommends locales \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && apt-get install -yq --no-install-recommends apt-utils \
    && apt-get -yq dist-upgrade \
    && apt-get install -yq --no-install-recommends \
       bash-completion \
       bzip2 \
       ca-certificates \
       curl \
       dirmngr \
       git \
       gnupg \
       jq \
       less \
       openssh-client \
       procps \
       rsync \
       sudo \
       unzip \
       vim \
       wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && usermod -u 99 nobody \
    && addgroup --gid 99 nobody \
    && usermod -g nobody nobody \
    && echo "nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin" >> /etc/passwd

RUN cd /tmp \
    && apt-key adv --keyserver "${GPG_KEYSERVER}" --recv-keys "${TINI_GPG_KEY}" \
    && curl --retry 3 -fsSL "${TINI_URL}/${TINI_VERSION}/tini" -o /usr/bin/tini \
    && curl --retry 3 -fsSL -O "${TINI_URL}/${TINI_VERSION}/tini.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --keyserver "${GPG_KEYSERVER}" --recv-keys "${TINI_GPG_KEY}" \
    && gpg --batch --verify tini.asc /usr/bin/tini \
    && rm -rf "${GNUPGHOME}" tini.asc \
    && chmod +x /usr/bin/tini

RUN cd /tmp \
    && curl --retry 3 -fsSL -O "${CONDA_URL}/${CONDA_INSTALLER}" \
    && echo "${CONDA_MD5}  ${CONDA_INSTALLER}" | md5sum -c - \
    && bash "./${CONDA_INSTALLER}" -u -b -p "${CONDA_DIR}" \
    && ${CONDA_DIR}/bin/conda config --system --prepend channels conda-forge \
    && ${CONDA_DIR}/bin/conda config --system --set auto_update_conda false \
    && ${CONDA_DIR}/bin/conda config --system --set show_channel_urls true \
    && ${CONDA_DIR}/bin/conda update --json --all -yq \
    && ${CONDA_DIR}/bin/conda clean --json -tipsy \
    && rm -rf "${HOME}/.cache/pip" "/tmp/*"

COPY profile "/root/.profile"
COPY bash_profile "/root/.bash_profile"
COPY bashrc "/root/.bashrc"
COPY dircolors "/root/.dircolors"
