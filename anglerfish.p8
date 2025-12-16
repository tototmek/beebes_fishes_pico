function anglerfish_spawn(y) --WIP
    local enemy = {
        hp = 1, dead = false,
        target_x = 104, target_y = y,
        atk_func = cocreate(anglerfish_atk),
        die_func = anglerfish_die,
        update_func = anglerfish_update,
        draw_func = anglerfish_draw,
        atk_rate = 50,
        beat_ctr = 0,
        seed = time(),
        -- lights = {},
        dashing = false,
        frame_ctr = 0,
    }
    -- enemy.lights[1] = {id=-1}
    -- enemy.lights[2] = {id=0}
    -- enemy.lights[3] = {id=1}
    add_tf(enemy, 166, y)
    -- add_tf(enemy.lights[1], 166, y)
    -- add_tf(enemy.lights[2], 166, y)
    -- add_tf(enemy.lights[3], 166, y)
    add_collider(enemy, 8, 8)
    add(enemies, enemy)
end

function anglerfish_atk(bf)
    for i=1,8 do
        anglerfish_dash(bf)
        bf.target_y = 16+rnd(112)
    end
    bf.target_x = 148
    yield()
    yield()
    yield()
    bf.dead = true
end

function anglerfish_dash(bf)
    yield()
    yield()
    sfx(6)
    bf.dx = 1.2
    yield()
    sfx(10)
    explode_small(bf.x+12, bf.y)
    bf.dx = -9
    bf.dashing = true
    yield()
    bf.dashing = false
end

function anglerfish_die(bf)
    local shoot_x, shoot_y = bf.x, bf.y
    enemy_shoot(shoot_x, shoot_y, -0.5, -0.75)
    enemy_shoot(shoot_x, shoot_y, -0.8, -0.5)
    enemy_shoot(shoot_x, shoot_y, -1.0)
    enemy_shoot(shoot_x, shoot_y, -0.8, 0.5)
    enemy_shoot(shoot_x, shoot_y, -0.5, 0.75)
end

function anglerfish_update(bf)
    tf_spring_to(bf, bf.target_x + cos(bf.seed+time()/9)*6, bf.target_y+sin(bf.seed+time()/8), 0.0008)
    for light in all(bf.lights) do
        tf_update(light)
    end
    if bf.dashing then
        particle_spawn_foam(bf.x+12, bf.y-1, -3, 0.5-rnd(1))
        particle_spawn_foam(bf.x+12, bf.y-1, -3, 0.5-rnd(1))
        if check_collision(bf, player) then
            player_get_hit()
            bf.dashing = false
        end
    end
end

function anglerfish_draw(bf) 
    local draw_x, draw_y = flr(bf.x), flr(bf.y)
    if bf.dashing then
        local rectlen = abs(bf.dx)*12
        rectfill(draw_x+6, draw_y-7, draw_x+rectlen, draw_y+3, 8)
        fillp(0b0101101001011010.1)
        rectfill(draw_x+rectlen, draw_y-7, draw_x+rectlen*1.2, draw_y+3, 8)
        fillp()
    end
    -- for light in all(bf.lights) do
    --     line(light.x, light.y,  bf.x, bf.y - 4, 14)
    --     spr(50, light.x - 4, light.y - 4)
    -- end
    spr(32 , draw_x - 8, draw_y - 8, 2, 2)
    bf.frame_ctr += 0.1*abs(bf.dx)
    spr(34+bf.frame_ctr%2 , draw_x+8, draw_y - 8, 1, 1)
end
