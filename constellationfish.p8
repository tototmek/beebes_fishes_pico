function constellationfish_spawn(y)
    local enemy = {id = 2,
        hp = 1, dead = false,
        target_x = 104,
        target_y = y,
        atk_func = cocreate(constellationfish_atk),
        die_func = constellationfish_die,
        update_func = constellationfish_update,
        draw_func = constellationfish_draw,
        atk_rate = 90,
        beat_ctr = 0,
        seed = time(),
    }
    add_tf(enemy, 136, y)
    add_collider(enemy, 4, 4)
    add(enemies, enemy)
end

function constellationfish_atk(bf)
    for i=1,4 do
        yield()
        bf.target_x -= 16
    end
    bf.target_x = 136
    yield()
    yield()
    bf.dead = true
end

function constellationfish_die(bf)
    local shoot_x, shoot_y = bf.x, bf.y
    enemy_shoot(shoot_x, shoot_y, -0.5, -0.75)
    enemy_shoot(shoot_x, shoot_y, -0.8, -0.5)
    enemy_shoot(shoot_x, shoot_y, -1.0)
    enemy_shoot(shoot_x, shoot_y, -0.8, 0.5)
    enemy_shoot(shoot_x, shoot_y, -0.5, 0.75)
end

function constellationfish_update(bf)
    enemy_oscillate(bf, 12)
end

function constellationfish_draw(bf) 
    local draw_x, draw_y = flr(bf.x), flr(bf.y) - 8
    spr(9 , draw_x-8, draw_y, 1, 2)
    spr(10+time()*4%2 , draw_x, draw_y, 1, 2)
end
