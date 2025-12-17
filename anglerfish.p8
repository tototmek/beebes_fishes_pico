function anglerfish_spawn(y)
    local enemy = {id = 2,
        hp = 3, dead = false,
        target_x = 104, target_y = y,
        atk_func = cocreate(anglerfish_atk),
        die_func = anglerfish_die,
        update_func = anglerfish_update,
        draw_func = anglerfish_draw,
        hit_func = anglerfish_hit,
        atk_rate = 40,
        beat_ctr = 0,
        seed = time(),
        -- lights = {},
        dashing = false,
        exploding = 0,
        frame_ctr = 0,
        lights_out = false,
        lights = 3,
    }
    -- enemy.lights[1] = {id=-1}
    -- enemy.lights[2] = {id=0}
    -- enemy.lights[3] = {id=1}
    add_tf(enemy, 166, y)
    -- add_tf(enemy.lights[1], 166, y)
    -- add_tf(enemy.lights[2], 166, y)
    -- add_tf(enemy.lights[3], 166, y)
    add_collider(enemy, 2, 7)
    add(enemies, enemy)
end

function anglerfish_atk(bf)
    yield()
    for k = 1,9 do
        for i=1,4 do -- random dashes
            yield()
            anglerfish_dash(bf)
            bf.target_y = min(max(39,player.y + player.dy * 8 + rnd(16) - 8),112)
        end
        yield()
        yield()
        yield()
        anglerfish_light_spawn(bf) -- spawn the light
        while (bf.lights_out) do
            yield()
        end
    end
    bf.target_x = 148
    yield()
    yield()
    yield()
    bf.dead = true
end

function anglerfish_dash(bf)
    yield()
    sfx(6)
    bf.dy = 0
    bf.dx = 1.2
    yield()
    sfx(9)
    explode_small(bf.x+12, bf.y)
    bf.dx = -9
    bf.dashing = true
    yield()
    bf.dashing = false
end

function anglerfish_die(bf)
    explode_big(bf.x, bf.y)
end

function anglerfish_update(bf)
    if bf.exploding > 0 then
        bf.exploding -= 1
        if rnd(1) < 0.05 then
            explode_small(bf.x - 16 + rnd(32), bf.y - 16 + rnd(32))
        end
    end
    if bf.dashing then
        particle_spawn_foam(bf.x+12, bf.y-2, -3, 0.5-rnd(1))
        particle_spawn_foam(bf.x+12, bf.y-2, -3, 0.5-rnd(1))
        if check_collision(bf, player) then
            player_get_hit()
            bf.dashing = false
        end
    else
        tf_spring_to(bf, bf.target_x + cos(bf.seed+time()/9)*6, bf.target_y+sin(bf.seed+time()/8), 0.0014)
    end
end

function anglerfish_hit(enemy, bullet, i)
    sfx(11)
    particle_spawn_torpedo(bullet.x, bullet.y, (bullet.y - enemy.y)/8)
    deli(player_bullets, i)
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
    if bf.exploding > 30 then
        pal(2, 7)
        pal(8, 7)
        pal(14, 7)
        draw_x += rnd(2)-2
        draw_y += rnd(2)-2
    end
    for i = 1,bf.lights do
        spr(50 , draw_x + 4-2*i, draw_y - 9-2*i, 1, 1) -- draw lights
    end
    spr(32 , draw_x - 8, draw_y - 8, 2, 2)
    bf.frame_ctr += 0.1*abs(bf.dx)
    spr(34+bf.frame_ctr%2 , draw_x+8, draw_y - 8, 1, 1)
    if bf.exploding > 30 then
        pal(2, 2)
        pal(8, 8)
        pal(14, 14)
    end
end



function anglerfish_light_spawn(anglerfish)
    local enemy = {
        hp = 1, dead = false,
        atk_func = cocreate(anglerfish_light_atk),
        die_func = anglerfish_light_die,
        update_func = anglerfish_light_update,
        draw_func = anglerfish_light_draw,
        atk_rate = 80,
        beat_ctr = 0,
        seed = time(),
        parent = anglerfish,
        returning = false,
    }
    anglerfish.lights -= 1
    anglerfish.lights_out = true
    add_tf(enemy, anglerfish.x-1, anglerfish.y-10)
    add_collider(enemy, 4, 4)
    add(enemies, enemy)
end

function anglerfish_light_update(bf)
    if bf.returning == true then 
        tf_spring_to(bf, bf.parent.x-1, bf.parent.y-10, 0.002)
    else
        tf_spring_to(bf, bf.parent.x-20+sin(time()/2)*8, bf.parent.y-32+cos(time()/2.1)*8, 0.0015)
    end
end

function anglerfish_light_die(bf)
    bf.parent.lights_out = false
    bf.parent.hp -= 1
    bf.parent.exploding = 100
    explode_small(bf.parent.x, bf.parent.y-8)
end

function anglerfish_light_draw(bf)
    sx, sy = bf.x, bf.y
    dx, dy = bf.parent.x+2-bf.parent.lights*2 - sx, bf.parent.y-9 - sy
    line(sx, sy, sx+0.5*dx, sy+0.125*dy, 8)
    line(sx+0.5*dx, sy+0.125*dy, sx+0.75*dx, sy+0.3*dy)
    line(sx+0.75*dx, sy+0.3*dy, sx+0.9*dx, sy+0.6*dy)
    line(sx+0.9*dx, sy+0.6*dy, sx+dx, sy+dy, 8)
    spr(24, bf.x-4, bf.y-4)
end

function anglerfish_light_atk(bf)
    for i=1,5 do
        local shoot_x, shoot_y = bf.x, bf.y
        enemy_shoot(shoot_x, shoot_y, -0.8, -0.75)
        enemy_shoot(shoot_x, shoot_y, -1.0, -0.25)
        enemy_shoot(shoot_x, shoot_y, -1.0, 0.25)
        enemy_shoot(shoot_x, shoot_y, -0.8, 0.75)
        yield()
    end
    bf.returning = true
    yield()
    bf.parent.lights_out = false
    bf.parent.lights += 1
    bf.dead = true
end