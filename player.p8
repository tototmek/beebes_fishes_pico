function player_create()
    local player = {
        --params--
        jump_dy = -2,
        shoot_dx = -1.5,
        def_x = 24,
        hit_timeout = 60,
        gravity = 0.07,
        shots = 3,
        reload_timeout = 40,
        --health
        hp = 3,
        hit_ctr = 0,
        hittable = true,
        --shooting
        shots_left = 3,
        shoot_ctr = 3,
    }
    add_tf(player, -12, 36)
    add_collider(player, 8, 3)
    return player
end


function player_shoot()
    if (player.shots_left < 1) then
        sfx(7)
        return  
    end
    player.shoot_ctr = 0
    player.shots_left -= 1
    bullet = {}
    add_tf(bullet, player.x+8, player.y+2, 4, 0.3*player.dy, -0.02)
    add_collider(bullet, 6, 1)
    add(player_bullets, bullet)
    player.dx += player.shoot_dx
    sfx(0)
    particle_spawn_explosion(bullet.x, bullet.y, 6)
end

function player_update()
    --input and kinematics--
    if btnp(4) then --shoot
        player_shoot()
    end
    if btnp(5) then --jump
        sfx(1)
        if player.y > 0 then
            player.dy = player.jump_dy
        end
    end
    if in_beat_ctr == 0 and beat_counter % 3 == 0 then
        particle_spawn_foam(player.x-12, player.y, -0.5)
    end
    player.ddy = player.gravity
    tf_spring_to(player, player.def_x, nil, 0.003)

    if player.y > level_height then --bounce from level bottom
        tf_spring_to(player, nil, level_height, 0.01)
    end
    tf_update(player)

    player_bullets_update()

    if player.hittable == false then
        player.hit_ctr += 1
        if player.hit_ctr == player.hit_timeout then
            player.hittable = true
            player.hit_ctr = 0
        end
    end
    if player.shoot_ctr > player.reload_timeout then
        if (player.shots_left < player.shots) then
            player.shots_left += 1
            player.shoot_ctr -= 8
        end
    else 
        player.shoot_ctr += 1
    end
end

function player_bullets_update()
    for i, bullet in ipairs(player_bullets) do
        particle_spawn_foam(bullet.x, bullet.y, 0.5, 0.125-rnd(0.25))
        bullet.ddx += 0.003
        tf_update(bullet)
        if bullet.x > 136 then
            deli(player_bullets, i)
        end
        for pillar in all(pillars) do
            if check_collision(pillar, bullet) then
                explode_small(bullet.x-4, bullet.y)
                deli(player_bullets, i)
            end
        end
        if bullet.x < 116 do
            for enemy in all(enemies) do
                if check_collision(enemy, bullet, 2) then
                    enemy_get_hit(enemy, bullet, i)
                end
            end
        end
    end
end

function player_get_hit()
    if (player.hittable == false) return
    sfx(4)
    player.hittable = false
    player.hp -= 1
    cam_shake = 10
    -- if (player.hp == 1) then  -- make it intense
    --     music(5)
    --     sfx(8)
    -- end
    if (player.hp < 1 and hearts == 0) then
        for bullet in all(player_bullets) do
            explode_small(bullet.x+6, bullet.y)
        end
        player_bullets = {}
        music(1)
        game_over = true
        playing = false
        max_checkpoint = dget(1)
    end
end