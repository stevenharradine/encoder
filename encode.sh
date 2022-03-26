cleanupKeywords=( 4k 1080p 720p 480p 360p 240p 180p h264 x264 h265 x265 mp3 aac ac3 flac )
supportedFormats=( "avi" "mkv" "mp4" )
resolution="1080p"
videoCodec="x264"
audioCodec="ac3"
dryrun=false
help=false
startTime=`date '+%a %d %b %Y %T %Z'`

for arg in "$@"; do
  key=`echo "$arg" | awk -F "=" '{print $1}'`
  value=`echo "$arg" | awk -F "=" '{print $2}'`

  if [[ $key == "--resolution" ]]; then
    resolution=$value
  elif [[ $key == "--videocodec" ]]; then
    videoCodec=$value
  elif [[ $key == "--audiocodec" ]]; then
    audioCodec=$value
  elif [[ $key == "--directory" ]]; then
    directory=$value
  elif [[ $key == "--dryrun" ]]; then
    dryrun=true
  elif [[ $key == "--help" ]]; then
    help=true
  fi
done

if [ $help = true ]; then
  echo "ffmpeg helper v0.0"
  echo "usage: ./encode.sh --directory=videos"
  echo ""
  echo "Options:"
  echo -e "\t--directory (required)\tthe directory to encode relative to currently path"
  echo -e "\t--resolution\t\tcan be one of the following values - 240p, 360p, 480p, 720p, 1080p (default), 4k"
  echo -e "\t--videoCodec\t\t\tcan be any valid video codec as passed directly to ffmpeg ie x264 (default), x265"
  echo -e "\t--audioCodec\t\t\tcan be any valid audio codec as passed directly to ffmpeg ie ac3 (default), acc"
  echo -e "\t--dryRun\tWont encodde anything just list out files to be encoded"
  echo -e "\t--help\t\t\tthis help menu"
  
  exit 0
fi

# the defined resolution name maps to an actual x and y picture size
resolutionMatrixName=( 180p 240p 360p 480p 720p 1080p 4k   )
resolutionMatrixX=(    320  352  480  858  1280 1920  3840 )
resolutionMatrixY=(    180  240  360  480  720  1080  2160 )
for i in "${!resolutionMatrixName[@]}"; do
  if [[ $resolution == ${resolutionMatrixName[$i]} ]]; then
    xRes=${resolutionMatrixX[$i]}
    yRes=${resolutionMatrixY[$i]}
  fi
done

cd "$directory"

filenamePostfix=$resolution.$videoCodec.$audioCodec

if [[ $dryrun == false ]]; then
  mkdir -p "$filenamePostfix"
fi

# Pre scan media
totalRuntimeSeconds=0
totalItems=0
echo "Prescanning media"
for rawfilename in *; do
  extention="${rawfilename##*.}"

  isCurrentFileSupported=false
  for i in "${supportedFormats[@]}"; do
    if [ "$i" == "$extention" ]; then
        isCurrentFileSupported=true
    fi
  done

  if [ "$isCurrentFileSupported" = true ]; then
    echo -n "  $rawfilename"

    cache=`ffmpeg -i "$rawfilename" 2>&1`
    thisDuration=`echo "$cache" | grep "Duration:" | cut -d' ' -f4 | cut -d',' -f1`
    thisVideoCache=`echo "$cache" | grep "Stream #0" | grep "Video:"`
    thisAudioCache=`echo "$cache" | grep "Stream #0" | grep "Audio:"`
    thisVideoCodec=`echo "$thisVideoCache" | cut -d' ' -f 8`
    thisVideoResolution=`echo "$thisVideoCache" | cut -d' ' -f 14`
    thisAudioCodec=`echo "$thisAudioCache" | cut -d' ' -f 8`

    totalRuntimeSeconds="$(date -u -d "`echo jan 1 1970` $thisDuration" +%s) + $totalRuntimeSeconds"

    echo " $thisDuration $thisVideoCodec $thisVideoResolution $thisAudioCodec"

    ((totalItems=totalItems+1))
  fi  
done
echo ""

totalRuntimeSeconds=`echo $totalRuntimeSeconds | bc`
encodeRuntimeSecondsRemaining=$totalRuntimeSeconds
totalRuntimeFormatted=`date -u -d @$totalRuntimeSeconds +%H:%M:%S`

# Execute
echo "Start Encoding"
for rawfilename in *; do
  extention="${rawfilename##*.}"

  isCurrentFileSupported=false
  for i in "${supportedFormats[@]}"; do
    if [ "$i" == "$extention" ]; then
        isCurrentFileSupported=true
    fi
  done

  if [ "$isCurrentFileSupported" = true ]; then
    echo -n "  $rawfilename"

    cache=`ffmpeg -i "$rawfilename" 2>&1`
    thisDuration=`echo "$cache" | grep "Duration:" | cut -d' ' -f4 | cut -d',' -f1`
    filename="${rawfilename%.*}"

    echo -n " " `echo "scale=2; 1 - $encodeRuntimeSecondsRemaining / $totalRuntimeSeconds" | bc -l | sed 's/\.//'`%

    endTime=`date '+%a %d %b %Y %T %Z'`
    seconds1=$(date --date "$endTime" +%s)
    seconds2=$(date --date "$startTime" +%s)
    delta=$((seconds1 - seconds2))
    formatedTime=`printf '%dh:%dm:%ds\n' $((delta/3600)) $((delta%3600/60)) $((delta%60))`
    echo -n " " $formatedTime

    # remove fileformat information from the new filename
    newFilename=$filename
    for keyword in "${cleanupKeywords[@]}"; do
      newFilename=${newFilename//$keyword/}
    done

    if [ $dryrun = false ]; then
    	result=`ffmpeg -i "$rawfilename" -n -map 0 -scodec mov_text -c:v lib$videoCodec -c:a $audioCodec -s $xRes"x"$yRes "$filenamePostfix/$newFilename.$filenamePostfix.mp4" 2>&1`
    else
    	echo -n " " ffmpeg -i "$rawfilename" -n -map 0 -scodec mov_text -c:v lib$videoCodec -c:a $audioCodec -s $xRes"x"$yRes "$filenamePostfix/$newFilename.$filenamePostfix.mp4"
    fi

    encodeRuntimeSecondsRemaining="$encodeRuntimeSecondsRemaining - $(date -u -d "`echo jan 1 1970` $thisDuration" +%s)"
    encodeRuntimeSecondsRemaining=`echo $encodeRuntimeSecondsRemaining | bc`

    echo " . done"
  fi
done

endTime=`date '+%a %d %b %Y %T %Z'`
seconds1=$(date --date "$endTime" +%s)
seconds2=$(date --date "$startTime" +%s)
delta=$((seconds1 - seconds2))
formatedTime=`printf '%dh:%dm:%ds\n' $((delta/3600)) $((delta%3600/60)) $((delta%60))`

echo " Report"
echo " ******"
echo " Number of files: $totalItems"
echo "         Runtime: $totalRuntimeFormatted"
echo "   Encoding time: $formatedTime"

cd ..
