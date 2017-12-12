FROM openjdk:8-jdk

MAINTAINER Júnior Alves <jr290488@gmail.com>

# Setup environment variables
ENV ANDROID_ADB_SERVER_PORT=5038
ENV GRADLE_USER_HOME /app/android/gradle_deps

ENV PATH $PATH:node_modules/.bin
#ENV JAVA_HOME="/usr/lib/jvm/java-7-openjdk-amd64"
ENV PATH=$JAVA_HOME/bin:$PATH

## Set correct environment variables.
ENV ANDROID_SDK_FILE android-sdk_r24.4.1-linux.tgz
ENV ANDROID_SDK_URL http://dl.google.com/android/$ANDROID_SDK_FILE

RUN \
	sed -i "s/deb\.debian\./ftp\.br\.debian\./g" /etc/apt/sources.list

RUN \
	apt-get update \
	&& apt-get --assume-yes install build-essential libssl-dev software-properties-common

RUN \
	curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh -o install.sh | bash install.sh

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

RUN \
	(while true ; do sleep 5; echo y; done) | android update sdk --no-ui --force --all --filter platform-tools,android-23,build-tools-23.0.1,extra-android-support,extra-android-m2repository,sys-img-x86_64-android-23,extra-google-m2repository


# Install watchman
RUN \
	apt-get install -qy build-essential git automake \
	&& git clone https://github.com/facebook/watchman.git \
	&& cd watchman && git checkout v4.7.0 && ./autogen.sh && ./configure && make && make install \
	&& rm -rf watchman

# Install Basic React-Native packages
RUN \
	npm install -g create-react-native-app \
	&& npm install -g react-native-cli

RUN \
	npm install rnpm -g

## Clean up when done
RUN \
	apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && npm cache clear --force

EXPOSE 5038

VOLUME ["/project"]

RUN \
	chmod -R 777 /project

WORKDIR /project
