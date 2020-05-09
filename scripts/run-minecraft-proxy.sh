#!/bin/bash

java -Xmx1024M -Xms512M -jar /srv/minecraft/proxy-server.jar

tail -f /dev/null