#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

char *argv0;

#include "arg.h"
#include "config-extern.h"
#include "config.h"
#include "plot.h"

static unsigned char *buffer = NULL;

void config_default(void);
void config_options(int argc, char *argv[]);
void config_init(void);
void buffer_create(void);
void draw(void);
void buffer_destroy(void);

int main(int argc, char *argv[])
{
    config_default();
    config_options(argc, argv);
    config_init();
    buffer_create();
    draw();
    buffer_destroy();
    return 0;
}

void config_default(void)
{
    config_width = 1600;
    config_height = 900;
    config_channels = 4;
    config_rate = 24;
    config_frame = 0;
    config_index = 0;
    config_length = 1;
}

void config_options(int argc, char *argv[])
{
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wnonnull"
    ARGBEGIN
    {
    case 'w':
        config_width = atoi(ARGF());
        break;
    case 'h':
        config_height = atoi(ARGF());
        break;
    case 'c':
        config_channels = atoi(ARGF());
        break;
    case 'f':
        config_frame = atoi(ARGF());
        break;
    case 'r':
        config_rate = atoi(ARGF());
        break;
    case 'l':
        config_length = atoi(ARGF());
        break;
    case 'i':
        config_index = atoi(ARGF());
        break;
    }
    ARGEND;
#pragma GCC diagnostic pop
}

void config_init(void)
{
    config_pixels_count = config_width * config_height;
    config_image_bytes = config_pixels_count * config_channels;
    config_buffer_size = config_width * config_channels;
}

void buffer_create(void)
{
    buffer = malloc(config_image_bytes);
}

void draw(void)
{
    int x, y;
    double dw = config_width - 1, dh = config_height - 1;
    double x0 = config_width > config_height ? -dw / dh : -1.0, py = config_height > config_width ? dh / dw : 1.0;
    double xs = -2.0 * x0 / dw, ys = 2.0 * py / dh;
    double px;

    for (y = 0; y < config_height; ++y)
    {
        px = x0;

        memset(buffer, 0, config_buffer_size);

        for (x = 0; x < config_width; ++x)
        {
            plot(buffer + x * config_channels, px, py);

            px += xs;
        }

        fwrite(buffer, 1, config_buffer_size, stdout);

        py -= ys;
    }
}

void buffer_destroy(void)
{
    free(buffer);
}
