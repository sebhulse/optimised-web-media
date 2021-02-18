# README

## Automate and Optimise Your Web Media Delivery Workflow with FFMPEG

This nifty bash script is intended to create lower file size (and lower quality) media - with or without watermarks - for use online where, for example, 20MB jpegs or 5GB video clips aren't welcome. The output files and formats can be adjusted as required by amending the FFMPEG commands.

See this blog post for a comprehensive overview of the FFMPEG commands, how to adjust them to your needs and for photo and video examples!

## Output

It takes photos and videos (in most formats) from the `photo_in` and `video_in`  directories, and spits out the following for each input file in that directory:

### Photo (all are cropped about the centre if the aspect ratio differs):

1. 200x200px (square)
2. 480x720px (portrait)
3. 720x480px (landscape)
4. 640x640px (square)
5. 1280xAR (width is 1280px and the original aspect ratio is maintained)
6. 1920xAR (width is 1920px and the original aspect ratio is maintained)

### Video:

1. 1920xAR (width is 1920px and the original aspect ratio is maintained - e.g. if input video is 16:9, this outputs 1080p)

The video render also does the following:

- Scale with width 1920px and by maintaining the original aspect ratio
- Set watermark (overlay) in bottom right corner of video
- Set pixel format to yuv420p (4:2:0)
- Fade in and out by a set `$fade_duration`
- Speed video up (or slow down) by the calculated `$factor` to be the approximate `$target_duration`
- Remove audio

## Install and Run

To use this tool: 

**First,** install FFMPEG:

Using Git (recommended):

```bash
git clone https://git.ffmpeg.org/ffmpeg.git ffmpeg
```

Or, on MacOS with brew:

```bash
brew install ffmpeg
```

Or, on Linux with pip:

```bash
sudo apt-get install ffmpeg
```

**Second,** clone this git repository or download the ZIP and locate it to a suitable location.

```bash
git clone https://github.com/zero45/optimised-web-media.git
```

**Third,** change the relevant FFMPEG filters - if any of the above operations are not required, amend the script as desired.

**Fourth,** if you're converting video, change the default `watermark.png` to your own, or delete the overlay function from the FFMPEG command.

**Fifth,** change the relevant parameters -  `$photo_format_out`,  `$video_format_out`, `$target_duration` and `$fade_duration`. If the `$fade_duration` is set as `1`, the video will fade in by `1` second and fade out by `1` second.

**Sixth,** place the input media into either `media/in/photo_in` or `media/in/video_in`, and ensure that the filenames are unique and without spaces.

**Seventh,** it's go time! Run the script in the command line terminal by navigating to the `optimised-web-media` directory with:

```bash
cd <file path to optimised-web-media>
```

Then execute `render_all.sh`:

```bash
bash render_all.sh
```

This will render all of the input media to the output formats specified in the parameters section of `render_all.sh`. If you need media in more formats, you can simply change the output parameters and re-run the script. 

**Finally,** navigate to the `media/out/photo_out` and `media/out/video_out` directories to see your renders.

You're done! Now just feast your eyes on those beautiful (ly reduced) pixels and get uploading!
