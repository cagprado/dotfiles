#!/bin/zsh

GEOFILE="track.kmz"
FIXTIMEFILE="time.jpg"
DIR=$(pwd)

checktime()
{
  local TIME
  TIME=("${(@s/:/)1}")
  if [[ "${#TIME}" -ne 3 ]]; then
    return 1
  fi

  if [[ "$TIME[1]" != <-> || "$TIME[2]" != <-> || "$TIME[3]" != <-> ]]; then
    return 1
  fi

  if [[ "$TIME[1]" -lt 0 || "$TIME[1]" -gt 23 ]]; then
    return 1
  fi

  if [[ "$TIME[2]" -lt 0 || "$TIME[2]" -gt 59 ]]; then
    return 1
  fi

  if [[ "$TIME[3]" -lt 0 || "$TIME[3]" -gt 59 ]]; then
    return 1
  fi

  return 0
}

timeoffset()
{
  local SEC1=$(date +%s -d $1)
  local SEC2=$(date +%s -d $2)
  local DIFF
  if [[ $SEC2 -gt $SEC1 ]]; then
    ((DIFF = SEC2 - SEC1))
    echo "+=$(date +%H:%M:%S -ud @${DIFF})"
  else
    ((DIFF = SEC1 - SEC2))
    echo "-=$(date +%H:%M:%S -ud @${DIFF})"
  fi
}

while [[ -z "$GEOFILE" || ! -f $GEOFILE ]]; do
  echo "Could not find gps track file '$GEOFILE', please provide one: "
  read GEOFILE
done

if [[ "${GEOFILE##*.}" == "kmz" ]]; then
  unzip "${GEOFILE}"
  mv doc.kml "${GEOFILE%.*}.kml"
  GEOFILE="${GEOFILE%.*}.kml"
fi

if [[ ! -f $FIXTIMEFILE ]]; then
  echo "Could not find timestamp reference image 'time.jpg'!"
  echo -n "Please, provide a reference image filename [ENTER to ignore]: "
  read FIXTIMEFILE
fi

if [[ -n "$FIXTIMEFILE" ]]; then
  echo "Timestamp reference image: $FIXTIMEFILE"
  echo -n "Set correct time for this image [HH:MM:SS]: "
  read TIME
  checktime $TIME
  while [[ $? -eq 1 ]]; do
    echo -n "Incorrect format. Set correct time for this image [HH:MM:SS]: "
    read TIME
    checktime $TIME
  done
  
  TIMEORIGINAL=$(exiftool -s3 -DateTimeOriginal $FIXTIMEFILE | cut -f2 -d' ')
  TIMEOFFSET=$(timeoffset $TIMEORIGINAL $TIME)
  echo "Applying time offset of $TIMEOFFSET..."
  exiftool -overwrite_original -alldates$TIMEOFFSET $DIR
else
  echo "No reference image given..."
fi

exiftool -overwrite_original -geotag $GEOFILE $DIR
