function constellationfish_spawn(y)
    local enemy = {
        hp = 1, dead = false,
        target_x = 104,
        atk_func = cocreate(constellationfish_atk),
        die_func = constellationfish_die,
        update_func = constellationfish_update,
        draw_func = constellationfish_draw,
        atk_rate = 2,
        beat_ctr = 0,
    }
    add_tf(enemy, 136, y)
    add_collider(enemy, 4, 4)
    add(enemies, enemy)
end

function constellationfish_atk(bf)
    for i=1,5 do
        for i=1,40 do
            yield()
        end
        enemy_shoot(bf.x, bf.y, -1.0, -0.5)
        yield()
        enemy_shoot(bf.x, bf.y, -1.2, 0)
        yield()
        enemy_shoot(bf.x, bf.y, -1.0, 0.5)
        bf.dx+=0.6
        for i=1,20 do
            yield()
        end
    end
    bf.target_x = 148
    for i=1,90 do
        yield()
    end
    bf.dead = true
    yield()
end

function constellationfish_die(bf)
end

function constellationfish_update(bf)
    enemy_update(bf)
    tf_spring_to(bf, bf.target_x + cos(2137+time()/19)*16, player.y + sin(time()/18)*16, 0.001, 0.0005)
    tf_update(bf)
end

function constellationfish_draw(bf) 
    local draw_x, draw_y = flr(bf.x), flr(bf.y) - 8
    spr(9 , draw_x-8, draw_y, 1, 2)
    spr(10+time()*4%2 , draw_x, draw_y, 1, 2)
end