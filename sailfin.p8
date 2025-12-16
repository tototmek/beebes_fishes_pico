function sailfin_spawn(y)
    local enemy = {
        hp = 1, dead = false,
        target_x = 104, target_y = y,
        atk_func = cocreate(sailfin_atk),
        die_func = empty_func,
        update_func = sailfin_update,
        draw_func = sailfin_draw,
        atk_rate = 35,
        beat_ctr = 0,
        seed = time(),
        dashing = false,
    }
    add_tf(enemy, 136, y)
    add_collider(enemy, 10, 4)
    add(enemies, enemy)
end

function sailfin_atk(bf)
    yield()
    sfx(6)
    bf.target_x = 128
    yield()
    sfx(9)
    explode_small(bf.x+12, bf.y)
    bf.target_x = -160
    bf.dashing = true
    bf.dx = -6
    yield()
    yield()
    bf.dead = true 
end


function sailfin_update(bf)
    tf_spring_to(bf, bf.target_x, bf.target_y, 0.002)
    if bf.dashing == true then
        if bf.x > -12 then
            particle_spawn_foam(bf.x+12, bf.y-1, -3, 0.5-rnd(1))
            particle_spawn_foam(bf.x+12, bf.y-1, -3, 0.5-rnd(1))
        end
        if check_collision(bf, player) then
            player_get_hit()
        end
    end
end

function sailfin_draw(bf)  
    spr(20, flr(bf.x-12), flr(bf.y-4), 2, 1)
    spr(6, flr(bf.x+4), flr(bf.y-9), 1, 2)
    if bf.dashing == true then
        rectfill(bf.x+6, bf.y-7, bf.x+128, bf.y+3, 8)
        fillp(0b0101101001011010.1)
        rectfill(bf.x+128, bf.y-7, bf.x+140, bf.y+3, 8)
        fillp()
    end
end
