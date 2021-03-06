#!/bin/bash

# TODO: add some sighandlers to cleanup temp stuff automatically
# TODO: add more CLI parameters
# TODO: look inside the downloaded XML and perform some sanity checks
# TODO: removing "fid" using sed works but it might be cleaner to use xmllint
# NOTE: potential security risk: we are "sourcing" the sidecar *.meta files for simplicity

# Return codes:
# 0 = OK
# 1 = wrong CLI parameters
# 2 = using different download URL as before
# 3 = another instance already running in the specified dir

# TODO:
#   add return codes for:
#   - unable to download
#   - update to download + retry limit reached

function usage() {
  echo USAGE: $(basename "$0") URL DIR
  exit 1
}

# store the width of our terminal
NCOL=`stty size --file=/dev/stdin | cut -d" " -f2`

function write_separator() {
  echo `seq 1 $NCOL | sed 's/^.*//' | tr '\n' '-'`
}


RETRY_LIMIT=3
LIMIT_RATE="1m" # max download rate for wget
DOWNLOAD_BEGIN="NEVER"
DOWNLOAD_END="NEVER"

URL="$1" # e.g. http://mygeoserver.com/geoserver/
DIR="${2%/}" # e.g. /path/to/my/mydir

# check parameters and show usage
[[ -z "$1" ]] && usage
[[ -z "$2" ]] && usage

# sanity check: data should always be downloaded from the same base URL
if [ -f "$DIR/download.url" ]; then
  DURL=`head -1 "$DIR/download.url"`
  [[ "$DURL" != "$URL" ]] && {
    echo "Using different URL as before:"
    echo " - Current URL:  $URL"
    echo " - Previous URL: $DURL"
    echo "   (override by deleting the file '$DIR/download.url')"
    exit 2
  }
else
  # saving the URL
  echo "$URL" > "$DIR/download.url"
fi

( # LOCK the directory (non-blocking)
  flock -n 9 || {
    echo "already running"
    exit 3
  }

  TMP=`mktemp gml-XXXXX.download`

  # list all files, but just GML files
  # filter: we need files older than 1 day (-daystart \! -mtime 0)
  # order files by mtime (oldest on top)
  # if there is no oldest file, just finish
  find "$DIR" -name '*.gml' -daystart \! -mtime 0 -printf "%T@ %f\n" |
  sort | head -1 | while read OLDEST; do
    write_separator
    FILENAME="${OLDEST/#*.* /}"
    TYPENAME="${FILENAME%.gml}"
    SAVETOFILE="$DIR/$FILENAME"
    METANAME="$DIR/$TYPENAME.meta"
    echo "Oldest file: $OLDEST"

    # try to download the oldest file
    DOWNLOAD_URL="${URL%/}/ows?service=WFS&version=1.0.0&request=GetFeature&typeName=$TYPENAME"
    echo "Download from URL : $DOWNLOAD_URL"
    echo "Download to file  : $SAVETOFILE"
    write_separator

    # loading metadata sidecar file
    # this should be the only place, where we load the file
    if [ -f "$METANAME" ]; then
      source "$METANAME"
    fi

    # count the number of download retries
    DOWNLOAD_COUNT=$((DOWNLOAD_COUNT + 1))

    # timestamp of the beginning of download
    TMPBEGIN=`date '+%Y-%m-%d %H:%M:%S'`

    if wget --output-document="$TMP" "$DOWNLOAD_URL" --limit-rate="$LIMIT_RATE"
    then

      write_separator
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
    # this should be the only place, where we store the file
    typeset -p DOWNLOAD_COUNT DOWNLOAD_BEGIN DOWNLOAD_END > "$METANAME"
  done

  rm "$TMP"
  echo "done"

) 9< "$DIR" # UNLOCK the directory
