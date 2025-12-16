function medusa_spawn(y)
    local enemy = {
        hp = 1, dead = false,
        atk_func = cocreate(medusa_atk),
        die_func = empty_func,
        update_func = empty_func,
        draw_func = medusa_draw,
        atk_rate = 70,
        beat_ctr = 0,
        seed = time() + rnd(1),
        spr = 1
    }
    add_tf(enemy, 136, y, 0, 0, -0.015, 0.003)
    add_collider(enemy, 4, 4)
    add(enemies, enemy)
end

function medusa_atk(bf)
    while true do
        enemy_shoot(bf.x, bf.y, -1.0, 0.5)
        bf.dx += 0.5
        bf.dy -= 0.5
        bf.spr = 0
        yield()
        bf.spr = 1
        yield()
        if bf.x < -16 then
            bf.dead = true
        end
    end
end

function medusa_draw(bf)  
    local draw_x, draw_y = flr(bf.x), flr(bf.y)
    spr(53+bf.spr, draw_x-6, draw_y-2)
    spr(51+bf.spr, draw_x-4, draw_y-4)
end
