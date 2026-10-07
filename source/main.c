#include "video.h"
#include "time.h"

void main()
{
    clear_screen(color_blue);

    // Texture 0: ship64
    select_texture(0);
    select_region(0);
    define_region_topleft(0, 0, 63, 63);

    draw_region_at(180, 148);

    // Texture 1: Texture-HelloWorld
    select_texture(1);
    select_region(0);
    define_region_topleft(0, 0, 249, 49);

    draw_region_at(300, 148);

    end_frame();
}