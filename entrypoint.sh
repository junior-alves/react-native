#!/bin/bash

sysctl -w fs.inotify.max_user_watches=10000

chown -R root:users /project \
    && chmod -R 775 /project