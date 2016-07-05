#!/bin/bash

# TODO: add some sighandlers to cleanup temp stuff automatically
# TODO: add more CLI parameters
# TODO: add different return codes
# TODO: look inside the downloaded XML and perform some sanity checks
# TODO: removing "fid" using sed works but it might be cleaner to use xmllint
# NOTE: potential security risk: we are "sourcing" the sidecar *.meta files for simplicity

function usage() {
  echo USAGE: $(basename "$0") URL DIR
  exit 1
}

RETRY_LIMIT=3
LIMIT_RATE="1m" # max download rate for wget
DOWNLOAD_BEGIN="NEVER"
DOWNLOAD_END="NEVER"

URL="$1" # e.g. http://mygeoserver.com/geoserver/
DIR="$2" # e.g. /path/to/my/mydir

# check parameters and show usage
[[ -z "$1" ]] && usage
[[ -z "$2" ]] && usage

TMP=`mktemp gml-XXXXX.download`

# list all files, but just GML files
# filter: we need files older than 1 day (-daystart \! -mtime 0)
# order files by mtime (oldest on top)
# if there is no oldest file, just finish
find "$DIR" -name '*.gml' -daystart \! -mtime 0 -printf "%T@ %f\n" |
sort | head -1 | while read OLDEST; do
  FILENAME="${OLDEST/#*.* /}"
  TYPENAME="${FILENAME%.gml}"
  SAVETOFILE="$DIR/$FILENAME"
  METANAME="$DIR/$TYPENAME.meta"
  echo "Oldest file: $OLDEST"

  # try to download the oldest file
  # if failed to download, try it N times (keep the counter in a separate file)
  DOWNLOAD_URL="${URL%/}/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=$TYPENAME"
  echo "DOWNLOAD: $DOWNLOAD_URL to $SAVETOFILE"

  # loading metadata sidecar file
  if [ -f "$METANAME" ]; then
    source "$METANAME"
  fi

  # count the number of download retries
  DOWNLOAD_COUNT=$((DOWNLOAD_COUNT + 1))

  # timestamp of the beginning of download
  TMPBEGIN=`date '+%Y-%m-%d %H:%M:%S'`

  if wget --output-document="$TMP" "$DOWNLOAD_URL" --limit-rate="$LIMIT_RATE"
  then

    echo -n "Download successful, now formatting XML ... "

    # Formatting the XML using xmllint.
    # The "fid" XML attribute changes on every request which renders incremental
    # backup useless. Therefore we remove it automatically using sed.
    xmllint --format "$TMP" | sed 's/\s*fid="[^"]*"//' > "$SAVETOFILE"
    echo "ok"

    # preparing timestamps to be stored as metadata
    DOWNLOAD_BEGIN="$TMPBEGIN"
    DOWNLOAD_END=`date '+%Y-%m-%d %H:%M:%S'`

  else

    echo "Error downloading the layer (counter=$DOWNLOAD_COUNT)"

    # If an upper limit of download retries is reached,
    # we skip the file and try to download it the next day.
    if [ "$DOWNLOAD_COUNT" -gt "$RETRY_LIMIT" ]; then

      # We keep the content from the last successful download
      touch "$SAVETOFILE"

      # reseting the counter
      DOWNLOAD_COUNT=0
      echo "Retry limit reached. We'll try to download this layer tomorrow."
    fi
  fi

  # store updated metadata in a sidecar file
  typeset -p DOWNLOAD_COUNT DOWNLOAD_BEGIN DOWNLOAD_END > "$METANAME"
done

rm "$TMP"
echo "done"
