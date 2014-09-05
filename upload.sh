#!/bin/bash

AUTHOR="cmsj"
MODULE="caffeinate"

if [ "$1" == "" ]; then
    echo "Usage: upload.sh VERSION"
    exit 1
fi

VERSION="$1"

luarocks pack mjolnir.${AUTHOR}.${MODULE}
moonrocks upload --skip-pack mjolnir.${AUTHOR}.${MODULE}-${VERSION}.rockspec
moonrocks upload mjolnir.${AUTHOR}.${MODULE}-${VERSION}.all.rock
