#!/bin/bash

APP_HOME="/app"
CCG2LAMBDA_HOME="/opt/ccg2lambda"

FILE_NAME=$(basename $0)
PWD=$(pwd)

if [ ! -f $PWD/$FILE_NAME ]; then
    echo "<$FILE_NAME> is not in current directory."
    exit 1
fi

options=""
if [ $# -gt 0 ]; then
    options="$APP_HOME/bin/app.sh $@"
fi

sudo docker run \
    -it \
    --rm \
    -e APP_HOME=$APP_HOME \
    -e CCG2LAMBDA_HOME=$CCG2LAMBDA_HOME \
    -v $PWD/bin:$APP_HOME/bin \
    -v $PWD/share:$APP_HOME/share \
    ccg2lambda \
    $options

