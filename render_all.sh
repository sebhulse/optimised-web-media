#!/bin/bash

PURPLE='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# ALL FILE NAMES MUST HAVE NO SPACES IN AND MUST BE UNIQUELY NAMED

echo
echo -e "${CYAN}*** Starting Portrait Photo Renders ***${RESET}"
echo

# loop through all .jpg images in media/in/photo_in/portrait
for file in media/in/photo_in/portrait/*.jpg;
do
  # extract base name from path and trim
  basename=$(basename $file)
  name=${basename%.jpg}

  # create output file names
  photo_200x200=""$name"_portrait_200x200.jpg"
  photo_480x720=""$name"_portrait_480x720.jpg"
  photo_640x640=""$name"_portrait_640x640.jpg"
  photo_1280xAR=""$name"_portrait_1280xAR.jpg"

  # generate photo_200x200 with width and height 200px
  ffmpeg -i "$file" -vf "crop='min(iw,1*ih)':'min(iw/1,ih)',scale=200:200" "media/out/photo_out/$photo_200x200" -n
  # generate photo_480x720 with width 480px and height 720px
  ffmpeg -i "$file" -vf "crop='min(iw,ih/1.5)':'min(1.5*iw,ih)',scale=480:720" "media/out/photo_out/$photo_480x720" -n
  # generate photo_640x640 with width and height 640px
  ffmpeg -i "$file" -vf "crop='min(iw,1*ih)':'min(iw/1,ih)',scale=640:640" "media/out/photo_out/$photo_640x640" -n
  # generate photo_1280xAR with width 1280px
  ffmpeg -i "$file" -vf "scale=1280:-2" "media/out/photo_out/$photo_1280xAR" -n


  # status log
  echo
  echo "Photo optimised: $basename"

done

echo
echo -e "${CYAN}*** Starting Landscape Photo Renders ***${RESET}"
echo

# loop through all .jpg images in media/in/photo_in/landscape
for file in media/in/photo_in/landscape/*.jpg;
do
  # extract base name from path and trim
  basename=$(basename $file)
  name=${basename%.jpg}

  # create output file names
  photo_200x200=""$name"_landscape_200x200.jpg"
  photo_720x480=""$name"_landscape_720x480.jpg"
  photo_640x640=""$name"_landscape_640x640.jpg"
  photo_1920xAR=""$name"_landscape_1920xAR.jpg"

  # generate photo_200x200 with width and height 200px
  ffmpeg -i "$file" -vf "crop='min(iw,1*ih)':'min(iw/1,ih)',scale=200:200" "media/out/photo_out/$photo_200x200" -n
  # generate photo_720x480 with width 720px and height 480px
  ffmpeg -i "$file" -vf "crop='min(iw,1.5*ih)':'min(iw/1.5,ih)',scale=720:480" "media/out/photo_out/$photo_720x480" -n
  # generate photo_640x640 with width and height 640px
  ffmpeg -i "$file" -vf "crop='min(iw,1*ih)':'min(iw/1,ih)',scale=640:640" "media/out/photo_out/$photo_640x640" -n
  # generate photo_1920x1280 with width 1920px and by maintaining the original aspect ratio
  ffmpeg -i "$file" -vf "scale=1920:-2" "media/out/photo_out/$photo_1920xAR" -n

  # status log
  echo
  echo "Photo optimised: $basename"

done

echo
echo -e "${CYAN}*** Starting Video Renders ***${RESET}"
echo

# loop through all .mov videoa in media/in/video_in
for file in media/in/video_in/*.mov;
do

  # extract base name from path and trim
  basename=$(basename $file)
  name=${basename%.mov}

  # create file name
  video_1920xAR=""$name"_video_1920xAR.mov"

  # calculate duration of video before alteration
  duration_before=$(ffprobe -i "$file" -show_entries format=duration -v quiet -of csv="p=0" | awk '{print int($0)}' | xargs)
  # remove white space
  duration_before="${duration_before%"${duration_before##*[![:space:]]}"}"

  # target duration of clip - seconds ($duration_before and $factor are integers so unless the code is ammended, the target_duration is approximate)
  target_duration=10

  # if duration_before > target_duration, determine factor. Else, set the factor to 1 (do not change speed of footage)
  if (( $duration_before > $target_duration )); then
    factor=$(($duration_before / $target_duration))
    else factor=1
  fi

  # fade duration - seconds
  fade_duration=1
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
  echo "Video optimised: $basename"
  echo "Duration before: $duration_before"
  echo "Duration after: $duration_after"
  echo

done

echo
echo -e "${PURPLE}*** Completed All Renders ***${RESET}"
