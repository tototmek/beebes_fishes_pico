function catalogue_unlock_fish(index)
    dset(0, dget(0) | (1 << index))
end

catalogue_draw_functions = {
    bubblefish_draw,
    constellationfish_draw,
    anglerfish_draw,
    medusa_draw,
    nautilus_draw,
    naked_nautilus_draw,
    rainbowgar_draw,
    sailfin_draw,
}

catalogue_draw_positions = {
    12,  -110,
    34, -100,
    50, -50,
    16, -60,
    64, -80,
    88, -80,
    96, -100,
    100, -30,
}

catalogue_dummy_enemy = {
    x, y = 0, 0,
    dashing = false,
    lights = 3,
    exploding = 0,
    frame_ctr = 0,
    spr = 0,
}

function draw_fish(func, x, y)
    catalogue_dummy_enemy.x = x
    catalogue_dummy_enemy.y = y
    func(catalogue_dummy_enemy)
end

function display_catalogue()
    for i, draw_func in ipairs(catalogue_draw_functions) do
        local draw_x, draw_y = catalogue_draw_positions[i*2-1], catalogue_draw_positions[i*2]
        pal(2, 4)
        pal(8, 4)
        pal(14, 4)
        pal(15, 4)
        draw_fish(draw_func, draw_x-1, draw_y)
        draw_fish(draw_func, draw_x+1, draw_y)
        draw_fish(draw_func, draw_x+1, draw_y-1)
        draw_fish(draw_func, draw_x+1, draw_y+1)
        draw_fish(draw_func, draw_x-1, draw_y-1)
        draw_fish(draw_func, draw_x-1, draw_y+1)
        draw_fish(draw_func, draw_x, draw_y-1)
        draw_fish(draw_func, draw_x, draw_y+1)
        pal(2, 2)
        pal(8, 8)
        pal(14, 14)
        pal(15, 15)
        if (dget(0) >> (i - 1)) & 1 == 1 then -- fish catalogued
            draw_fish(draw_func, draw_x, draw_y)
        else
        spr(16, draw_x-3, draw_y-5)
        end
    end
end