#!/bin/bash

function usage() {
  echo USAGE: $(basename "$0") URL DIR
  exit 1
}

URL="$1" # e.g. http://mygeoserver.com/geoserver/wms?request=GetCapabilities&service=WMS
DIR="$2" # e.g. /path/to/my/mydir

[[ -z "$1" ]] && usage
[[ -z "$2" ]] && usage

find "$DIR" -daystart -mtime 0 -printf "%T@ %f\n" |
  sort -r | head -1 | while read OLDEST; do

  done
