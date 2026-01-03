function catalogue_unlock_fish(index)
    dset(0, dget(0) | (1 << (index-1)))
end

function bubblefish1_draw_wrapper(bf)
    bf.spr = 7
    bubblefish_draw(bf)
end

function bubblefish2_draw_wrapper(bf) 
    bf.spr = 60
    bubblefish_draw(bf)
end

function medusa_draw_wrapper(bf) 
    bf.spr = 1
    medusa_draw(bf)
end


function bathysphaera_draw_mock(bf)
    local length = 40
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
    medusa_draw_wrapper,
    bubblefish2_draw_wrapper,
    nautilus_draw,
    naked_nautilus_draw,
    rainbowgar_draw,
    sailfin_draw,
    grenadier_draw,
    bathysphaera_draw_mock,
}

catalogue_names = {
    "hatchetfish",
    "five-striped constellation fish",
    "three-starred anglerfish",
    "giant jelly",
    "manefish",
    "nautilus",
    "naked nautilus",
    "abyssal rainbow gar",
    "pallid sailfin",
    "pacific grenadier",
    "giant dragonfish",
}

catalogue_surnames = {
    "argyropelecus aculeatus",
    "bathysidus pentagrammus",
    "bathyceratias trilynchnus",
    "stygiomedusa gigantea",
    "platyberyx opalescens",
    "nautilus belauensis",
    "nautilus nudus",
    "abyssobelonidus atlanticus",
    "bathyembryx istiophasma",
    "coryphaenoides acrolepis",
    "bathysphaera intacta",
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

function create_catalogue()
    catalogue_fish_pos = {}
    add_tf(catalogue_fish_pos)
    catalogue_fish_pos.drag = 0.5
    selected_fish = 1
end

function display_catalogue()
    tf_spring_to(catalogue_fish_pos, -selected_fish*64, nil, 0.03)
    tf_update(catalogue_fish_pos)
    local y_offset = 6
    circfill(64,-60+y_offset,23,4)
    local unlocked = 0
    
    for i, draw_func in ipairs(catalogue_draw_functions) do
        local draw_x, draw_y = catalogue_fish_pos.x + i*64, -54 + y_offset
        draw_x = atan2(draw_x/64, 1) * 300 - 160
        if i == selected_fish then
            draw_y -= 8
        end
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
            unlocked += 1
            draw_fish(draw_func, draw_x, draw_y)
            if i == selected_fish then
                textlen = print(catalogue_names[i], 0, 200)
                print(catalogue_names[i], 64-textlen/2+1, -41+y_offset, 4)
                print(catalogue_names[i], 64-textlen/2, -42+y_offset, 6)
                textlen = print(catalogue_surnames[i], 0, 200)
                print(catalogue_surnames[i], 64-textlen/2+1, -83+y_offset, 4)
                print(catalogue_surnames[i], 64-textlen/2, -84+y_offset, 7)
            end
        else
            if i == selected_fish then
                print("?????", 55, -41+y_offset, 6)
                print("?????", 55, -84+y_offset, 7)
            end
            spr(16, draw_x-3, draw_y-5)
        end
    end

    spr(128, 39, -127, 6, 4) --print game title
    print("fish catalogue", 36, -99, 1)
    print("fish catalogue", 37, -100, 1)
    print("fish catalogue", 38, -99, 1)
    print("fish catalogue", 38, -98, 4)
    print("fish catalogue", 37, -99, 7)

    if selected_fish > 1 then
        spr(150, 2, -79)
    end
    if selected_fish < #catalogue_draw_functions then
        spr(150, 118, -79, 1, 1, true)
    end

    print(unlocked.."/"..#catalogue_draw_functions.." unlocked", 71, -8)
end