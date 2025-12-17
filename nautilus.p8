function nautilus_spawn(y)
    local enemy = {id = 5,
        hp = 1, dead = false,
        target_x = 104, target_y = y,
        atk_func = cocreate(nautilus_atk),
        die_func = nautilus_die,
        update_func = nautilus_update,
        draw_func = nautilus_draw,
        atk_rate = 50,
        beat_ctr = 0,
        seed = time(),
    }
    add_tf(enemy, 136, y)
    add_collider(enemy, 8, 8)
    add(enemies, enemy)
end

function nautilus_atk(bf)
    for i=1,10 do
        yield()
        local shoot_x, shoot_y = bf.x-4, bf.y+4
        enemy_shoot(shoot_x, shoot_y, -1.0, -0.5)
        enemy_shoot(shoot_x, shoot_y, -1.2, 0)
        enemy_shoot(shoot_x, shoot_y, -1.0, 0.5)
        bf.dx+=0.5
        yield()
    end
    bf.target_x = 148
    yield()
    yield()
    yield()
    yield()
    bf.dead = true
end

function nautilus_die(bf)
    naked_nautilus_spawn(bf.x, bf.y+4)
end

function nautilus_update(bf)
    tf_spring_to(bf, bf.target_x + cos(bf.seed+2137+time()/8)*8, bf.target_y + sin(bf.seed+time()/9)*6, 0.0006)
end

function nautilus_draw(bf) 
    spr(12 , flr(bf.x)-8, flr(bf.y)-8, 2, 2)
end



function naked_nautilus_spawn(x, y)
    local enemy = {id = 6,
        hp = 1, dead = false,
        target_x = x, target_y = y,
        atk_func = cocreate(naked_nautilus_atk),
        die_func = function()end,
        update_func = function()end,
        draw_func = naked_nautilus_draw,
        atk_rate = 20,
        beat_ctr = 0,
        seed = time(),
        flip = false,
    }
    add_tf(enemy, x, y, -1.0)
    add_collider(enemy, 8, 4)
    add(enemies, enemy)
end

function naked_nautilus_atk(bf)
    yield()
    for i=1,3 do
        bf.flip = true,
        enemy_shoot(bf.x, bf.y, -1.0)
        bf.dy=-1.0
        bf.dx=0.3
        yield()
        bf.flip = false,
        enemy_shoot(bf.x, bf.y, -1.0)
        bf.dx=0.3
        bf.dy=1.0
        yield()
    end
    bf.ddx = -0.02
    yield()
    yield()
    yield()
    explode_small(bf.x, bf.y)
    sfx(2)
    bf.dead = true
end

function naked_nautilus_draw(bf) 
    spr(14 , flr(bf.x)-8, flr(bf.y)-4, 2, 1, false, bf.flip)
end