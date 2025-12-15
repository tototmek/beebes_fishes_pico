function bubblefish_spawn(y)
    local enemy = {
        hp = 1, dead = false,
        target_x = 104, target_y = y,
        draw_x = 136,
        atk_func = cocreate(bubblefish_atk),
        die_func = function()end,
        update_func = bubblefish_update,
        draw_func = bubblefish_draw,
        atk_rate = 90,
        beat_ctr = 0,
        seed = time(),
    }
    add_tf(enemy, 136)
    add_collider(enemy, 4, 4)
    add(enemies, enemy)
end

function bubblefish_atk(bf)
    for i=1,8 do
        enemy_shoot(bf.draw_x, bf.y, -1.5, 0)
        bf.dx -= 0.5
        yield()
    end
    bf.target_x = 148
    yield()
    bf.dead = true 
end


function bubblefish_update(bf)
    tf_spring_to(bf, bf.target_x, nil, 0.001)
    bf.y = bf.target_y + sin(bf.seed+time()/8) * 8
    bf.draw_x = bf.x + cos(bf.seed+2137+time()/9) * 6
end

function bubblefish_draw(bf)  
    spr(7+time()*2%2 , flr(bf.draw_x-4), flr(bf.y-4), 1, 1)
end


function enemy_shoot(x, y, dx, dy)
    local bullet = {}
    add_tf(bullet, x, y, dx, dy)
    add_collider(bullet, 1, 1)
    bullet.drag = 1
    add(enemy_bullets, bullet)
    sfx(3)
end

function enemy_update(enemy)
    tf_update(enemy)
    enemy.update_func(enemy)
    if enemy.hp < 1 then
        enemy.dead = true
        score += 1
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