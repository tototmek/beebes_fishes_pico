function catalogue_unlock_fish(index)
    dset(0, dget(0) | (1 << index))
end

function bubblefish1_draw_wrapper(bf)
    bf.spr = 7
    bubblefish_draw(bf)
end

function bubblefish2_draw_wrapper(bf) 
    bf.spr = 60
    bubblefish_draw(bf)
end


function bathysphaera_draw_mock(bf)
    local length = 50
    local draw_x, draw_y = bf.x, bf.y
    for i=length,1,-1 do
        local seg_x, seg_y = bf.x + i*2, bf.y
        if i > length * 0.98 then
            spr(46, seg_x-4, seg_y-8)
            spr(46, seg_x-4, seg_y, 1, 1, false, true)
        elseif i > length * 0.825 then
            spr(44, seg_x-4, seg_y-8)
            spr(44, seg_x-4, seg_y, 1, 1, false, true)
        elseif i > length * 0.80 then
            spr(45, seg_x-4, seg_y-8)
            spr(45, seg_x-4, seg_y, 1, 1, false, true)
        else
            if i%6 == 4 then
                spr(59, seg_x-4, seg_y-4)
            else
                spr(58, seg_x-4, seg_y-4)
            end
        end
    end
    line(draw_x, draw_y+3, draw_x+3, draw_y+6, 8)
    line(draw_x+3, draw_y+6, draw_x+8, draw_y+8)
    line(draw_x+8, draw_y+8, draw_x+44, draw_y+8)
    line(draw_x+55, draw_y+3, draw_x+58, draw_y+6, 8)
    line(draw_x+58, draw_y+6, draw_x+63, draw_y+9)
    line(draw_x+63, draw_y+9, draw_x+100, draw_y+9)
    spr(41, draw_x-10, draw_y-4, 2, 1)
    spr(43, draw_x+100, draw_y-4)
    spr(24, draw_x+40, draw_y+4)
    spr(24, draw_x+100, draw_y+5)
end

catalogue_draw_functions = {
    bubblefish1_draw_wrapper,
    constellationfish_draw,
    anglerfish_draw,
    medusa_draw,
    nautilus_draw,
    naked_nautilus_draw,
    rainbowgar_draw,
    sailfin_draw,
    bathysphaera_draw_mock,
    bubblefish2_draw_wrapper,
}

catalogue_names = {
    "bubblefish",
    "five-striped constellation fish",
    "three-starred anglerfish",
    "medusa",
    "nautilus",
    "naked nautilus",
    "abyssal rainbow gar",
    "pallid sailfin",
    "giant dragonfish",
    "bubblefish2",
}

catalogue_draw_positions = {}

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

for i = 1,10 do
    catalogue_draw_positions[2*i-1] = 16
    catalogue_draw_positions[2*i] = -128 + 12 * i
end
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
        print(catalogue_names[i], draw_x + 22, draw_y - 8, 7)
    end
end