function player_create()
    local player = {
        --params--
        jump_dy = -2,
        shoot_dx = -1.5,
        def_x = 24,
        hit_timeout = 60,
        gravity = 0.07,
        --kinematics--
        tf = tf(-8),
        drag = 0.95,
        --collision--
        w_half = 6, h_half = 2,
        --health
        hp = 3,
        hit_ctr = 0,
        hittable = false,
    }
    return player
end


function player_shoot()
    bullet = {
        tf = tf(player.tf.x+8, player.tf.y+2, 4, 0.3*player.tf.dy, -0.02, 0),
    }
    add(player_bullets, bullet)
    player.tf.dx += player.shoot_dx
    sfx(0)
end

function player_update()
    --input and kinematics--
    if btnp(4) then --shoot
        player_shoot()
    end
    if btnp(5) then --jump
        sfx(1)
        if player.tf.y > 0 then
            player.tf.dy = player.jump_dy
        end
    end
    player.tf.ddy = player.gravity
    tf_spring_to(player.tf, player.def_x, nil, 0.003)
    -- player.dx += player.ddx
    -- player.x += player.dx
    -- player.dy += player.ddy
    if player.tf.y > level_height then --bounce from level bottom
        tf_spring_to(player.tf, nil, level_height, 0.02)
    end
    tf_update(player.tf)
    -- player.y += player.dy
    -- player.dx *= player.drag
    -- player.dy *= player.drag

    --update player bullets--
    player_bullets_update()

    --pillar collision--
    if pillar_collide(player.tf.x, player.tf.y, player.w_half, player.h_half) then
        player_get_hit()
    end

    if player.hittable == false then
        player.hit_ctr += 1
        if player.hit_ctr == player.hit_timeout then
            player.hittable = true
            player.hit_ctr = 0
        end
    end
end

function player_bullets_update()
    local remove_indices = {}
    for i, bullet in pairs(player_bullets) do
        bullet.tf.ddx += 0.003
        tf_update(bullet.tf)
        if bullet.tf.x > 136 then
            add(remove_indices, i)
        end
        if pillar_collide(bullet.tf.x, bullet.tf.y, 4, 0) then
            -- TODO: explode here --
            sfx(2)
            add(remove_indices, i)
        end
        if enemy_collide_bullet(bullet.tf.x, bullet.tf.y, 4, 2) then
            -- TODO: explode here --
            sfx(5)
            add(remove_indices, i)
        end
    end
    for i in all(remove_indices) do
        deli(player_bullets, i)
    end
end

function player_get_hit()
    if (player.hittable == false) return
    sfx(4)
    player.hittable = false
    player.hp -= 1
    if (player.hp < 1) game_over = true
end