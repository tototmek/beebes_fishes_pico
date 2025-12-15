function bkgr_init()
    bkgr_back = {
        speed = -level_speed / 18,
        x = {63, 127, 190},
        loc = {0, 1, 2},
        map_start_x = 0,
        map_start_y = 0,
        map_size_x = 5,
        map_size_y = 3,
        map_n = 3,
        respawn_x = 127,
        random = 0
    }
    bkgr_front = {
        speed = -level_speed / 4,
        x = {127, 61},
        loc = {0, 2},
        map_start_x = 0,
        map_start_y = 3,
        map_size_x = 5,
        map_size_y = 6,
        map_n = 5,
        respawn_x = 132,
        random = 0
    }
    bkgr_mid = {
        speed = -level_speed / 3,
        x = {},
        loc = {},
        map_start_x = 9,
        map_start_y = 9,
        map_size_x = 1,
        map_size_y = 8,
        map_n = 4,
        respawn_x = 127,
        random = 0.8,
    }
    for i=1,10 do
        add(bkgr_mid.x, rnd(127))
        add(bkgr_mid.loc, i*21.37%bkgr_mid.map_n)
    end
    end
    
    function bkgr_update()
        bkgr_update_internal(bkgr_back)
        bkgr_update_internal(bkgr_front)
        bkgr_update_internal(bkgr_mid)
    end
    
    function bkgr_draw()
        bkgr_draw_internal(bkgr_back, 16)
        bkgr_draw_internal(bkgr_front, 8)
        bkgr_draw_internal(bkgr_mid, 26)
    end
    
    function bkgr_update_internal(layer)
        for i, x in ipairs(layer.x) do
            layer.x[i] += (1 + i/#layer.x * layer.random) * layer.speed
            if layer.x[i] < -layer.map_size_x*8 then
                layer.x[i] = layer.respawn_x
                layer.loc[i] = flr(rnd(layer.map_n))
            end
        end
    end
    
    function bkgr_draw_internal(layer, y)
        for i, x in pairs(layer.x) do
            bkg_draw_y = y + i/#layer.x * layer.random * 48
            map(layer.map_start_x+layer.loc[i]*layer.map_size_x, layer.map_start_y, flr(x), y + i/#layer.x * layer.random * 32, layer.map_size_x, layer.map_size_y)
        end
    end
    
    