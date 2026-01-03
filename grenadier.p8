function grenadier_spawn(y)
    local enemy = {id = 10,
        hp = 1, dead = false,
        target_x = 104, target_y = y,
        atk_func = cocreate(grenadier_atk),
        die_func = empty_func,
        update_func = grenadier_update,
        draw_func = grenadier_draw,
        atk_rate = 40,
        beat_ctr = 0,
        seed = time(),
    }
    add_tf(enemy, 136, y)
    add_collider(enemy, 8, 4)
    add(enemies, enemy)
end

function grenadier_atk(bf)
    for i=1,3 do
        for i=1,3 do
            enemy_shoot(bf.x-4, bf.y, -0.6, -1.2, 0.02)
            bf.dx -= 0.3
            bf.dy -= 0.5
            yield()
        end
        yield()
        yield()
        yield()
    end
    bf.target_x = 148
    yield()
    yield()
    bf.dead = true 
end


function grenadier_update(bf)
    tf_spring_to(bf, bf.target_x + cos(bf.seed+2137*time()/9) * 6, bf.target_y + sin(bf.seed+time()/8) * 8, 0.001)
end

function grenadier_draw(bf)  
    spr(40, bf.x-8, bf.y-4)
    spr(30+time()*2%2 , bf.x, bf.y-4)
end