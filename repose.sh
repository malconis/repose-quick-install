#!/bin/bash

HOME=~/
REPOSE=$HOME/repose_home
ARTIFACT_DIR=$REPOSE/artifacts
DEPLOYMENT_DIR=$REPOSE/deployment
CONFIG_DIR=$REPOSE/configs
LOG_DIR=$REPOSE/logs
REPOSE_LOG=$LOG_DIR/repose.log
REPOSE_HTTP_LOG=$LOG_DIR/repose-http.log

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

start_repose()
{
    echo "Starting repose on port 8888..."
    java -jar $REPOSE/repose-valve.jar START -p 8888 -s 8188 -c $CONFIG_DIR > /dev/null 2>&1 &
}

stop_repose()
{
    echo "Stopping repose..."
    java -jar $REPOSE/repose-valve.jar STOP -s 8188
}

install_repose()
{
    echo "Creating Repose install directory under $HOME"
    mkdir $REPOSE $ARTIFACT_DIR $DEPLOYMENT_DIR $CONFIG_DIR $LOG_DIR

    LATEST_URL="http://maven.research.rackspacecloud.com/content/repositories/releases/com/rackspace/repose/installation/deb/valve/repose-valve/maven-metadata.xml"
    LATEST_XML=`wget $LATEST_URL -qO-`
    LATEST_VERSION=`echo $LATEST_XML | sed -n -e 's/.*<release>\(.*\)<\/release>.*/\1/p'`
    LATEST_BUILD_JAR="http://maven.research.rackspacecloud.com/content/repositories/releases/com/rackspace/papi/core/valve/$LATEST_VERSION/valve-$LATEST_VERSION.jar"
    LATEST_BUILD_FB="http://maven.research.rackspacecloud.com/content/repositories/releases/com/rackspace/papi/components/filter-bundle/$LATEST_VERSION/filter-bundle-$LATEST_VERSION.ear"

    echo "Latest Version: $LATEST_VERSION"

    echo "Downloading latest Valve and Filter Bundle..."
    wget -nv $LATEST_BUILD_JAR -O $REPOSE/repose-valve.jar
    wget -nv $LATEST_BUILD_FB -O $ARTIFACT_DIR/filter-bundle.ear

    echo "Downloading config files"

    for f in $DIR/configs/*
    do
        echo $f
        base=`basename $f`
        echo "building $base"
        touch $CONFIG_DIR/$base
        source $f > $CONFIG_DIR/$base
    done

    start_repose
}


case "$1" in
  install)
    install_repose
    ;;
  start)
    start_repose
    ;;
  stop)
    stop_repose
    ;;
  restart)
    stop_repose
    sleep 5
    start_repose
    ;;

  *)
    echo "Usage: repose.sh  {install|start|stop|restart}"
    exit 1
esac

