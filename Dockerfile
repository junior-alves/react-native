FROM openjdk:8-jdk

MAINTAINER Júnior Alves <jr290488@gmail.com>

# Setup environment variables
ENV ANDROID_ADB_SERVER_PORT=5038
# ENV GRADLE_USER_HOME /app/android/gradle_deps

ENV PATH $PATH:node_modules/.bin
ENV PATH=$JAVA_HOME/bin:$PATH

## Set correct environment variables.
ENV ANDROID_SDK_FILE android-sdk_r24.4.1-linux.tgz
ENV ANDROID_SDK_URL http://dl.google.com/android/$ANDROID_SDK_FILE

RUN \
	sed -i "s/deb\.debian\./ftp\.br\.debian\./g" /etc/apt/sources.list

RUN \
	apt-get update \
	&& apt-get --assume-yes install build-essential libssl-dev software-properties-common

## Install SDK
ENV ANDROID_HOME /usr/local/android-sdk-linux
RUN \
	cd /usr/local \
    && wget $ANDROID_SDK_URL \
    && tar -xzf $ANDROID_SDK_FILE \
    && export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools \
    && chgrp -R users $ANDROID_HOME \
    && chmod -R 0775 $ANDROID_HOME \
    && rm $ANDROID_SDK_FILE


# Install android tools and system-image.
ENV PATH $PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/23.0.1

# RUN \
# 	(while true ; do sleep 5; echo y; done) | android update sdk --no-ui --force --all --filter platform-tools,android-25,build-tools-25.0.1,extra-android-support,extra-android-m2repository,sys-img-x86_64-android-25,extra-google-m2repository

RUN \
	(while true ; do sleep 5; echo y; done) | android update sdk --no-ui --force --all --filter platform-tools,android-23,build-tools-23.0.1,android-25,build-tools-25.0.3,extra-android-support,extra-android-m2repository,sys-img-x86_64-android-23,sys-img-x86_64-android-25,extra-google-m2repository


# Install Node
RUN \
	curl -sL https://deb.nodesource.com/setup_6.x | bash - \
	&& apt-get --assume-yes install nodejs


# Install watchman
RUN \
	apt-get install -qy python-dev lib32stdc++6 lib32z1 lib32z1-dev automake autoconf libtool

RUN \
	git clone https://github.com/facebook/watchman.git \
	&& cd watchman && git checkout v4.7.0 && ./autogen.sh && ./configure && make && make install

# Install yarn
RUN \
	curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
	&& echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
	&& apt-get update && apt-get -qy install yarn

# Install gradle
ENV PATH=$PATH:/opt/gradle/gradle-3.4.1/bin
RUN \
	cd /tmp/ \
	&& wget https://services.gradle.org/distributions/gradle-3.4.1-bin.zip \
	&& mkdir /opt/gradle \
	&& unzip -d /opt/gradle gradle-3.4.1-bin.zip


# Install Basic React-Native packages
RUN \
	npm install -g react-native-cli \
	&& npm install rnpm -g 

## Clean up when done
RUN \
	apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && npm cache clear --force

EXPOSE 5038

WORKDIR /project

COPY ./entrypoint.sh /bin/entrypoint.sh

RUN \
	chmod +x /bin/entrypoint.sh

ENV ANDROID_EMULATOR_FORCE_32BIT true
ENV ANDROID_SDK_HOME=$ANDROID_HOME
ENV ANDROID_AVD_HOME=/root

ENTRYPOINT /bin/entrypoint.sh; bash