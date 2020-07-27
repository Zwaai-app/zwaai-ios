#!/bin/sh

##
# Collect some information about the build so that it can be displayed
# as debug information in development builds.
#
# This script is called from an Xcode build phase. It is not intended to
# be called manually.

BUILDINFO_FILE=$CODESIGNING_FOLDER_PATH/buildinfo.txt
if [[ -f $BUILDINFO_FILE ]]; then
    git rev-parse --short HEAD > $BUILDINFO_FILE
    git rev-parse --abbrev-ref HEAD >> $BUILDINFO_FILE
    hostname >> $BUILDINFO_FILE
fi

