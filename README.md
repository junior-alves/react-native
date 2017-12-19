# Docker container for React Native Android development

This dockerfile will build a Open JDK8 based container that encapsulates node, the android sdk and react native.

## Setup
	docker-compose up -d --build --force-recreate

## Access container
	docker exec -it react-native bash

## Start a react-native project
	$ cd /project
	$ react-native init MyProject

### Build App
$ cd MyProject
$ react-native run-android //Or react-native run-ios
