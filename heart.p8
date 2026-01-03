hearts = 0

function heart_spawn(x, y)
    hearts += 1
    local enemy = {
        hp = 1, dead = false,
        atk_func = cocreate(empty_func),
        die_func = empty_func,
        hit_func = empty_func,
        update_func = heart_update,
        draw_func = heart_draw,
        atk_rate = 70,
        beat_ctr = 0,
        seed = time() + rnd(1),
        spr = 1,
        timer = 50+rnd(100),
    }
    add_tf(enemy, x, y, rnd(2)-1, -1 + rnd(0.5), 0, 0.007)
    explode_small(x+rnd(16)-8, y+rnd(16)-8)
    add_collider(enemy, 4, 4)
    enemy.drag = 0.95
    add(enemies, enemy)
end

function heart_update(bf)
    if bf.timer > 0 then
        bf.timer -= 1
        return
    end
    bf.drag = 0.98
    local dx, dy = player.x - bf.x, player.y - bf.y
    norm = sqrt(dx*dx + dy*dy)
    dx = dx / norm * 0.06
    dy = dy / norm * 0.06
    bf.dx += dx
    bf.dy += dy
    if player.hp < 1 or check_collision(bf, player, 6) then
        bf.dead = true
        if player.hp < 3 then
            player.hp += 1
        end
        sfx(14)
        hearts -= 1
    end
end

function heart_draw(bf)  
    spr(64+t()*4%4, bf.x-4, bf.y-4)
end