# Draw-XY

Lightweight image generator.  
To make own images user must change the source code.  
The code is using 2d grid, scaled down to one unit world.

# Makefile

## Env List

| Name       | Default                             | What                                                     |
| :--------- | :---------------------------------- | :------------------------------------------------------- |
| IN_WIDTH   | 1600                                | Input width                                              |
| IN_HEIGHT  | 900                                 | Input height                                             |
| OUT_WIDTH  | IN_WIDTH                            | Output width                                             |
| OUT_HEIGHT | IN_HEIGHT                           | Output height                                            |
| CHANNELS   | 4                                   | Pixel channel number (1..4: gray, ~ alpha, rgb, ~ alpha) |
| RATE       | 24                                  | Frame-rate                                               |
| LENGTH     | image: 0, frames: RATE, video: RATE | Length                                                   |
| FRAME      | 0                                   | Start frame                                              |
| INDEX      | 0                                   | Start index                                              |
| REPEAT     | 0                                   | Repeat rendered video X times                            |

## Usage

```sh
# Image target
make CHANNELS=1 image
make install && ./draw-xy.exe -c 1 | ffmpeg ...

# Frames target
make IN_WIDTH=680 IN_HEIGHT=420 frames
make install && ./draw-xy.exe -w 680 -h 420 | ffmpeg ...

# Frames target on my machine (test)
make IN_CHANNELS=1 IN_WIDTH=320 IN_HEIGHT=280 RATE=60 frames && sxiv frames

# Video target
make REPEAT=2 video

# Video target on my machine (test)
make REPEAT_VIDEO=5 IN_CHANNELS=3 IN_WIDTH=3840 IN_HEIGHT=2160 RATE=60 video && mpv --loop-file video.mp4 --video-unscaled
```

# Source Code

## Globals

```c
// config.h
#ifdef __CONFIG_EXTERN__
extern
#endif
    int config_width,
    config_height,
    config_channels,
    config_rate,
    config_frame,
    config_index,
    config_length,
    config_image_bytes,
    config_pixels_count,
    config_buffer_size;
```

## What to Change?

```c
// plot.c
#include "..."

void plot(unsigned char pixel[], double x, double y)
{
    // Your Code Here
    pixel[0] = pixel[3] = 255 * sin(x * y) / cos(y / x) / atan((double)config_index / config_rate);
}
```

# License

[GPLv3](https://www.gnu.org/licenses/gpl-3.0.txt)

**See notice in ACKNOWLEDGEMENTS.md**
