#!/bin/sh

BR=96k

#ffmpeg -i $1 -acodec libmp3lame -ar 48000 -ab 64k -s 320×180 -vcodec libx264 -b $BR -flags +loop -cmp +chroma -partitions +parti4x4+partp8x8+partb8x8 -subq 5 -trellis 1 -refs 1 -coder 0 -me_range 16 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -bt 200k -maxrate $BR -bufsize $BR -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -level 30 -g 30 -async 2 sample$BR._pre.ts
ffmpeg -i $1 -threads 0 -acodec libmp3lame -ar 48000 -ab 64k -vcodec libx264 -vpre medium -s 320x180 -b $BR -maxrate $BR -bufsize $BR sample$BR._pre.ts

/home/ayl/rails/mediaManager/lib/aaron/segmenter sample$BR._pre.ts 10 video_$BR stream-$BR.m3u8 $2

rm -f sample$BR._pre.ts


BR=128k

#ffmpeg -i $1 -acodec libmp3lame -ar 48000 -ab 64k -s 320×180 -vcodec libx264 -b $BR -flags +loop -cmp +chroma -partitions +parti4x4+partp8x8+partb8x8 -subq 5 -trellis 1 -refs 1 -coder 0 -me_range 16 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -bt 200k -maxrate $BR -bufsize $BR -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -level 30 -g 30 -async 2 sample$BR._pre.ts
ffmpeg -i $1 -threads 0 -acodec libmp3lame -ar 48000 -ab 64k -vcodec libx264 -vpre medium -s 320x180 -b $BR -maxrate $BR -bufsize $BR sample$BR._pre.ts

/home/ayl/rails/mediaManager/lib/aaron/segmenter sample$BR._pre.ts 10 video_$BR stream-$BR.m3u8 $2

rm -f sample$BR._pre.ts

BR=384k

#ffmpeg -i $1 -acodec libmp3lame -ar 48000 -ab 64k -s 320×180 -vcodec libx264 -b $BR -flags +loop -cmp +chroma -partitions +parti4x4+partp8x8+partb8x8 -subq 5 -trellis 1 -refs 1 -coder 0 -me_range 16 -keyint_min 25 -sc_threshold 40 -i_qfactor 0.71 -bt 200k -maxrate $BR -bufsize $BR -rc_eq 'blurCplx^(1-qComp)' -qcomp 0.6 -qmin 10 -qmax 51 -qdiff 4 -level 30 -g 30 -async 2 sample$BR._pre.ts
ffmpeg -i $1 -threads 0 -acodec libmp3lame -ar 48000 -ab 64k -vcodec libx264 -vpre medium -s 320x180 -b $BR -maxrate $BR -bufsize $BR sample$BR._pre.ts

/home/ayl/rails/mediaManager/lib/aaron/segmenter sample$BR._pre.ts 10 video_$BR stream-$BR.m3u8 $2

rm -f sample$BR._pre.ts


echo "#EXTM3U
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=96000
$2stream-96k.m3u8
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=128000
$2stream-128k.m3u8
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=384000
$2stream-384k.m3u8" > varpl.m3u8

