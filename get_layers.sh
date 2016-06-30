#!/bin/bash

function usage() {
  echo USAGE: $(basename "$0") URL DIR
  exit 1
}

URL="$1" # e.g. http://mygeoserver.com/geoserver/wms?request=GetCapabilities&service=WMS
DIR="$2" # e.g. /path/to/my/mydir

[[ -z "$1" ]] && usage
[[ -z "$2" ]] && usage

mkdir --parents "$DIR"
LAYERS=`mktemp list_of_layers.XXXX`

# Quick and dirty XML parsing.
# we should later use e.g. xmllint --xpath '//Layer/Name' layers.xml
wget -O /dev/stdout "$URL/wms?request=GetCapabilities&service=WMS" |
  grep -A 1 '<Layer' |
  grep Name |
  sed -e 's/.*<Name>//g' -e 's/<\/Name>//g' |
  sort -u | awk '{print $1".kml"; print $1".gml"}' > "$LAYERS"

# Creating new layers
while read FNAME; do
  touch "$DIR/$FNAME"
done < "$LAYERS"

# Removing old layers
# Note: this is how set complement is implemented in shell
comm -23 <(ls -1 "$DIR" | sort) <(sort "$LAYERS") |
  while read FILE; do
    rm "$DIR/$FILE"
  done

# cleanup temp files
rm "$LAYERS"

echo done.
