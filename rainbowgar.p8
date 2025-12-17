function rainbowgar_spawn(y, recursion, s_x, s_y)
    local enemy = {id = 7,
        hp = 1, dead = false,
        target_x = 104, target_y = y,
        atk_func = cocreate(bubblefish_atk),
        die_func = rainbowgar_die,
        update_func = rainbowgar_update,
        draw_func = rainbowgar_draw,
        atk_rate = 100,
        beat_ctr = 0,
        seed = time() + rnd(1),
        recurse_ctr = recursion or 1,
    }
    add_tf(enemy, s_x or 136, s_y or y, 1)
    if enemy.recurse_ctr == 2 then
        add_collider(enemy, 3, 8)
    else
        add_collider(enemy, 6, 4)
    end
    add(enemies, enemy)
end

function rainbowgar_die(bf)
    local recursion = bf.recurse_ctr
    if (recursion > 2) return
    sfx(10)
    rainbowgar_spawn(bf.target_y+24/recursion, recursion+1, bf.x, bf.y)
    rainbowgar_spawn(bf.target_y-24/recursion, recursion+1, bf.x, bf.y)
end


function rainbowgar_update(bf)
    tf_spring_to(bf, bf.target_x + cos(bf.seed+2137+time()/8)*8, bf.target_y + sin(bf.seed+time()/9)*6, 0.001)
end

function rainbowgar_draw(bf)  
    local draw_x, draw_y = flr(bf.x), flr(bf.y) - 4
    if bf.recurse_ctr == 2 then
        spr(39 , draw_x-4, draw_y-7, 1, 1)
        spr(55+time()*6%2 , draw_x-3, draw_y, 1, 1)
    else
        spr(36 , draw_x-8, draw_y-1, 1, 1)
        spr(37+time()*6%2 , draw_x, draw_y-1, 1, 1)
    end
end
