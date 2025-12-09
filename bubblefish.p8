function bubblefish_spawn(y)
    local enemy = {
        hp = 1, dead = false,
        tf = tf(136),
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
    bf.tf.ddx = 0.001 * (bf.target_x - bf.tf.x)
    tf_update(bf.tf)
    bf.tf.y = bf.target_y + sin(time()/8) * 8
    bf.draw_x = bf.tf.x + cos(2137+time()/9) * 6
end

function bubblefish_draw(bf)  
    spr(7+time()*2%2 , flr(bf.draw_x-4), flr(bf.tf.y-4), bf.x_size, bf.y_size)
end

function bubblefish_shoot(bf)
    enemy_shoot(bf.draw_x, bf.tf.y, -1.5, 0)
    bf.tf.dx -= 0.5
end


function enemy_shoot(x, y, dx, dy)
    local bullet = {
        tf = tf(x, y, dx, dy)
    }
    bullet.tf.drag = 1
    add(enemy_bullets, bullet)
    sfx(3)
end

function enemy_update(enemy)
    enemy.beat_ctr += 1
    if enemy.beat_ctr % enemy.atk_rate == 0 then
        enemy.atk_ctr += 1
        enemy.atk_func(enemy)
    end
end

function enemy_bullets_update()
    local remove_indices = {}
    for i, bullet in pairs(enemy_bullets) do
        tf_update(bullet.tf)
        if bullet.tf.x < -4 then -- went outside the screen
            add(remove_indices, i)
        elseif (abs(bullet.tf.x - player.tf.x) < 8 and abs(bullet.tf.y - player.tf.y) < 8) then
            player_get_hit()
            add(remove_indices, i)
        end
    end
    for i in all(remove_indices) do
        deli(enemy_bullets, i)
    end
end

function enemy_collide_bullet(x, y, w_half, h_half)
    for e in all(enemies) do
        if 
            (x > e.tf.x - w_half - e.x_size * 4)
            and
            (x < e.tf.x + w_half + e.x_size * 4)
            and
            (y > e.tf.y - h_half - e.y_size * 4)
            and
            (y < e.tf.y + h_half + e.y_size * 4)
        then
            e.hp -= 1
            return true
        end
    end
    return false
end