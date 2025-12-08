function player_create()
    return {
        --params--
        jump_dy = -2,
        shoot_dx = -0.4,
        def_x = 24,
        hit_timeout = 90,
        --kinematics--
        x = -8, y = 0,
        dx = 0, dy = 0,
        ddx = 0, ddy = 0.07,
        drag = 0.95,
        --collision--
        w_half = 6, h_half = 2,
        --health
        hp = 3,
        hit_ctr = 0,
        hittable = false,
    }
end


function player_shoot()
    bullet = {
        x = player.x+8, y = player.y+2,
        dx = 4, ddx = -0.02,
    }
    add(player_bullets, bullet)
    sfx(0)
end

function player_update()
    --input and kinematics--
    if btnp(4) then --shoot
        player.dx += player.shoot_dx
        player_shoot()
    end
    if btnp(5) then --jump
        sfx(1)
        if player.y > 0 then
            player.dy = player.jump_dy
        end
    end
    player.ddx = 0.003 * (player.def_x - player.x)
    player.dx += player.ddx
    player.x += player.dx
    player.dy += player.ddy
    if player.y > level_height then --bounce from level bottom
        player.dy += 0.002 * ( player.dy - level_height)
    end
    player.y += player.dy
    player.dx *= player.drag
    player.dy *= player.drag

    --update player bullets--
    player_bullets_update()

    --pillar collision--
    if pillar_collide(player.x, player.y, player.w_half, player.h_half) then
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
        bullet.ddx += 0.003
        bullet.dx += bullet.ddx
        bullet.x += bullet.dx
        bullet.dx *= player.drag
        if bullet.x > 136 then
            add(remove_indices, i)
        end
        if pillar_collide(bullet.x, bullet.y, 4, 0) then
            -- TODO: explode here --
            sfx(2)
            add(remove_indices, i)
        end
        if enemy_collide_bullet(bullet.x, bullet.y, 4, 0) then
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