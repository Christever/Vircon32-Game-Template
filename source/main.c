#include "video.h"


void main()
{
    while (1)
    {
        clear_screen(color_darkgray);
        print_at(250, 160, "HELLO WORLD");
        end_frame();
    }
}