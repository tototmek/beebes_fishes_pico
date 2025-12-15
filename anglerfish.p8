function anglerfish_spawn(y) --WIP
    local enemy = {
        hp = 1, dead = false,
        target_x = 104, target_y = y,
        atk_func = cocreate(anglerfish_atk),
        die_func = anglerfish_die,
        update_func = anglerfish_update,
        draw_func = anglerfish_draw,
        atk_rate = 60,
        beat_ctr = 0,
        seed = time(),
        lights = {},
    }
    enemy.lights[1] = {id=-1}
    enemy.lights[2] = {id=0}
    enemy.lights[3] = {id=1}
    add_tf(enemy, 166, y)
    add_tf(enemy.lights[1], 166, y)
    add_tf(enemy.lights[2], 166, y)
    add_tf(enemy.lights[3], 166, y)
    add_collider(enemy, 4, 4)
    add(enemies, enemy)
end

function anglerfish_atk(bf)
    for i=1,8 do
        yield()
        yield()
    end
    bf.target_x = 148
    yield()
    yield()
    yield()
    bf.dead = true
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
    tf_spring_to(bf, bf.target_x + cos(bf.seed+time()/9)*6, bf.target_y+sin(bf.seed+time()/8), 0.002)
    for light in all(bf.lights) do
        tf_update(light)
    end
end

function anglerfish_draw(bf) 
    local draw_x, draw_y = flr(bf.x) - 8, flr(bf.y) - 8
    for light in all(bf.lights) do
        line(light.x, light.y,  bf.x, bf.y - 4, 14)
        spr(50, light.x - 4, light.y - 4)
    end
    spr(32 , draw_x, draw_y, 2, 2)
    spr(34+time()*2%2 , draw_x+16, draw_y, 1, 1)
end
