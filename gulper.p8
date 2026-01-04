function gulper_spawn(y)
    local enemy = {id = 12,
        hp = 1, dead = false,
        atk_func = cocreate(empty_func),
        die_func = gulper_die,
        update_func = gulper_update,
        draw_func = gulper_draw,
        atk_rate = 70,
        beat_ctr = 0,
        seed = time() + rnd(1),
        holding_heart = true,
        target_x = 112,
        target_y = y,
    }
    add_tf(enemy, 148, y)
    add_collider(enemy, 16, 4)
    add(enemies, enemy)
    sfx(15, 3)
end

function gulper_draw(bf)  
    local draw_x, draw_y = flr(bf.x), flr(bf.y)
    spr(142, draw_x, draw_y-4, 2, 1)
    spr(141, draw_x-8, draw_y-4, 1, 1, bf.beat_ctr/20 % 2 > 1)
    spr(141, draw_x-16, draw_y-4, 1, 1, bf.beat_ctr/20 % 2 < 1)
    spr(140, draw_x-24, draw_y-4)
end

function gulper_die(bf)
    heart_spawn(bf.x, bf.y)
    sfx(-1, 3)
end

function gulper_update(bf)
    enemy_oscillate(bf)
    bf.target_x -= 0.1
    if rnd(1) > 0.89 then
        particle_spawn_foam(bf.x+2, bf.y, rnd(2)-1, rnd(2)-1)
    end
    if game_over and bf.holding_heart then
        bf.holding_heart = false
        sfx(-1, 3)
    end
    if bf.x < -16 then
        bf.holding_heart = false
        bf.dead = true
        sfx(-1, 3)
    end
end
