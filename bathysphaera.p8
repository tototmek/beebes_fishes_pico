function bathysphaera_spawn(y)
    local enemy = {id = 9,
        hp = 30, dead = false,
        target_x = 136, target_y = y,
        atk_func = cocreate(bathysphaera_atk),
        die_func = bathysphaera_die,
        update_func = bathysphaera_update,
        draw_func = bathysphaera_draw,
        hit_func = bathysphaera_get_hit,
        atk_rate = 100,
        beat_ctr = 0,
        seed = time() + rnd(1),
        frame_ctr = 0,
        prev_x = {},
        prev_y = {},
        length = 75,
        exploding = 0,
        line_points_x = {},
        line_points_y = {},
        line_end_1_x = 0,
        line_end_2_x = 0,
        line_end_1_y = 0,
        line_end_2_y = 0,
    }
    for i=1,enemy.length*2 do
        enemy.prev_x[i] = 136
        enemy.prev_y[i] = y
    end
    for i=1,20 do
        enemy.line_points_x[i] = 286
        enemy.line_points_y[i] = y
    end
    add_tf(enemy, 136, y)
    add_collider(enemy, 4, 4)
    add(enemies, enemy)
end

function bathysphaera_atk(bf)
    while true do
        local shoot_x, shoot_y = bf.line_end_1_x, bf.line_end_1_y
        if shoot_x < 128 then
            enemy_shoot(shoot_x, shoot_y, -0.8, -0.5)
            enemy_shoot(shoot_x, shoot_y, -1.0)
            enemy_shoot(shoot_x, shoot_y, -0.8, 0.5)
        end
        yield()
        local shoot_x, shoot_y = bf.line_end_2_x, bf.line_end_2_y
        if shoot_x < 128 then
            enemy_shoot(shoot_x, shoot_y, -0.8, -0.5)
            enemy_shoot(shoot_x, shoot_y, -1.0)
            enemy_shoot(shoot_x, shoot_y, -0.8, 0.5)
            yield()
        end
    end
end

function bathysphaera_get_hit(bf, bullet, i)
    bf.exploding = 10
    explode_big(bullet.x+6, bullet.y)
    bf.hp -= 1
    sfx(5)
    deli(player_bullets, i)
    bf.length = 3*(bf.hp+1)
end

function bathysphaera_die(bf)
    explode_big(bf.x, bf.y)
    explode_big(bf.line_end_1_x, bf.line_end_1_y)
    explode_big(bf.line_end_2_x, bf.line_end_2_y)
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
    for i = 1,bf.length do
        for k, bullet in ipairs(player_bullets) do
            if abs(bullet.x - bf.prev_x[i]) < 2 and abs(bullet.y - bf.prev_y[i]) < 2 do
                bathysphaera_get_hit(bf, bullet, k)
            end
        end
    end
    bf.line_points_x[1] = bf.x 
    bf.line_points_y[1] = bf.y+6
    bf.line_points_x[2] = bf.prev_x[flr(0.75*bf.length)] 
    bf.line_points_y[2] = bf.prev_y[flr(0.75*bf.length)]+8
    for i=3,20,2 do
        bf.line_points_x[i] += 0.04 * (bf.line_points_x[i-2] - bf.line_points_x[i]) - 0.1
        bf.line_points_y[i] += 0.04 * (bf.line_points_y[i-2] - bf.line_points_y[i]) + 0.02
        bf.line_points_x[i+1] += 0.04 * (bf.line_points_x[i-1] - bf.line_points_x[i+1]) - 0.1
        bf.line_points_y[i+1] += 0.04 * (bf.line_points_y[i-1] - bf.line_points_y[i+1]) + 0.02
    end
    bf.line_points_y[3] += 0.1
    bf.line_points_y[4] += 0.15
    bf.line_end_1_x = bf.line_points_x[#bf.line_points_x-1]
    bf.line_end_2_x = bf.line_points_x[#bf.line_points_x]
    bf.line_end_1_y = bf.line_points_y[#bf.line_points_y-1]
    bf.line_end_2_y = bf.line_points_y[#bf.line_points_y]
end

function bathysphaera_draw(bf)  
    if bf.exploding > 0 then
        pal(2, 7)
        pal(8, 7)
        pal(14, 7)
    end
    line(flr(bf.line_points_x[2]), flr(bf.line_points_y[2]), bf.prev_x[flr(0.75*bf.length)], bf.prev_y[flr(0.75*bf.length)]+3, 8)
    for i=3,20,2 do
        line(flr(bf.line_points_x[i-1]), flr(bf.line_points_y[i-1]), flr(bf.line_points_x[i+1]), flr(bf.line_points_y[i+1]))
    end
    spr(24, bf.line_end_2_x-4, bf.line_end_2_y-4)
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
    line(flr(bf.line_points_x[1]), flr(bf.line_points_y[1]), bf.x, bf.y+3, 8)
    for i=3,20,2 do
        line(flr(bf.line_points_x[i-2]), flr(bf.line_points_y[i-2]), flr(bf.line_points_x[i]), flr(bf.line_points_y[i]))
    end
    spr(24, bf.line_end_1_x-4, bf.line_end_1_y-4)
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
