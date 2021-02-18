#!/bin/bash

GREEN='\033[0;32m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# ALL FILE NAMES MUST BE UNIQUELY NAMED
# Try to avoid file names with spaces - else the output name will only include text before the space

# *** PARAMETERS ***
# desired photo output format
photo_format_out=".jpg"

# desired video output format
video_format_out=".mov"

# target duration of video clip - seconds ($duration_before and $factor are integers so unless the code is ammended, the target_duration is approximate)
target_duration=10

# fade duration of video clip - seconds
fade_duration=1

echo
echo -e "${CYAN}*** Starting Photo Renders ***${RESET}"
echo

# loop through all $photo_format_in images in media/in/photo_in
for file in media/in/photo_in/*;
do
  # extract base name from path and trim
  basename=$(basename $file)
  name=${basename%.*}

  # create output file names
  photo_200x200=""$name"_200x200$photo_format_out"
  photo_480x720=""$name"_480x720$photo_format_out"
  photo_720x480=""$name"_720x480$photo_format_out"
  photo_640x640=""$name"_640x640$photo_format_out"
  photo_1280xAR=""$name"_1280xAR$photo_format_out"
  photo_1920xAR=""$name"_1920xAR$photo_format_out"

  # generate photo_200x200 with width and height 200px
  ffmpeg -i "$file" -vf "crop='min(iw,1*ih)':'min(iw/1,ih)',scale=200:200" "media/out/photo_out/$photo_200x200" -n
  # generate photo_480x720 with width 480px and height 720px
  ffmpeg -i "$file" -vf "crop='min(iw,ih/1.5)':'min(1.5*iw,ih)',scale=480:720" "media/out/photo_out/$photo_480x720" -n
  # generate photo_720x480 with width 720px and height 480px
  ffmpeg -i "$file" -vf "crop='min(iw,1.5*ih)':'min(iw/1.5,ih)',scale=720:480" "media/out/photo_out/$photo_720x480" -n
  # generate photo_640x640 with width and height 640px
  ffmpeg -i "$file" -vf "crop='min(iw,1*ih)':'min(iw/1,ih)',scale=640:640" "media/out/photo_out/$photo_640x640" -n
  # generate photo_1280xAR with width 1280px
  ffmpeg -i "$file" -vf "scale=1280:-2" "media/out/photo_out/$photo_1280xAR" -n
  # generate photo_1920x1280 with width 1920px and by maintaining the original aspect ratio
  ffmpeg -i "$file" -vf "scale=1920:-2" "media/out/photo_out/$photo_1920xAR" -n


  # status log
  echo
  echo -e "${GREEN}Photo optimised: $basename${RESET}"

done

echo
echo -e "${CYAN}*** Starting Video Renders ***${RESET}"
echo

# loop through all $video_format_in videos in media/in/video_in
for file in media/in/video_in/*;
do

  # extract base name from path and trim
  basename=$(basename $file)
  name=${basename%.*}

  # create output file name
  video_1920xAR=""$name"_video_1920xAR$video_format_out"

  # calculate duration of video before alteration
  duration_before=$(ffprobe -i "$file" -show_entries format=duration -v quiet -of csv="p=0" | awk '{print int($0)}' | xargs)
  # remove white space
  duration_before="${duration_before%"${duration_before##*[![:space:]]}"}"

  # if duration_before > target_duration, determine factor. Else, set the factor to 1 (do not change speed of footage)
  if (( $duration_before > $target_duration )); then
    factor=$(($duration_before / $target_duration))
    else factor=1
  fi

  fade_out=$( expr $duration_before - $fade_duration)

  # generate video_1920xAR by performing the following operations:
  # - scale with width 1920px and by maintaining the original aspect ratio (scale=1920:-2)
  # - set watermark (overlay) in bottom right corner of video (-i watermark.png) & (overlay=x=(1920-340):y=(1080-100))
  # - set pixel format to yuv420p (4:2:0) (format=yuv420p)
  # - fade in and out by set $fade_duration (fade=d=$fade_duration,fade=t=out:st=$fade_out:d=$fade_duration)
  # - speed video up by the calculated $factor to be close to the $target_duration (setpts=PTS/$factor)
  # - remove audio (-an)
  ffmpeg -i "$file" -i "watermark.png" -lavfi "scale=1920:-2,overlay=x=(1920-340):y=(1080-100),format=yuv420p,fade=d=$fade_duration,fade=t=out:st=$fade_out:d=$fade_duration,setpts=PTS/$factor" -an "media/out/video_out/$video_1920xAR" -n

  # calculate duration of video after alteration
  duration_after=$(ffprobe -i "media/out/video_out/$video_1920xAR" -show_entries format=duration -v quiet -of csv="p=0")

  # status log
  echo
  echo -e "${GREEN}Video optimised: $basename"
  echo -e "Duration before: $duration_before"
  echo -e "Duration after: $duration_after${RESET}"
  echo

done

echo
echo -e "${PURPLE}*** Completed All Renders ***${RESET}"
