#!/bin/bash

FILE_NAME=$(basename $0)

if [ ! -f $(pwd)/$FILE_NAME ]; then
    echo "<$FILE_NAME> is not in current directory."
    exit 1
fi

if [ $# -gt 0 ]; then
    sudo docker run -it --rm -v $(pwd)/share:/mnt/host ccg2lambda
else
    sudo docker run -it --rm -v $(pwd)/share:/mnt/host ccg2lambda
fi

