FROM ubuntu:18.04
LABEL maintainer="Pieter Compen <info@compen.net>"
LABEL Description="Image for building Android Flutter projects"

ENV VERSION_SDK_TOOLS "4333796"
ENV FLUTTER_VERSION 1.17.5-stable

ENV ANDROID_HOME "/sdk"
ENV PATH "$PATH:${ANDROID_HOME}/tools:/flutter/bin/cache/dart-sdk/bin:/flutter/bin"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update
RUN apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

RUN apt-get install -qqy --no-install-recommends \
      bzip2 \
      curl \
      git-core \
      html2text \
      openjdk-8-jdk \
      libc6-i386 \
      lib32stdc++6 \
      lib32gcc1 \
      lib32ncurses5 \
      lib32z1 \
      unzip \
      xz-utils \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN curl -O https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip && \
    unzip /sdk-tools-linux-${VERSION_SDK_TOOLS}.zip -d /sdk && \
    rm -rf /sdk-tools-linux-${VERSION_SDK_TOOLS}.zip

RUN mkdir -p $ANDROID_HOME/licenses/ \
  && echo "8933bad161af4178b1185d1a37fbf41ea5269c55\nd56f5187479451eabf01fb78af6dfcb131a6481e" > $ANDROID_HOME/licenses/android-sdk-license \
  && echo "84831b9409646a918e30573bab4c9c91346d8abd" > $ANDROID_HOME/licenses/android-sdk-preview-license
  
RUN yes | $ANDROID_HOME/tools/bin/sdkmanager "platforms;android-28"

ADD packages /sdk

RUN mkdir -p /root/.android && \
  touch /root/.android/repositories.cfg && \
  ${ANDROID_HOME}/tools/bin/sdkmanager --update 

RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < /sdk/packages && \
    ${ANDROID_HOME}/tools/bin/sdkmanager ${PACKAGES}

RUN yes | sdk/tools/bin/sdkmanager --licenses

RUN curl -O https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_$FLUTTER_VERSION.tar.xz && \
  tar xf flutter_linux_$FLUTTER_VERSION.tar.xz && \
  rm -rf flutter_linux_$FLUTTER_VERSION.tar.xz

RUN yes | flutter doctor --android-licenses
RUN flutter doctor

