#include "plot.h"
#include "config-extern.h"
#include "math.h"
#include "pow2n.h"

void plot(unsigned char pixel[], double x, double y)
{
// XCP: "X Circles Paradox" - malformed naming a bit
#if 1
    double n, r, f, xm;
    int i;
    int c;
    double p = (double)config_index / config_rate;
    double shades = 2;
    double s = pow(2, p * shades * 2.0);

    x /= s;
    y /= s;

    // This block is core of XCP
    n = floor(log(fabs(y)) / M_LN2);
    for (i = 0; i < 62; ++i, ++n)
    {
        r = pow2n[61 + (int)(n)];
        xm = fmod(fabs(x), 2.0 * r) - r;
        if (xm * xm + y * y <= r * r)
        {
            break;
        }
    }

    n = 31.0 + n;

    f = fmod(fabs(n) * (1 / (shades - 1)), shades / (shades - 1));

    c = 255 - 255 * f * (n < 0.0 ? -1.0 : 1.0);

    for (i = 0; i < 1 /* config_channels */; ++i)
    {

        pixel[i] = c;
    }

    if (config_channels == 2 || config_channels == 4)
    {
        pixel[config_channels - 1] = 255;
    }
#endif
}