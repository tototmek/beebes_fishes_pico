function bathysphaera_spawn(y)
    local enemy = {id = 9,
        hp = 24, dead = false,
        target_x = 136, target_y = y,
        atk_func = cocreate(bathysphaera_atk),
        die_func = empty_func,
        update_func = bathysphaera_update,
        draw_func = bathysphaera_draw,
        hit_func = bathysphaera_get_hit,
        atk_rate = 70,
        beat_ctr = 0,
        seed = time() + rnd(1),
        frame_ctr = 0,
        prev_x = {},
        prev_y = {},
        length = 75,
        exploding = 0,
    }
    for i=1,enemy.length*2 do
        enemy.prev_x[i] = 136
        enemy.prev_y[i] = y
    end
    add_tf(enemy, 136, y)
    add_collider(enemy, 4, 4)
    add(enemies, enemy)
end

function bathysphaera_atk(bf)
end

function bathysphaera_get_hit(bf, bullet, i)
    bf.exploding = 10
    explode_big(bullet.x+6, bullet.y)
    bf.hp -= 1
    sfx(5)
    deli(player_bullets, i)
    bf.length = 3*(bf.hp+1)
end

function bathysphaera_update(bf)
    bf.frame_ctr += 0.001
    local sin_t, cos_t = sin(bf.frame_ctr), cos(bf.frame_ctr)
    bf.target_x, bf.target_y = 120 + 32*sin_t*cos_t - 48*sin_t*sin_t, 64 + 52*sin_t
    tf_spring_to(bf, bf.target_x, bf.target_y, 0.0005)
    if (bf.frame_ctr % 0.0012 == 0) then
        bf.prev_x[1] = bf.x
        bf.prev_y[1] = bf.y
        for i=bf.length-1,1,-1 do
            -- bf.prev_x[i] = bf.prev_x[i] + 0.1*(bf.prev_x[i-1]-bf.prev_x[i])
            -- bf.prev_y[i] = bf.prev_y[i] + 0.1*(bf.prev_y[i-1]-bf.prev_y[i])
            bf.prev_x[i+1] = bf.prev_x[i]
            bf.prev_y[i+1] = bf.prev_y[i]
        end
    end
    if bf.exploding > 0 then
        bf.exploding -= 1
    end
    for i, x in ipairs(bf.prev_x) do
        for k, bullet in ipairs(player_bullets) do
            if abs(bullet.x - x) < 2 and abs(bullet.y - bf.prev_y[i]) < 2 do
                bathysphaera_get_hit(bf, bullet, k)
            end
        end
    end
end

function bathysphaera_draw(bf)  
    if bf.exploding > 0 then
        pal(2, 7)
        pal(8, 7)
        pal(14, 7)
    end
    local flip_tail =  bf.prev_x[bf.length] < bf.prev_x[bf.length-1]
    local offset = 3
    if (flip_tail) offset = -3
    spr(43, bf.prev_x[bf.length]-4+offset, bf.prev_y[bf.length]-4, 1, 1, flip_tail)
    local draw_x, draw_y = flr(bf.x), flr(bf.y)
    for i=bf.length,1,-1 do
        local seg_x, seg_y = flr(bf.prev_x[i]), flr(bf.prev_y[i])
        if i > bf.length * 0.98 then
            spr(46, seg_x-4, seg_y-8)
            spr(46, seg_x-4, seg_y, 1, 1, false, true)
        elseif i > bf.length * 0.825 then
            spr(44, seg_x-4, seg_y-8)
            spr(44, seg_x-4, seg_y, 1, 1, false, true)
        elseif i > bf.length * 0.80 then
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
    if bf.dx > 0.12 then
        spr(41, draw_x-7, draw_y-4, 2, 1, true)
    elseif bf.dx < -0.15 then
        spr(41, draw_x-10, draw_y-4, 2, 1)
    else
        spr(57, draw_x-4, draw_y-4, 1, 1, true)
    end
    if bf.exploding > 0 then
        pal(2, 2)
        pal(8, 8)
        pal(14, 14)
    end
end
