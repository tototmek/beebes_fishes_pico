function bubblefish_spawn(y)
    local enemy = {
        hp = 1, dead = false,
        target_x = 104, target_y = y,
        draw_x = 136,
        atk_func = bubblefish_atk,
        die_func = bubblefish_die,
        update_func = bubblefish_update,
        draw_func = bubblefish_draw,
        atk_rate = 90,
        atk_ctr = 0,
        beat_ctr = 0,
        x_size = 1, y_size = 1,
    }
    add_tf(enemy, 136)
    add_collider(enemy, 4, 4)
    add(enemies, enemy)
end

function bubblefish_atk(bf)
    if (bf.atk_ctr < 5) bubblefish_shoot(bf)
    if (bf.atk_ctr == 5) bf.target_x = 148
    if (bf.atk_ctr > 5) bf.dead = true 
end

function bubblefish_die(bf)
end

function bubblefish_update(bf)
    enemy_update(bf)
    bf.ddx = 0.001 * (bf.target_x - bf.x)
    tf_update(bf)
    bf.y = bf.target_y + sin(time()/8) * 8
    bf.draw_x = bf.x + cos(2137+time()/9) * 6
end

function bubblefish_draw(bf)  
    spr(7+time()*2%2 , flr(bf.draw_x-4), flr(bf.y-4), bf.x_size, bf.y_size)
end

function bubblefish_shoot(bf)
    enemy_shoot(bf.draw_x, bf.y, -1.5, 0)
    bf.dx -= 0.5
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
    if enemy.hp < 1 then
        enemy.dead = true
        score += 1
        enemy.die_func(enemy)
    end
    enemy.beat_ctr += 1
    if enemy.beat_ctr % enemy.atk_rate == 0 then
        enemy.atk_ctr += 1
        enemy.atk_func(enemy)
    end
end

function enemy_bullets_update()
    for i = #enemy_bullets, 1, -1 do
        local bullet = enemy_bullets[i]
        tf_update(bullet)
        if bullet.x < -4 then -- went outside the screen
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
end
