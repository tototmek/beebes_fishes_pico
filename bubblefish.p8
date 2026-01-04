function bubblefish_spawn(y)
    if rnd(1) > 0.95 then
        sprite, id = 60, 5
    else
        sprite, id = 7, 1
    end
    local enemy = {id = id,
        hp = 1, dead = false,
        target_x = 104, target_y = y,
        atk_func = cocreate(bubblefish_atk),
        die_func = empty_func,
        update_func = bubblefish_update,
        draw_func = bubblefish_draw,
        atk_rate = 90,
        beat_ctr = 0,
        seed = time(),
        spr = sprite,
    }
    add_tf(enemy, 136, y)
    add_collider(enemy, 4, 4)
    add(enemies, enemy)
end

function bubblefish_atk(bf)
    for i=1,8 do
        if bf.recurse_ctr != 2 then
            enemy_shoot(bf.x-3, bf.y)
            bf.dx -= 0.5
        end
        yield()
    end
    bf.target_x = 148
    yield()
    bf.dead = true 
end


function bubblefish_update(bf)
    enemy_oscillate(bf)
end

function bubblefish_draw(bf)  
    spr(bf.spr+time()*2%2 , flr(bf.x-4), flr(bf.y-4))
end


function enemy_shoot(x, y, dx, dy, ddy)
    local bullet = {}
    add_tf(bullet, x, y, dx or -1.5, dy or 0, 0, ddy or 0)
    add_collider(bullet, 1, 1)
    bullet.drag = 1
    add(enemy_bullets, bullet)
    sfx(3)
end

last_enemy_x = 0
last_enemy_y = 0

function enemy_update(enemy)
    tf_update(enemy)
    enemy.update_func(enemy)
    last_enemy_x = enemy.x
    last_enemy_y = enemy.y
    if enemy.hp < 1 then
        enemy.dead = true
        score += 1
        if (enemy.id) catalogue_unlock_fish(enemy.id)
        enemy.die_func(enemy)
    end
    enemy.beat_ctr += 1
    if enemy.beat_ctr % enemy.atk_rate == 0 then
        if game_over == false and costatus(enemy.atk_func) then
            coresume(enemy.atk_func, enemy)
        end
    end
end

function enemy_bullets_update()
    for i, bullet in ipairs(enemy_bullets) do
        tf_update(bullet)
        if bullet.x < -4 or bullet.y < -4 or bullet.y > 131 then -- went outside the screen
            deli(enemy_bullets, i)
        elseif check_collision(bullet, player) then
            player_get_hit()
            deli(enemy_bullets, i)
            explode_big(bullet.x, bullet.y)
        end
        for pb in all(player_bullets) do
            if check_collision(bullet, pb, 3) then
                particle_spawn_explosion(bullet.x, bullet.y, 13, 0, 8)
                deli(enemy_bullets, i)
                sfx(5)
            end
        end
    end
    if game_over then
        for i, bullet in ipairs(enemy_bullets) do
            explode_big(bullet.x+6, bullet.y)
            deli(enemy_bullets, i)
        end
    end
end


function enemy_get_hit(enemy, bullet, i)
    if enemy.hit_func then
        enemy.hit_func(enemy, bullet, i)
        return
    end
    explode_big((bullet.x+6+enemy.x)/2, (bullet.y+enemy.y)/2)
    enemy.hp -= 1
    sfx(5)
    deli(player_bullets, i)
end

function enemy_oscillate(bf, speed)
    local slowness = slowness or 8
    tf_spring_to(bf, bf.target_x + cos(bf.seed+2137*time()/9) * 6, bf.target_y + sin(bf.seed+time()/8) * 8, speed or 0.001)
end

function empty_func()
end
