pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
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

function constellationfish_spawn(y)
    local enemy = {id = 2,
        hp = 1, dead = false,
        target_x = 104,
        atk_func = cocreate(constellationfish_atk),
        die_func = constellationfish_die,
        update_func = constellationfish_update,
        draw_func = constellationfish_draw,
        atk_rate = 60,
        beat_ctr = 0,
        seed = time(),
    }
    add_tf(enemy, 136, y)
    add_collider(enemy, 4, 4)
    add(enemies, enemy)
end

function constellationfish_atk(bf)
    for i=1,8 do
        yield()
    end
    bf.target_x = 136
    yield()
    yield()
    yield()
    bf.dead = true
end

function constellationfish_die(bf)
    local shoot_x, shoot_y = bf.x, bf.y
    enemy_shoot(shoot_x, shoot_y, -0.5, -0.75)
    enemy_shoot(shoot_x, shoot_y, -0.8, -0.5)
    enemy_shoot(shoot_x, shoot_y, -1.0)
    enemy_shoot(shoot_x, shoot_y, -0.8, 0.5)
    enemy_shoot(shoot_x, shoot_y, -0.5, 0.75)
end

function constellationfish_update(bf)
    tf_spring_to(bf, bf.target_x + cos(bf.seed+time()/9)*6, player.y, 0.001, 0.0006)
end

function constellationfish_draw(bf) 
    local draw_x, draw_y = flr(bf.x), flr(bf.y) - 8
    spr(9 , draw_x-8, draw_y, 1, 2)
    spr(10+time()*4%2 , draw_x, draw_y, 1, 2)
end



function pillar_spawn(gap_y, gap_width)
    local pillar = {collision = true,}
    add_tf(pillar, 132, gap_y - gap_width - 72)
    add_collider(pillar, 4, 72)
    add(pillars, pillar)
    pillar = {collision = true,}
    add_tf(pillar, 132, gap_y + gap_width + 72)
    add_collider(pillar, 4, 72)
    add(pillars, pillar)
end

function pillar_draw(pillar)
    map(0, 9, flr(pillar.x-4), pillar.y-72, 3, 18)
end

function pillars_update() 
    for i, pillar in ipairs(pillars) do
        pillar.dx = -level_speed
        tf_update(pillar)
        if pillar.x < player.x - 4 then
            pillar.collision = false --prevents hitting a pillar from the back
        end
        if pillar.x < -20 then
            deli(pillars, i)
        elseif pillar.collision and check_collision(player, pillar) then
            player_get_hit()
        end
    end
end

function add_tf(tab, x, y, dx, dy, ddx, ddy)
    tab.x = x or 0
    tab.y = y or 0
    tab.dx = dx or 0
    tab.dy = dy or 0
    tab.ddx = ddx or 0
    tab.ddy = ddy or 0
    tab.drag = environment.drag
end

function tf_update(tf)
    tf.dx += tf.ddx
    tf.dy += tf.ddy
    tf.x += tf.dx
    tf.y += tf.dy
    tf.dx *= tf.drag
    tf.dy *= tf.drag
end

function tf_spring_to(tf, x, y, springiness, springiness_y)
    if (x) tf.ddx = springiness * (x - tf.x) 
    if (y) tf.ddy = (springiness_y or springiness) * (y - tf.y) 
end

function add_collider(tab, x_half_size, y_half_size)
    tab.x_half_size = x_half_size or 0
    tab.y_half_size = y_half_size or 0
end

function check_collision(a, b, range)
    local r = range or 0
    local x_offset = a.x_half_size + b.x_half_size + r
    local y_offset = a.y_half_size + b.y_half_size + r
    return
        (a.x > b.x - x_offset)
        and
        (a.x < b.x + x_offset)
        and
        (a.y > b.y - y_offset)
        and
        (a.y < b.y + y_offset)
end

function particle_spawn_foam(x, y, dx, dy)
    local foam = {lifetime = 0, size = 2,}
    add_tf(foam, x, y, dx, dy)
    add(foam_particles, foam)
end

function particle_spawn_explosion(x, y, size, dx, color)
    local explosion = {x = x, y = y, dx=dx or -level_speed, lifetime = 0, maxsize = size, size = 0, one_minus_size = size, color = color or 6}
    add(explosion_particles, explosion)
end

function particle_spawn_torpedo(x, y, dy)
    local torpedo = {lifetime = 0}
    add_tf(torpedo, x, y, -1, dy, 0.04)
    add(torpedo_particles, torpedo)
end

function explode_big(x, y)
    particle_spawn_explosion(x, y, 17, 0, 8)
    for i=1,24 do
        particle_spawn_foam(x, y, 1-rnd(2), 1-rnd(2))
    end
end

function explode_small(x, y)
    particle_spawn_explosion(x+6, y, 12)
    for i=1,9 do
        particle_spawn_foam(x+6, y, 0.5-rnd(1)-2*level_speed, 0.5-rnd(1))
    end
    sfx(2)
end



function particles_update()
    for i, foam in ipairs(foam_particles) do
        foam.lifetime += 1
        foam.size = 2 * (1 - foam.lifetime/40)
        tf_update(foam)
        if foam.lifetime > 40 then
            deli(foam_particles, i)
        end
    end
    for i, explo in ipairs(explosion_particles) do
        explo.lifetime += 1
        explo.x += explo.dx
        explo.size = explo.maxsize * (explo.lifetime/16)
        explo.one_minus_size = 0.6 * explo.maxsize * (1-explo.lifetime/16)
        if explo.lifetime >= 16 then
            deli(explosion_particles, i)
        end
    end
    for i, particle in ipairs(back_particles) do
        if (i > 13) then 
            particle[1] -= level_speed * 0.8
        elseif (i > 5) then
            particle[1] -= level_speed * 0.6
        else
            particle[1] -= level_speed * 0.4
        end
        if particle[1] < -1 then
            particle[1] = 128
            particle[2] = rnd(127)
        end
    end
    for i, torpedo in ipairs(torpedo_particles) do
        torpedo.lifetime += 1
        tf_update(torpedo)
        if torpedo.lifetime > 25 then
            explode_small(torpedo.x, torpedo.y)
            deli(torpedo_particles, i)
        end
    end
end



function particles_draw()
    for explo in all(explosion_particles) do
        if explo.lifetime >= 12 then
            fillp(0b1011011101110101.1)
        end
        circ(explo.x, explo.y, explo.size, explo.color)
        circfill(explo.x, explo.y, explo.one_minus_size)
        fillp()
    end 
    for torpedo in all(torpedo_particles) do
        spr(4, torpedo.x-8, torpedo.y-4, 2, 1)
    end
    for foam in all(foam_particles) do
        circfill(foam.x, foam.y, foam.size, 6)
    end 
end



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
    if (player.hp < 1) then
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

function bubblefish_spawn(y)
    if rnd(1) > 0.85 then
        sprite, id = 60, 10
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
    tf_spring_to(bf, bf.target_x + cos(bf.seed+2137*time()/9) * 6, bf.target_y + sin(bf.seed+time()/8) * 8, 0.001)
end

function bubblefish_draw(bf)  
    spr(bf.spr+time()*2%2 , flr(bf.x-4), flr(bf.y-4), 1, 1)
end


function enemy_shoot(x, y, dx, dy)
    local bullet = {}
    add_tf(bullet, x, y, dx or -1.5, dy or 0)
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


function empty_func()
end


function _init()
    poke(0x5f5c, 0xff) --no button repeat--
    poke(0x5f5d, 0xff) --no button repeat--
    cartdata("beebes_fishes_1")
    music(1)

    selected_checkpoint = 0
    max_checkpoint = dget(1)
    total_checkpoints = 5
    
    environment = {
        drag = 0.95,
    }

    create_catalogue()

    player = player_create()
    playing = false


    level_height, level_speed = 112, 2/3
    dead_ctr = 2137
    cam_shake = 0
    catalogue = false
    catalogue_y = -128
    cam_y = 0

    press_x_text = {target_y = 92}
    add_tf(press_x_text, 33, 128)

    checkpoint_label = {}
    add_tf(checkpoint_label, 0, 72)
    checkpoint_label.drag=0.5

    checkpoint_text_label = {}
    add_tf(checkpoint_text_label, 170)
    checkpoint_text_label.drag=0.1

    back_particles = {}
    for i=1,20 do
        back_particles[i] = {rnd(127), rnd(127)}
    end

    bkgr_init()
end


function init_gameplay()
    music(6)
    cam_y = 0
    score = 0
    playing, game_over = true, false
    dead_ctr, beat_counter, in_beat_ctr, beat_time = 0, 0, 0, 6
    pillars, player_bullets, enemy_bullets, enemies, foam_particles, explosion_particles, torpedo_particles = {}, {}, {}, {}, {}, {}, {}
    player = player_create()
    press_x_text.target_y = 160
    spawners_init(selected_checkpoint)
end


function _update60()
    if playing == true then -- main game loop --
    --update player--
    player_update()

    --update level generator--
    in_beat_ctr+=1
    if in_beat_ctr > beat_time then
        in_beat_ctr = 0
        beat_counter += 1
        if costatus(pillar_spawner_coroutine) then
            coresume(pillar_spawner_coroutine)
        end
        if costatus(spawner_coroutine) then
            coresume(spawner_coroutine)
        end
    end


    else -- end of main game loop, menu code below
    dead_ctr += 1
    if (btnp(4) or btnp(5)) and not catalogue then -- pressed play
        if selected_checkpoint <= max_checkpoint then
            if (dead_ctr > 50) then
                init_gameplay()
                sfx(1)
            end
        end
    end
    if (btnp(2)) catalogue = true
    if (btnp(3)) catalogue = false
    if catalogue then -- catalogue button logic
        if (btnp(0)) then --left
            sfx(13)
            selected_fish = min(#catalogue_draw_functions, max(1, selected_fish - 1))
        end
        if (btnp(1)) then --right
            sfx(13)
            selected_fish = min(#catalogue_draw_functions, max(1, selected_fish + 1))
        end
    else -- menu button logic
        if (btnp(0)) then --left
            sfx(13)
            selected_checkpoint = min(total_checkpoints, max(0, selected_checkpoint - 1))
        end
        if (btnp(1)) then --right
            sfx(13)
            selected_checkpoint = min(total_checkpoints, max(0, selected_checkpoint + 1))
        end
    end
    if game_over then
        player.ddy = 0.02
        player.ddx = -0.004
        tf_update(player)
        if (player.y < level_height) and rnd(1) < 0.05 then
            explode_small(player.x - 16 + rnd(32), player.y - 8 + rnd(16))
        end
    end
    end --below runs in both game loop and main menu
    for i, enemy in ipairs(enemies) do -- update enemies and destroy if needed
        enemy_update(enemy)
        if enemy.dead then
            deli(enemies, i)
        end
    end
    enemy_bullets_update()
    pillars_update()
    particles_update() -- do in any mode
    tf_spring_to(press_x_text, nil, press_x_text.target_y, 0.003)
    tf_update(press_x_text)
    bkgr_update()
    if cam_shake > 0 then
        cam_shake -= 1
    end
end

function _draw()
    pal(4, 129, 1) -- add blues to pallette
    pal(5, 140, 1)
    cls(4)
    rectfill(0, -128, 128, 0, 1)
    rectfill(0, 0, 127, 16, 1)
    for i=0,127,8 do
        spr(80, i, 16, 1, 3)
    end
    camera(rnd(cam_shake), cam_y + rnd(cam_shake))

    --draw background--
    bkgr_draw()


    local sine_y = -2.5*sin(t()/4)

    -- draw background particles --
    for particle in all(back_particles) do
        pset(particle[1], particle[2], 5)
    end

    for pillar in all(pillars) do
        pillar_draw(pillar)
    end
    for enemy in all(enemies) do
        enemy.draw_func(enemy)
    end

    local blink_player = player.hit_ctr%12 < 6 and player.hit_ctr > 0
    if blink_player then
        pal(12, 7, 0)
        pal(5, 7, 0)
    end
    local player_flr_x, player_flr_y = flr(player.x), flr(player.y)
    spr(1, player_flr_x-12, player_flr_y-7, 3, 2)
    if blink_player then
        pal(12, 12, 0)
        pal(5, 5, 0)
    end
    particles_draw()

    local sine_prop = flr(2*sin(time()))
    line(player_flr_x-13, player_flr_y+1-sine_prop, player_flr_x-13, player_flr_y+2+sine_prop, 6)  --propeller
    for i=1,player.shots_left do
        -- torpedo bays
        rectfill(player_flr_x-9+i*5, player_flr_y+2, player_flr_x-8+i*5, player_flr_y+3, 12)
    end

    for bullet in all(player_bullets) do
        -- circfill(bullet.x-10, bullet.y, bullet.dx, 6)
        spr(4, bullet.x-8, bullet.y-4, 2, 1)
    end
    for bullet in all(enemy_bullets) do
        spr(23, bullet.x-4, bullet.y-4)
    end

    camera(0, cam_y)
    -- rectfill(0, gui_y, 127, gui_y+16, 1)
    -- line(0, gui_y, 128, gui_y, 7)
    local lives = ""
    for i=1,player.hp do
        lives = lives.."♥"
    end

    if playing then --draw game ui
        print(lives.."  ", 1, 2, 7)
        score_str_length = print(score,0,-100)
        print(score, 127-score_str_length, 2)
        spawner_progress_bar_print()

    -- print("particles "..#foam_particles, 63, level_height+3)
    else -- draw main menu
        if catalogue then
            display_catalogue()
            cam_y += 0.15 * (catalogue_y - cam_y)
        else
            cam_y -= 0.1 * cam_y
            if (cam_y > -0.6) cam_y = 0
        end
        if game_over then
            press_x_text.target_y = 92
            print("game over", 47, 31, 2)
            print("game over", 46, 30, 7)
            print("SCORE", 53, 61, 7)
            score_str_length = print("\^w\^t"..score,0,-100)
            print("\^w\^t"..score, 64-0.5*score_str_length, 50)
            pset(63,63)
        else
            spr(128, 39, 20, 6, 4) --print game title
        end

        -- print checkpoint menu
        tf_spring_to(checkpoint_text_label, 0, nil, 0.02)
        tf_update(checkpoint_text_label)
        print("catalogue", -checkpoint_text_label.x+10, 2, 7)
        spr(151, -checkpoint_text_label.x+2, 2)
        if selected_checkpoint == 0 then
            tf_spring_to(checkpoint_label, 130, nil, 0.05)
            print(" check\npoints", checkpoint_text_label.x+98, 68, 7)
            spr(150.5, checkpoint_text_label.x+119, 70, 1, 1, true)
        else
            tf_spring_to(checkpoint_label, -selected_checkpoint * 40, nil, 0.05)
            spr(150, 2, 70)
            if selected_checkpoint < total_checkpoints then
                spr(150, 118, 70, 1, 1, true)
            end
        end
        tf_update(checkpoint_label)
        for i=1,total_checkpoints do
            local draw_x = checkpoint_label.x + i*40 + 64
            local draw_y = checkpoint_label.y + sin(i/4+t()*0.2)*4
            if i==selected_checkpoint then
                spr(136, draw_x-8, draw_y-8, 2, 2)
            else
                spr(138, draw_x-8, draw_y-8, 2, 2)
            end
            if i>max_checkpoint then
                spr(134, draw_x-4, draw_y-4)
            else
                spr(135, draw_x-4, draw_y-4)
            end
            print(i, draw_x-2, draw_y-3, 7)
        end
    end

    local message = " locked..."
    if selected_checkpoint <= max_checkpoint then
        message = "press ❎"
    end
    print(message, 48, press_x_text.y+sine_y+1, 1)
    print(message, 47, press_x_text.y+sine_y, 7)

    -- print("plr:"..#pillars.." enm:"..#enemies.." pb:"..#player_bullets.." eb:"..#enemy_bullets, 38, level_height + 3)

    --debug--
    -- pset(player.x, player.y, 11)
    -- rect(player.x-player.x_half_size, player.y-player.y_half_size, player.x+player.x_half_size, player.y + player.y_half_size, 11)

end

function bkgr_init()
    bkgr_back = {
        speed = -level_speed / 18,
        x = {63, 127, 190},
        loc = {0, 1, 2},
        map_start_x = 0,
        map_start_y = 0,
        map_size_x = 5,
        map_size_y = 3,
        map_n = 3,
        respawn_x = 127,
        random = 0
    }
    bkgr_front = {
        speed = -level_speed / 4,
        x = {127, 61},
        loc = {0, 2},
        map_start_x = 0,
        map_start_y = 3,
        map_size_x = 5,
        map_size_y = 6,
        map_n = 5,
        respawn_x = 132,
        random = 0
    }
    bkgr_mid = {
        speed = -level_speed / 3,
        x = {},
        loc = {},
        map_start_x = 9,
        map_start_y = 9,
        map_size_x = 1,
        map_size_y = 8,
        map_n = 4,
        respawn_x = 127,
        random = 0.8,
    }
    for i=1,10 do
        add(bkgr_mid.x, rnd(127))
        add(bkgr_mid.loc, i*21.37%bkgr_mid.map_n)
    end
    end
    
    function bkgr_update()
        bkgr_update_internal(bkgr_back)
        bkgr_update_internal(bkgr_front)
        bkgr_update_internal(bkgr_mid)
    end
    
    function bkgr_draw()
        bkgr_draw_internal(bkgr_back, 16)
        bkgr_draw_internal(bkgr_front, 8)
        bkgr_draw_internal(bkgr_mid, 26)
    end
    
    function bkgr_update_internal(layer)
        for i, x in ipairs(layer.x) do
            layer.x[i] += (1 + i/#layer.x * layer.random) * layer.speed
            if layer.x[i] < -layer.map_size_x*8 then
                layer.x[i] = layer.respawn_x
                layer.loc[i] = flr(rnd(layer.map_n))
            end
        end
    end
    
    function bkgr_draw_internal(layer, y)
        for i, x in pairs(layer.x) do
            bkg_draw_y = y + i/#layer.x * layer.random * 48
            map(layer.map_start_x+layer.loc[i]*layer.map_size_x, layer.map_start_y, flr(x), y + i/#layer.x * layer.random * 32, layer.map_size_x, layer.map_size_y)
        end
    end
    
    

function anglerfish_spawn(y)
    local enemy = {id = 2,
        hp = 3, dead = false,
        target_x = 104, target_y = y,
        atk_func = cocreate(anglerfish_atk),
        die_func = anglerfish_die,
        update_func = anglerfish_update,
        draw_func = anglerfish_draw,
        hit_func = anglerfish_hit,
        atk_rate = 40,
        beat_ctr = 0,
        seed = time(),
        -- lights = {},
        dashing = false,
        exploding = 0,
        frame_ctr = 0,
        lights_out = false,
        lights = 3,
    }
    -- enemy.lights[1] = {id=-1}
    -- enemy.lights[2] = {id=0}
    -- enemy.lights[3] = {id=1}
    add_tf(enemy, 166, y)
    -- add_tf(enemy.lights[1], 166, y)
    -- add_tf(enemy.lights[2], 166, y)
    -- add_tf(enemy.lights[3], 166, y)
    add_collider(enemy, 2, 7)
    add(enemies, enemy)
end

function anglerfish_atk(bf)
    yield()
    for k = 1,9 do
        for i=1,4 do -- random dashes
            yield()
            anglerfish_dash(bf)
            bf.target_y = min(max(39,player.y + player.dy * 8 + rnd(16) - 8),112)
        end
        yield()
        yield()
        yield()
        anglerfish_light_spawn(bf) -- spawn the light
        while (bf.lights_out) do
            yield()
        end
    end
    bf.target_x = 148
    yield()
    yield()
    yield()
    bf.dead = true
end

function anglerfish_dash(bf)
    yield()
    sfx(6)
    bf.dy = 0
    bf.dx = 1.2
    yield()
    sfx(9)
    explode_small(bf.x+12, bf.y)
    bf.dx = -9
    bf.dashing = true
    yield()
    bf.dashing = false
end

function anglerfish_die(bf)
    explode_big(bf.x, bf.y)
end

function anglerfish_update(bf)
    if bf.exploding > 0 then
        bf.exploding -= 1
        if rnd(1) < 0.05 then
            explode_small(bf.x - 12 + rnd(24), bf.y - 12 + rnd(24))
        end
    end
    if bf.dashing then
        particle_spawn_foam(bf.x+12, bf.y-2, -3, 0.5-rnd(1))
        particle_spawn_foam(bf.x+12, bf.y-2, -3, 0.5-rnd(1))
        if check_collision(bf, player) then
            player_get_hit()
            bf.dashing = false
        end
    else
        tf_spring_to(bf, bf.target_x + cos(bf.seed+time()/9)*6, bf.target_y+sin(bf.seed+time()/8), 0.0014)
    end
end

function anglerfish_hit(enemy, bullet, i)
    sfx(11)
    particle_spawn_torpedo(bullet.x, bullet.y, (bullet.y - enemy.y)/8)
    deli(player_bullets, i)
end

function anglerfish_draw(bf) 
    local draw_x, draw_y = flr(bf.x), flr(bf.y)
    if bf.dashing then
        local rectlen = abs(bf.dx)*12
        rectfill(draw_x+6, draw_y-7, draw_x+rectlen, draw_y+3, 8)
        fillp(0b0101101001011010.1)
        rectfill(draw_x+rectlen, draw_y-7, draw_x+rectlen*1.2, draw_y+3, 8)
        fillp()
    end
    if bf.exploding > 30 then
        pal(2, 7)
        pal(8, 7)
        pal(14, 7)
        draw_x += rnd(2)-2
        draw_y += rnd(2)-2
    end
    for i = 1,bf.lights do
        spr(50 , draw_x + 4-2*i, draw_y - 9-2*i, 1, 1) -- draw lights
    end
    spr(32 , draw_x - 8, draw_y - 8, 2, 2)
    bf.frame_ctr += 0.1*abs(bf.dx)
    spr(34+bf.frame_ctr%2 , draw_x+8, draw_y - 8, 1, 1)
    if bf.exploding > 30 then
        pal(2, 2)
        pal(8, 8)
        pal(14, 14)
    end
end



function anglerfish_light_spawn(anglerfish)
    local enemy = {
        hp = 1, dead = false,
        atk_func = cocreate(anglerfish_light_atk),
        die_func = anglerfish_light_die,
        update_func = anglerfish_light_update,
        draw_func = anglerfish_light_draw,
        atk_rate = 80,
        beat_ctr = 0,
        seed = time(),
        parent = anglerfish,
        returning = false,
    }
    anglerfish.lights -= 1
    anglerfish.lights_out = true
    add_tf(enemy, anglerfish.x-1, anglerfish.y-10)
    add_collider(enemy, 4, 4)
    add(enemies, enemy)
end

function anglerfish_light_update(bf)
    if bf.returning == true then 
        tf_spring_to(bf, bf.parent.x-1, bf.parent.y-10, 0.002)
    else
        tf_spring_to(bf, bf.parent.x-20+sin(time()/2)*8, bf.parent.y-32+cos(time()/2.1)*8, 0.0015)
    end
end

function anglerfish_light_die(bf)
    bf.parent.lights_out = false
    bf.parent.hp -= 1
    bf.parent.exploding = 100
    explode_small(bf.parent.x, bf.parent.y-8)
    for i=1,5-bf.parent.hp do
        bubblefish_spawn(rnd(16+96))
    end
end

function anglerfish_light_draw(bf)
    sx, sy = bf.x, bf.y
    dx, dy = bf.parent.x+2-bf.parent.lights*2 - sx, bf.parent.y-9 - sy
    line(sx, sy, sx+0.5*dx, sy+0.125*dy, 8)
    line(sx+0.5*dx, sy+0.125*dy, sx+0.75*dx, sy+0.3*dy)
    line(sx+0.75*dx, sy+0.3*dy, sx+0.9*dx, sy+0.6*dy)
    line(sx+0.9*dx, sy+0.6*dy, sx+dx, sy+dy, 8)
    spr(24, bf.x-4, bf.y-4)
end

function anglerfish_light_atk(bf)
    for i=1,5 do
        local shoot_x, shoot_y = bf.x, bf.y
        enemy_shoot(shoot_x, shoot_y, -0.8, -0.75)
        enemy_shoot(shoot_x, shoot_y, -1.0, -0.25)
        enemy_shoot(shoot_x, shoot_y, -1.0, 0.25)
        enemy_shoot(shoot_x, shoot_y, -0.8, 0.75)
        yield()
    end
    bf.returning = true
    yield()
    bf.parent.lights_out = false
    bf.parent.lights += 1
    bf.dead = true
end

function sailfin_spawn(y)
    local enemy = {id = 8,
        hp = 1, dead = false,
        target_x = 104, target_y = y,
        atk_func = cocreate(sailfin_atk),
        die_func = empty_func,
        update_func = sailfin_update,
        draw_func = sailfin_draw,
        atk_rate = 35,
        beat_ctr = 0,
        seed = time(),
        dashing = false,
    }
    add_tf(enemy, 136, y)
    add_collider(enemy, 10, 4)
    add(enemies, enemy)
end

function sailfin_atk(bf)
    yield()
    sfx(6)
    bf.target_x = 128
    yield()
    sfx(9)
    explode_small(bf.x+12, bf.y)
    bf.target_x = -160
    bf.dashing = true
    bf.dx = -6
    yield()
    yield()
    bf.dead = true 
end


function sailfin_update(bf)
    tf_spring_to(bf, bf.target_x, bf.target_y, 0.002)
    if bf.dashing == true then
        if bf.x > -12 then
            particle_spawn_foam(bf.x+12, bf.y-1, -3, 0.5-rnd(1))
            particle_spawn_foam(bf.x+12, bf.y-1, -3, 0.5-rnd(1))
        end
        if check_collision(bf, player) then
            player_get_hit()
        end
    end
end

function sailfin_draw(bf)  
    local draw_x, draw_y = bf.x, bf.y
    spr(20, flr(draw_x-12), flr(draw_y-4), 2, 1)
    spr(6, flr(draw_x+4), flr(draw_y-9), 1, 2)
    if bf.dashing == true then
        rectfill(draw_x+6, draw_y-7, draw_x+128, draw_y+3, 8)
        fillp(0b0101101001011010.1)
        rectfill(draw_x+128, draw_y-7, draw_x+140, draw_y+3, 8)
        fillp()
    end
end


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


function medusa_spawn(y)
    local enemy = {id = 4,
        hp = 1, dead = false,
        atk_func = cocreate(medusa_atk),
        die_func = empty_func,
        update_func = empty_func,
        draw_func = medusa_draw,
        atk_rate = 70,
        beat_ctr = 0,
        seed = time() + rnd(1),
        spr = 1
    }
    add_tf(enemy, 136, y, 0, 0, -0.015, 0.003)
    add_collider(enemy, 4, 4)
    add(enemies, enemy)
end

function medusa_atk(bf)
    while true do
        enemy_shoot(bf.x, bf.y, -1.0, 0.5)
        bf.dx += 0.5
        bf.dy -= 0.5
        bf.spr = 0
        yield()
        bf.spr = 1
        yield()
        if bf.x < -16 then
            bf.dead = true
        end
    end
end

function medusa_draw(bf)  
    local draw_x, draw_y = flr(bf.x), flr(bf.y)
    spr(53+bf.spr, draw_x-6, draw_y-2)
    spr(51+bf.spr, draw_x-4, draw_y-4)
end


function catalogue_unlock_fish(index)
    dset(0, dget(0) | (1 << (index-1)))
end

function bubblefish1_draw_wrapper(bf)
    bf.spr = 7
    bubblefish_draw(bf)
end

function bubblefish2_draw_wrapper(bf) 
    bf.spr = 60
    bubblefish_draw(bf)
end


function bathysphaera_draw_mock(bf)
    local length = 40
    local draw_x, draw_y = bf.x, bf.y
    for i=length,1,-1 do
        local seg_x, seg_y = bf.x + i*2, bf.y
        if i > length * 0.98 then
            spr(46, seg_x-4, seg_y-8)
            spr(46, seg_x-4, seg_y, 1, 1, false, true)
        elseif i > length * 0.825 then
            spr(44, seg_x-4, seg_y-8)
            spr(44, seg_x-4, seg_y, 1, 1, false, true)
        elseif i > length * 0.80 then
            spr(45, seg_x-4, seg_y-8)
            spr(45, seg_x-4, seg_y, 1, 1, false, true)
        else
            if i%6 == 4 then
                spr(59, seg_x-4, seg_y-4)
            else
                spr(58, seg_x-4, seg_y-4)
            end
        end
    end
    line(draw_x, draw_y+3, draw_x+3, draw_y+6, 8)
    line(draw_x+3, draw_y+6, draw_x+8, draw_y+8)
    line(draw_x+8, draw_y+8, draw_x+44, draw_y+8)
    line(draw_x+55, draw_y+3, draw_x+58, draw_y+6, 8)
    line(draw_x+58, draw_y+6, draw_x+63, draw_y+9)
    line(draw_x+63, draw_y+9, draw_x+100, draw_y+9)
    spr(41, draw_x-10, draw_y-4, 2, 1)
    spr(43, draw_x+100, draw_y-4)
    spr(24, draw_x+40, draw_y+4)
    spr(24, draw_x+100, draw_y+5)
end

catalogue_draw_functions = {
    bubblefish1_draw_wrapper,
    constellationfish_draw,
    anglerfish_draw,
    medusa_draw,
    bubblefish2_draw_wrapper,
    nautilus_draw,
    naked_nautilus_draw,
    rainbowgar_draw,
    sailfin_draw,
    bathysphaera_draw_mock,
}

catalogue_names = {
    "hatchetfish",
    "five-striped constellation fish",
    "three-starred anglerfish",
    "giant jelly",
    "manefish",
    "nautilus",
    "naked nautilus",
    "abyssal rainbow gar",
    "pallid sailfin",
    "giant dragonfish",
}

catalogue_surnames = {
    "argyropelecus aculeatus",
    "bathysidus pentagrammus",
    "bathyceratias trilynchnus",
    "stygiomedusa gigantea",
    "platyberyx opalescens",
    "nautilus belauensis",
    "nautilus nudus",
    "abyssobelonidus atlanticus",
    "bathyembryx istiophasma",
    "bathysphaera intacta",
}

catalogue_draw_offsets = {6, 6, 8, 6, 6, 6, 6, 6, 6, 12}

catalogue_dummy_enemy = {
    x, y = 0, 0,
    dashing = false,
    lights = 3,
    exploding = 0,
    frame_ctr = 0,
    spr = 0,
}

function draw_fish(func, x, y)
    catalogue_dummy_enemy.x = x
    catalogue_dummy_enemy.y = y
    func(catalogue_dummy_enemy)
end

function create_catalogue()
    catalogue_fish_pos = {}
    add_tf(catalogue_fish_pos)
    catalogue_fish_pos.drag = 0.5
    selected_fish = 1
end

function display_catalogue()
    tf_spring_to(catalogue_fish_pos, -selected_fish*64, nil, 0.03)
    tf_update(catalogue_fish_pos)
    local y_offset = 6
    circfill(64,-60+y_offset,23,4)
    local unlocked = 0
    
    for i, draw_func in ipairs(catalogue_draw_functions) do
        local draw_x, draw_y = catalogue_fish_pos.x + i*64, -54 + y_offset
        draw_x = atan2(draw_x/64, 1) * 300 - 154 - catalogue_draw_offsets[i]
        if i == selected_fish then
            draw_y -= 8
        end
        pal(2, 4)
        pal(8, 4)
        pal(14, 4)
        pal(15, 4)
        draw_fish(draw_func, draw_x-1, draw_y)
        draw_fish(draw_func, draw_x+1, draw_y)
        draw_fish(draw_func, draw_x+1, draw_y-1)
        draw_fish(draw_func, draw_x+1, draw_y+1)
        draw_fish(draw_func, draw_x-1, draw_y-1)
        draw_fish(draw_func, draw_x-1, draw_y+1)
        draw_fish(draw_func, draw_x, draw_y-1)
        draw_fish(draw_func, draw_x, draw_y+1)
        pal(2, 2)
        pal(8, 8)
        pal(14, 14)
        pal(15, 15)
        if (dget(0) >> (i - 1)) & 1 == 1 then -- fish catalogued
            unlocked += 1
            draw_fish(draw_func, draw_x, draw_y)
            if i == selected_fish then
                textlen = print(catalogue_names[i], 0, 200)
                print(catalogue_names[i], 64-textlen/2+1, -41+y_offset, 4)
                print(catalogue_names[i], 64-textlen/2, -42+y_offset, 6)
                textlen = print(catalogue_surnames[i], 0, 200)
                print(catalogue_surnames[i], 64-textlen/2+1, -83+y_offset, 4)
                print(catalogue_surnames[i], 64-textlen/2, -84+y_offset, 7)
            end
        else
            if i == selected_fish then
                print("?????", 55, -41+y_offset, 6)
                print("?????", 55, -84+y_offset, 7)
            end
            spr(16, draw_x-3, draw_y-5)
        end
    end

    spr(128, 39, -127, 6, 4) --print game title
    print("fish catalogue", 36, -99, 1)
    print("fish catalogue", 37, -100, 1)
    print("fish catalogue", 38, -99, 1)
    print("fish catalogue", 38, -98, 4)
    print("fish catalogue", 37, -99, 7)

    if selected_fish > 1 then
        spr(150, 2, -79)
    end
    if selected_fish < #catalogue_draw_functions then
        spr(150, 118, -79, 1, 1, true)
    end

    print(unlocked.."/"..#catalogue_draw_functions.." unlocked", 71, -8)
end

function bathysphaera_spawn(y)
    local enemy = {id = 9,
        hp = 30, dead = false,
        target_x = 136, target_y = y,
        atk_func = cocreate(bathysphaera_atk),
        die_func = bathysphaera_die,
        update_func = bathysphaera_update,
        draw_func = bathysphaera_draw,
        hit_func = bathysphaera_get_hit,
        atk_rate = 100,
        beat_ctr = 0,
        seed = time() + rnd(1),
        frame_ctr = 0,
        prev_x = {},
        prev_y = {},
        length = 75,
        exploding = 0,
        line_points_x = {},
        line_points_y = {},
        line_end_1_x = 0,
        line_end_2_x = 0,
        line_end_1_y = 0,
        line_end_2_y = 0,
    }
    for i=1,enemy.length*2 do
        enemy.prev_x[i] = 136
        enemy.prev_y[i] = y
    end
    for i=1,20 do
        enemy.line_points_x[i] = 286
        enemy.line_points_y[i] = y
    end
    add_tf(enemy, 136, y)
    add_collider(enemy, 4, 4)
    add(enemies, enemy)
end

function bathysphaera_atk(bf)
    while true do
        local shoot_x, shoot_y = bf.line_end_1_x, bf.line_end_1_y
        if shoot_x < 128 then
            enemy_shoot(shoot_x, shoot_y, -0.8, -0.5)
            enemy_shoot(shoot_x, shoot_y, -1.0)
            enemy_shoot(shoot_x, shoot_y, -0.8, 0.5)
        end
        yield()
        local shoot_x, shoot_y = bf.line_end_2_x, bf.line_end_2_y
        if shoot_x < 128 then
            enemy_shoot(shoot_x, shoot_y, -0.8, -0.5)
            enemy_shoot(shoot_x, shoot_y, -1.0)
            enemy_shoot(shoot_x, shoot_y, -0.8, 0.5)
            yield()
        end
    end
end

function bathysphaera_get_hit(bf, bullet, i)
    bf.exploding = 10
    explode_big(bullet.x+6, bullet.y)
    bf.hp -= 1
    sfx(5)
    deli(player_bullets, i)
    bf.length = 3*(bf.hp+1)
end

function bathysphaera_die(bf)
    explode_big(bf.x, bf.y)
    explode_big(bf.line_end_1_x, bf.line_end_1_y)
    explode_big(bf.line_end_2_x, bf.line_end_2_y)
end

function bathysphaera_update(bf)
    bf.frame_ctr += 0.001
    local sin_t, cos_t = sin(bf.frame_ctr), cos(bf.frame_ctr)
    bf.target_x, bf.target_y = 120 + 32*sin_t*cos_t - 48*sin_t*sin_t, 64 + 52*sin_t
    tf_spring_to(bf, bf.target_x, bf.target_y, 0.0005)
    if (bf.frame_ctr % 0.0012 == 0) then
        bf.prev_x[1] = bf.x
        bf.prev_y[1] = bf.y
        for i=bf.length-1,1,-1 do
            -- bf.prev_x[i] = bf.prev_x[i] + 0.1*(bf.prev_x[i-1]-bf.prev_x[i])
            -- bf.prev_y[i] = bf.prev_y[i] + 0.1*(bf.prev_y[i-1]-bf.prev_y[i])
            bf.prev_x[i+1] = bf.prev_x[i]
            bf.prev_y[i+1] = bf.prev_y[i]
        end
    end
    if bf.exploding > 0 then
        bf.exploding -= 1
    end
    for i = 1,bf.length do
        for k, bullet in ipairs(player_bullets) do
            if abs(bullet.x - bf.prev_x[i]) < 2 and abs(bullet.y - bf.prev_y[i]) < 2 do
                bathysphaera_get_hit(bf, bullet, k)
            end
        end
    end
    bf.line_points_x[1] = bf.x 
    bf.line_points_y[1] = bf.y+6
    bf.line_points_x[2] = bf.prev_x[flr(0.75*bf.length)] 
    bf.line_points_y[2] = bf.prev_y[flr(0.75*bf.length)]+8
    for i=3,20,2 do
        bf.line_points_x[i] += 0.04 * (bf.line_points_x[i-2] - bf.line_points_x[i]) - 0.1
        bf.line_points_y[i] += 0.04 * (bf.line_points_y[i-2] - bf.line_points_y[i]) + 0.02
        bf.line_points_x[i+1] += 0.04 * (bf.line_points_x[i-1] - bf.line_points_x[i+1]) - 0.1
        bf.line_points_y[i+1] += 0.04 * (bf.line_points_y[i-1] - bf.line_points_y[i+1]) + 0.02
    end
    bf.line_points_y[3] += 0.1
    bf.line_points_y[4] += 0.15
    bf.line_end_1_x = bf.line_points_x[#bf.line_points_x-1]
    bf.line_end_2_x = bf.line_points_x[#bf.line_points_x]
    bf.line_end_1_y = bf.line_points_y[#bf.line_points_y-1]
    bf.line_end_2_y = bf.line_points_y[#bf.line_points_y]
end

function bathysphaera_draw(bf)  
    if bf.exploding > 0 then
        pal(2, 7)
        pal(8, 7)
        pal(14, 7)
    end
    line(flr(bf.line_points_x[2]), flr(bf.line_points_y[2]), bf.prev_x[flr(0.75*bf.length)], bf.prev_y[flr(0.75*bf.length)]+3, 8)
    for i=3,20,2 do
        line(flr(bf.line_points_x[i-1]), flr(bf.line_points_y[i-1]), flr(bf.line_points_x[i+1]), flr(bf.line_points_y[i+1]))
    end
    spr(24, bf.line_end_2_x-4, bf.line_end_2_y-4)
    local flip_tail =  bf.prev_x[bf.length] < bf.prev_x[bf.length-1]
    local offset = 3
    if (flip_tail) offset = -3
    spr(43, bf.prev_x[bf.length]-4+offset, bf.prev_y[bf.length]-4, 1, 1, flip_tail)
    local draw_x, draw_y = flr(bf.x), flr(bf.y)
    for i=bf.length,1,-1 do
        local seg_x, seg_y = flr(bf.prev_x[i]), flr(bf.prev_y[i])
        if i > bf.length * 0.98 then
            spr(46, seg_x-4, seg_y-8)
            spr(46, seg_x-4, seg_y, 1, 1, false, true)
        elseif i > bf.length * 0.825 then
            spr(44, seg_x-4, seg_y-8)
            spr(44, seg_x-4, seg_y, 1, 1, false, true)
        elseif i > bf.length * 0.80 then
            spr(45, seg_x-4, seg_y-8)
            spr(45, seg_x-4, seg_y, 1, 1, false, true)
        else
            if i%6 == 4 then
                spr(59, seg_x-4, seg_y-4)
            else
                spr(58, seg_x-4, seg_y-4)
            end
        end
    end
    line(flr(bf.line_points_x[1]), flr(bf.line_points_y[1]), bf.x, bf.y+3, 8)
    for i=3,20,2 do
        line(flr(bf.line_points_x[i-2]), flr(bf.line_points_y[i-2]), flr(bf.line_points_x[i]), flr(bf.line_points_y[i]))
    end
    spr(24, bf.line_end_1_x-4, bf.line_end_1_y-4)
    if bf.dx > 0.12 then
        spr(41, draw_x-7, draw_y-4, 2, 1, true)
    elseif bf.dx < -0.15 then
        spr(41, draw_x-10, draw_y-4, 2, 1)
    else
        spr(57, draw_x-4, draw_y-4, 1, 1, true)
    end
    if bf.exploding > 0 then
        pal(2, 2)
        pal(8, 8)
        pal(14, 14)
    end
end



spawn_functions = {
    bubblefish_spawn,
    constellationfish_spawn,
    anglerfish_spawn,
    medusa_spawn,
    nautilus_spawn,
    naked_nautilus_spawn,
    rainbowgar_spawn,
    sailfin_spawn,
    bathysphaera_spawn,
}

function spawners_init(starting_checkpoint)
    spawner_stage = 1 + starting_checkpoint
    printh("Starting from stage "..spawner_stage)
    spawner_current_spr = 0
    spawner_pillar_rate = 0
    pillar_spawner_coroutine = cocreate(pillar_spawner_run)
    spawner_coroutine = cocreate(spawner_run)
end

function pillar_spawner_run()
    while true do
        if spawner_pillar_rate > 0 then
            pillar_spawn(64+sin(t()/5)*24, 22 + rnd(8))
        end
        yield()
        for i=1,3*(16-spawner_pillar_rate)+flr(rnd(2)) do
            yield()
        end
    end
end


function spawner_run()
    for i=1,10 do
        yield()
    end
    bubblefish_spawn(63)
    -- medusa_spawn(63)
    for i=1,30 do
        yield()
    end
    while spawner_stage < 7 do
        for i=1,5 do
            spawner_perform_random_sprite()
            spawner_current_spr = i
        end
        spawner_perform_final_sprite()
        spawner_stage+=1
        spawner_current_spr = 0
        if spawner_stage-1 > dget(1) then
            dset(1, spawner_stage-1)
            printh("Checkpoint unlocked")
        end
    end
    while true do
        spawner_perform_random_sprite()
    end
end

function spawner_perform_random_sprite()
    spawner_perform_sprite(192+(spawner_stage-1)*8+flr(rnd(6)))
end

function spawner_perform_final_sprite()
    spawner_perform_sprite(199+(spawner_stage-1)*8)
    while #enemies > 0 do
        yield()
    end
end

function spawner_perform_sprite(spr_id)
    printh("stage "..spawner_stage)
    printh("Spawner performing sprite "..spr_id)
    local spr_x, spr_y = (spr_id % 16) * 8, (spr_id \ 16) * 8
    spawner_pillar_rate = sget(spr_x, spr_y)
    step_wait_time = sget(spr_x+1, spr_y)
    for fx = 0,7 do
        for fy = 1,7 do
            local fish_id = sget(spr_x+fx, spr_y+fy)
            if fish_id > 0 then
                spawn_functions[fish_id](24+11.43*fy)
            end
        end
        for i=1,9 do
            yield()
        end
    end
    for i=1,1+4*step_wait_time do
        yield()
    end
end


function spawner_progress_bar_print()
    local seglen = 12
    rect(28, 2, 100, 3, 5)
    line(29, 3, 99, 3, 4)
    local playerpos = 28+(spawner_stage-1)*seglen+spawner_current_spr*2.3
    line(29, 3, playerpos, 3, 5)
    for i = 1,6 do
        if i < spawner_stage then --stage cleared
            spr(166, 24+i*seglen, 0)
        else --stage yet to clear
            spr(167, 24+i*seglen, 0)
        end
    end
    spr(168, playerpos - 3, 0)
end


__gfx__
00000000000000000000055000000000000000000000000000008200000808800008088000000000000000000000000000000000000000000000000000000000
0000000000000000000005000000000000000000000000000008220008888800088888000000000088880000888800000000000022220000000eeeeeee000000
0070070000000000000005000000000050055555555555500008220002222808022228800000088888888000888800000000002288e822000000000eeeeee000
000770000000000000000500000000005555ccccccccccc50082220022882282228822200000222222288800222880000000228888e8e820000eeeee22eeee00
000770000000000000055555000000005555555555555cc5008222002222222022222220000222e2e2228800e2228000000022eee8e8e8200000000eeeeeee00
0070070000000555555555555555555050055555555555508888220802222022022220200022e22222e2808822e2808000022288e8e8e882000eeeeeeeeee000
0000000055505cccccccccccccccccc500000000000000008e888828002220020022202022822222222208282222028000222228822ee8820000000eee000000
0000000055555c5555555555555555c500000000000000002222228800020200000202000022e2e2e2e22220e2e22280022222282228888200000eee00000000
00000000ccc5555555555555555555c5000888888888888822228828008888000000000022222222222202222222022002222228222eeee20000000000000000
00ccc000555555551155511555115555088288288e8e8e8e888822080888ef80880880880022e22222e2802222e28220eee22222228888820000000000000000
0c000c0055555555115551155511555582222228222222220082220088228ef80088e800000222e2e2228800e2228000000eee2228eeee820000000000000000
0000c000555055555555555555555555022222288222222200822200822228e808228e80000022222228880022288000eeee22e2288888200000000000000000
000c00000000055555555555555555500000000888888888000822008222228808222880000008888888800088880000000eeee22eee88200000000000000000
000000000000000000000000000000000000000888000000000822008222228800822800000000008888000088880000eeeeeee2288e22000000000000000000
000c00000000000000000000000000000000000088800000000082000822288008088080000000000000000000000000000eeeee222200000000000000000000
0000000000000000000000000000000000000000088800000000000000888800080000800000000000000000000000000eee0022222000000000000000000000
00000222222222220000888000088000000000000880000008800000000000000000000000000088888000000000022000088000000000000000000000000000
00002222222222222208822022088000000000088880000888800080000222200000000000008822222200000000222200888800000880000000000000000000
000222222222222222282880222280000002222eeeeee088eeeee080222282200000000000882288222220000002222200888800008888000000000000000000
00e444222882288822228800222280002222822fffffe880ffffe880000222200000000000222222222280002222222000888800008888000008800000000000
0e44e4422882888822282880222280000002222eeeeee088eeeee080222222200000000084444422222280002222222000888800002882000088880000000000
0e4e444422228888220882202208800022222288eeee0008eeee008000088fe80000000084848442222280000002222200288200022222200088880000000000
0e4e44e442222222200088802008800000000088000000000000000000088fe80000000088888888222800000000222202222220022222200028820000000000
eeee4e44422282222000000020000000000000000000000000000000000eefe80000000008888888228000000000022002222220022222200022220000000000
2888ee44e4228222000000000088888008888880000080080000800800eefe8800eefe8800888800008888000088880000088800000888000000000000000000
22288e4e4422822200008280082228e8082228e8000800800008008000eefe8800eefe8802888820022882200228822000088800000888000000000000000000
22288eee4e22822200882820082228e8008228e8008008000080080000eefe0000eefe0002288220022882200228822008882220088822220000000000000000
288822eeee228220080000000822228800822288080080080800800800eefe0000eefe0008222280022882200228822008882222088822220000000000000000
02282288822882228000000008222228000822288008008000080080000eee00000eee000222222002222220ee2222ee88282222882822220000000000000000
0228882282282022800000000082222800008828008008000080080000008000000080000242242002222220ee2222ee08882222088822220000000000000000
00228822888200008000000000088880000000880800800000008000000888000088888000844800022222200222222088882220888822220000000000000000
00002222222000008000000000000000000000008008000000000000008808800000000000888800002222000022220000088800000888000000000000000000
07707700007070000007000000000000000000000000000000000000000000000000000000000000000555114441100020000000888888884442200082224442
77777770077777000077700000000000000000000000000000000000000000000000000000000000000511114441110020000000882222224442200082224444
77777770077777000077700000000000000000000000000000000000000000000000000000000000000511114444110020000000822244424442200082224442
07777700007770000077700000000000000000000000000000000000055555500000000000000000000511114444110020000000822244424442200082224444
00777000007770000007000000000000000000000000000000000000051111100000055555550000000555514444110020000000822244424442200082224442
00070000000700000007000000000000000000000000000000000000051144100000051111111000000051144441110020000000822244424442200082224442
00000000000000000000000000000000000000000000000000000000051444100000051114411000000051144441100020000000822244424442200082222222
00000000000000000000000000000000000000000000000000000000051441100000051144411000000051144441100020000000888224424442200088882822
14111411000000000000440000000000000000000000110000000000000000000005551444411000000051144441100044440000082224444444000044444422
11111111000000000000444000000000000000000000111000000000000000000005111144411100000051144441100044440000082224444444000044444422
11141114000000000000444000044000000000000000111000000000000000000005111144441100005555144441100044440000082224444440000044444444
11111111000000000000444000444000000000000110111000000000000000000005111144441100005111144441111044440000082224444440000044444444
14111411000000000000444400444000000000000111411400000000000000000005111144441111055511144444411044440000082224444440000022442222
11111111000000000000444400444000000000000111411400000000000000000005111144441111051114444444411044440000082224444440000022442222
14141414000000000000444400444000000000000111411400000000000000000005551444444111051144444444411044440000082224444440000044442222
11111111000000000000444400444000000000000011411400000000000000000000511444444111051144444444411044440000082224444440000044442222
14141414000000000440444400444000000000000011411400000000022244440000511444444111051144444444411022224444888224442000000000000000
11411141000000000440444404444000000000000011411400000000022244440000511444444111051144444444411022224422822222242000000000000000
14141414000000000440444404444400000000000011411400000000022244445555551444441111555111444444441022224422822222242000000000000000
41414141000000000444444444444400000000000011411400000000022244445111111444441110511111444444441022224444822222242222200000000000
14141414000000000444444444444400004400000114114000000000022244445111111444441110511111444444444044444444822222244442200000000000
41414141000000004444444444444440004404000114114000000000022244445111114444441110555511444444441044444444822222244442200000000000
14441444000000004444444444444444444444440114114000000000022244445511444444441111051144444444444044422444822222244442200000000000
41414141000000004444444444444444444444440114114000000000022244440511444444444111051144444444441044422444888822244442200000000000
44144414000000004444444411111111000000000144144000000000444444440114444444444444444444440511444444444422082224444442200044440000
41414141000000004444444411111111000000000414414000000000444444440514444444444444444444110511444444444422888224444442200044420000
44444444000000004444444411111111000000000140140000000000444444420114444411411144444444110511444444444442822222444442200044440000
41414141000000004444444411111111000000000414410000000000444444440144444411411144444444445551114444444442822222444442222244420000
44444444000000004444444411111111000000000140140000000000444444420444444444411144444444445111114444444444822222444444442222220000
41444144000000004444444411111111000000000040040000000000444444440144444444444444444114445111114444444442888222444444442200000000
44444444000000004444444411111111000000000010010000000000444444420444444441144444444114445111114444444444082224444444442200000000
44414441000000004444444411111111000000000000000000000000444222220144444441144444444444445551444444444442082224444444442200000000
000000000000000000000000000000000000000000000000000000000008000000000cccccc00000000000000000000000000000000000000000000000000000
0000000000077007770777077007770700770000000000000000888000088800000cc000000cc000000000000000000000000000000000000000000000000000
000000000007070700070007070700070700000000000000000080800008888800c0066000000c00000000cccc00000000000000000000000000000000000000
00000000000770077007700770077000077700000000000000088888000800000c066000000000c00000cc0000cc000000000000000000000000000000000000
00000000000707070007000707070000000700000000000000088088000800000c060000000000c0000c00000000c00000000000000000000000000000000000
0000000000077707770777077707770007700000000000000008888800080000c06000000000000c000c00000000c00000000000000000000000000000000000
0000000000000000000000000000000000000000000000000008888808888800c06000000000000c00c0000000000c0000000000000000000000000000000000
0000044404444004000440044444004444400444044000000000000000000000c06000000000000c00c0000000000c0000000000000000000000000000000000
00004cc14cccc44c404cc44cccc144cccc144cc14cc400000007000000070000c00000000000000c00c0000000000c0000000000000000000000000000000000
0004c1cc1c11c14c144cc1c111114c111114c1cc1cc140000077400000777000c00000000000000c00c0000000000c0000000000000000000000000000000000
0004c1cc1c14c144c14cc1c144444c144444c1cc1c1140000777400007777700c00000000000000c000c00000000c00000000000000000000000000000000000
004c14cc1c14c1444cccc14cccc444ccc44c14cc1c14000077774000777777700c000000000000c0000c00000000c00000000000000000000000000000000000
004c14cc1cccccc4441cc14444cc4444cc4c14cc1c14440047774000000000000c006000000000c00000cc0000cc000000000000000000000000000000000000
004ccccc1c111cc1444cc14444cc1444cc1ccccc1c14cc40047740000000000000c0066000000c00000000cccc00000000000000000000000000000000000000
004c11cc1c144cc1444cc1cc44cc1c44cc1c11cc1c14cc140047400000000000000cc000000cc000000000000000000000000000000000000000000000000000
004c14cc1cccccc1ccccc1cccccc1ccccc1c14cc1ccccc14000440000000000000000cccccc00000000000000000000000000000000000000000000000000000
00411411141111114111114111111411114114111411111400000000000000000000000000000000000000000000000000000000000000000000000000000000
004cccccc44cc44cccccc44cc44ccc44cccccc44cccccc4000000000000000000000000000000000000000000000000000000000000000000000000000000000
004c77ccc147c14c7cccc14cc14c7c14c77ccc14c7cccc1400000000000000000000000000000000000000000000000000000000000000000000000000000000
004cccccc14cc14cc111114cc14c7c14cccccc14cc1111140000c000000080000000c00000000000000000000000000000000000000000000000000000000000
004cc111114cc14cc144444cc14ccc14cc111114cc1400000000c000000080000000c00000000000000000000000000000000000000000000000000000000000
004cc144444cc14cccccc14cc14ccc14cc144444cccccc400000c00000008000000ccc0000000000000000000000000000000000000000000000000000000000
004cccc144ccc14cccccc14ccccccc14ccccc444cccccc140000c0000000800000ccccc000000000000000000000000000000000000000000000000000000000
004cccc144ccc14111ccc14ccccccc14ccccc144111ccc1400000000000000000000000000000000000000000000000000000000000000000000000000000000
004cccc144ccc14444ccc14cc11ccc14cc111144444ccc1400000000000000000000000000000000000000000000000000000000000000000000000000000000
004cc11144ccc14444ccc14cc14ccc14cc144444444ccc1400000000000000000000000000000000000000000000000000000000000000000000000000000000
004cc14404ccc14cccccc14cc14ccc14cccccc44cccccc1400000000000000000000000000000000000000000000000000000000000000000000000000000000
004cc14004ccc14cccccc14cc14ccc14cccccc14cccccc1400000000000000000000000000000000000000000000000000000000000000000000000000000000
004cc14004ccc14cccccc14cc14ccc14cccccc14cccccc1400000000000000000000000000000000000000000000000000000000000000000000000000000000
00411140041111411111114111411114111111141111111400000000000000000000000000000000000000000000000000000000000000000000000000000000
00044400004444044444440444044440444444404444444000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8000000080000000800000008000000080000000800000008000000080000000e000000030000000800000008000000080000000800000008000000080000000
00000001000000004000000000000000400000000000000000000000100000000000000000000001000000000000100000040000000000100004000000000001
00000000000100000400000000000000000400000000000001000000000100000000000001000000600100000000000001000400000000000000000001000000
10000000000000000040000010000000000000400000000000000000000000100000000000000001000000020000000000000004010000000010000000000000
00000000100000000000000001000000001000001000000110000000200000020000000010000000000000001000000020000000100000000000000020070000
00000000000000000000000000100000000000000000000000001000000000100000000000000000000000000000001000000000010000001000000000000000
00001000000000000000000000000000000000000000000000100000000100000000000000100000000000000001000001000000000000000000001001000000
00000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000100000000000000000
800000008000000080000000800000008000000080000000a0000000800000008000000080000000800000008000000080000000b00000008000000080000000
00000000000000004000010010000000040000000000000000000000000000088000000000000000000000004000000110000001000000100000000010000000
00000000100000000400000100100000104000011000001000000100000100800080000000800000100001000040800000000000100080000000010000000000
10000000000000000040000000010000000400000000000000000000000008008000000000001000000000010010400001000000000000000001000000800000
00000000000000701000000000007000000000000000000070000000800080000080001070000000000000000000000000000100700000000000000000005000
00020000000000000000000200010000000001000000000000000000000008008000000000000001100000008000000000000000000000000000000000800000
00000001000000000000100000100000000000000100000000000100000100800080000000800000000000000000010000000000000000001000100000000000
00000000000000000000000010000000000000000000000000000000000000088000000000000000000010000000000000010000000000000000000010000000
8000000080000000800000008000000080000000d00000008000000070000000800000008000000080000000b000000080000000800000008000000060000000
00000000800000000000000080000000400010000000000100010000000000000080000040040000000000000040000010000000000080010040000000000000
10050000100001000000000000080000040000000000000010000000100000000800100004004040100100001000001000000001000000000000000100000000
00000000000000000001000208000000004000001000000000001000000000008000000200400004000000000001000000100000000000000000500000000000
00000020001000507000000000870000005000000000000000000000300000000008000000000000000000000000000700500000000100000000000000009000
00000100000000000000000008000000000000100000100000100001000000000100800000000000000000000000000000000000000000001000000000000000
01000000100010000000001000080000100000000000000000000000100000000000080000000500010000010010001000000000000000000000000000000000
00000000800000000000000080000000000000000000000010001000000000000000000000000000000000000000000010000000000080010010000000000000
7000000080000000800000008000000080000000d000000080000000800000008000000080000000800000008000000080000000800000008000000080000000
00000000400001000400000000000000000100000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000
10000000040000000040000101000010800001000100000100200000000000000000000000000000000000000000000000000000000000000000000000000000
00000000004000000004000000000000000000000000000010000001000000000000000000000000000000000000000000000000000000000000000000000000
30000000100000007000000000000000008000010000000000000500000000000000000000000000000000000000000000000000000000000000000000000000
00000000000501000000000010000000010008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
10000000000000000100050000010010000000001000000001000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000010000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
1111111111111111111111111111111111111111111118222hhhhhh1111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111188822hhhhhhh111111111111111111111111111111111111111111111111111111111111111111111111
1177177111771771117717711111sssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssssss111111111111111111771171711
1177777111777771117777711111sssssssssssscssssssssssscssssssssssscsssssschhhh8hhhhhhhhhhh8hhhhhhhhhhh8111111111111111111171171711
1177777111777771117777711111111111111111c1118222222hchhh11111111c111111c11118111111111118111111111118111111111111111111171177711
1117771111177711111777111111111111111111c1118222222hchhh11111111c11111ccc1118111111111118111111111118111111111111111111171111711
1111711111117111111171111111111111111111c1118222222hchhh11111111c1111ccccc118111111111118111111111118111111111111111111777111711
111111111111111111111111111111111111111111118222222hhhhh111111111111111111111111111111111111111111111111111111111111111111111111
111111111111111111111111111111111111111111118888222hhhhh111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111118222hhhhhhh111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111118222hhhhhh2111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111118222hhhhhhh111111111111111111111111111111111111111111111111111111111111111111111111
1111111111111111111111111111111111111111111118222hhhhhh2111111111111111111111111111111sssssss11111111111111111111111111111111111
1111111111111111111111111111111111111111111118222hhh2222111111111111111111111111111111s11111111111111111111111111111111111111111
1111111111111111111111111111111111111111111118222hhh1111111111111111111111111111111111s111hh111111111111111111111111111111111111
1111111111111111111111111111111111s11111111118222hhh1111111111111111111111111111111111s11hhh111111111111111111111111111111111111
1h111h111h111h111h111h111h111h111h111h111h1118222hhh1h111h111h111h111h111h111h111h11sss11hhh11111h111h111h111h111h111h111h111h11
111111111111111111111111111111111111111111118222hhh211111111111111111111111111111111s1111hhh111111111111111111111111111111111111
111h111h111h111h111h111h111h111h111h111h111h8222hhhh111h111h111h111h11hh111h111h111hs1111hhhh11h111h111h111h111h111h111h111h111h
111111111111111111111111111111111111111111118222hhh211111111111111111hhh111111111111s1111hhhh11111111111111111111111111111111111
1h111h111h111h111h111h111h111h111h111h111h118222hhhh1h111h111h111h111hhh1h111h111s11ssss1hhhh1111h111h111h111h111h111h111h11hh11
111111111111111111111111111111111111111111118222hhh211111111111111111hhh1111111111111s11hhhh11111111111111111111111111111111hh1h
1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h8222hhh21h1h1h1h1h1h1h1h1hhh1h1h1h1h1h1h1s11hhhh111h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhh
111111111111111111111111111111111111111111118222222211111111111111111hhh1111111111111s11hhhh111111111111111111111111111111hhhhhh
1h1h1h1h1h1h1hss1h1h1h1h1h1h1h1h1h1h1h1h1h1h888828221h1h1h1h1h1h1h1h1hhh1h1h1h1hhh1h1s11hhhh111h1h1h1h1h1h1h1h1h1h1h1hhh1hhhhhhh
11h111h111h111s111h111h111h111h111h111h111h111h111h111h111h111h111h1hhhh11h111hhhhh11s11hhhh111111h111h111h111h111h111hhh1hhhhhh
hh1h1h1h1h1h1hsh1h1h1hhh1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhh1h1h1hhh1ssss1hhhhh11h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhhhh
h1h1h1h1h1h1h1s1h1h1hhhhh1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhh1h1h1hhhhhs1111hhhhh111h1h1h1h1h1h1h1h1h1h1h1hhh1hhhhhh
hh1h1hhh1h1hsssssh1h1hhh1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhh1h1h1hhhsss111hhhhh1111ssssh1h1h1h1h1h1h1h1hhhhhhhhhhh
hhh1hhssssssssssssssssssh1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhh1h1hhhhs111hhhhhhh111111111h1h1h1h1h1h1h1h188888hhhhh
hssshsccccccccccccccccccshhh1hhh1hhh1hhh1hhh1hhh1hhh1hhhshhh1hhh1hhhhhhhhhhh1hhhhhs11hhhhhhhhh1111hh11hh1hhh1hhh1hhh182228e8hhhh
hssssscsssssssssssssssscs1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhhhh1h1hhhhs11hhhhhhhhh111hhh11h1h1h1h1h1h1h1h82228e8hhhh
6cccssssssssssssssssssscsh1hhh1hhh1hhh1hhh1hhh1hhh1hhh1hhh1hhhhhhh1hhhhhhhhhhh1hhhs11hhhhhhhhhhhhhhh111hhh1hhh1hhh1hh8222288hhhh
6ssssssss11sss11sss11ssss1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhh1hhhhhhhhh1hhhhhhs18hhh8hhhhhhhhhhh1111h1h1h1h1h1hh88222228hhhh
hssssssss11sss11sss11sssshhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhsss111hhhhh88888hhhh11hhhhhhhhhhhh8hh822228hhhh
hssshssssssssssssssssssss1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1h1hhhhhhh1hhhhhhhhh1hhhh8s11111hhh868hhhh88h6111h1h1h1h1h18hh8h8888hhhhh
hhhhhhsssssssssssssssssshhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhssss11111hh86668688hh666111hhhhhhhhhhh8hh8hhhhhhhh
hhhhhhhhhhhhhhhhh1hhhhhhhhhhh1hhh1hhh1hhh1hhh1hhh1hhhhhhh1hhhhhhhhhhhhhhhhhhhhs11ssss11h86h6666688h6661111hhh1hhs1h8hh8hhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhs11hs11hhh66666668686h6h111hhhhhhhhh8hh8hhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhh1hhh1hhh1hhh1hhh1hhh1hhhhhhhhhhhhhhhhhhhhhhhhhh6hhh661hs116h6h68666666666h8111hh1hhh1hhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh666h66666666666666866666868h8111hhhhhhhhhhhhhhhhhhhhhhh
h11shhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh6h6hhhhh6hhs6666666666h68666686868h8111hhhhhhhhhhhhhhhhhhhhhhh
h111hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh6h6ss6s6s1h666hh68666666866666h8111hhhhhhhhhhhhhhhhhhhhhhh
h111hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh11h6hhhhhhhh66666666661hhhhhh88h688688868666811hhhhhhhhhhhhhhhhhhhhshhh
h111hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh16h161hhhhhhhhhh6h6s161611hhhhhhhh8h88888888868111hhhhhhhhhhhhhhhhhhhhhhhh
1h11hhhhhhhhhhhhhhhhhhhhhhhhhhhhh6hhhhhhhhhhhhhhhhhhh6111111hh6h6hhhhhhhhs11111hhhhhhhhh8hh8686888h68111hhhhhhhhhhhhhhhhhhhhhhhh
1h11hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh6hhh6hh6hh6hhh1111111hhhhhhhhhhhhss11hhhhhhhhhhhh8166668888661111hhhhhhhhhhhhhhhhhhhhhhh
1h11hhhhhhhhhhhhhhhhhhhhhhhhh6hhhhhhh6hhhhhhhhhhhhh11h111h11h1hhhhhhhhhhh1111hhhhhhhhhhhhh8666888ef8hh111hhhhhhhhhhhhhhhhhhhhhhh
1h11hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh111111h11h1hhhhhhhhhhh111hhhhhhhhhhhhhhhh688228ef8h11hhhhhhhhhhhhhhhhhhhhhhhh
1h11hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh111111h11h1hhhhhhhhhhh111hhhh8hhhhhhhhhhh8822228e8h11hhhhhhhhhhhhhhhhhhhhhhhh
1h11hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh111h11h11h1hhhhhhhh11h111hhhhhhhhhhhhhhhhh82222288hh1hhhhhhhhhhhhhhhhhhhhhhhh
1h1111hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh11h11h11h1hhhhhhhh111h11hhhhhhhh8h8h8hhhh82222288hh1hhhhhhhhhhhhhhhhhhhhhhhh
8h11111hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh11h11h11h1hhhhhhhh111h11hhhhhhhhhhhhhhhhhh822288hhhhhhhhhhhhhhhhhhhhhhhhhhhh
811h111hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh11h11h11h1hhhhhhhh111h11hhhhhhhhhhhhhhhh11h8888hhhh1hhhhhhhhhhhhhhhhhhhhhhhh
811h111hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh11h11h11h1hhhhhhhhh11h11hhhhhhhhhhhhhhhh11hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
8111h11hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1111h11h11hhhhhhhhh11h11hhhhhhhhhhhhhhhhhhhhhh8h88h1hhhhhhhhhhhhhhhhhhhhhhhh
h111h11hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh11h11h11h11hhhhhhhhh11h11hhhhhhhhhhhhhhhhhhhh88888hhhhhhhhhhhhhhhhhhhhhhhhhhh
1111h11hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh11hhhhhhh11h11h11h11hhhhhhhhh11h11hhhhhhhhhhhhhhhhhhhh22228h8hhhhhh11hhhhhhhhhhhhhhhhh
1h11h11hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh111hhhhhh11h1sh11h1hhhhhhhhhh11h11hhhhhhhhhhhhhhhhhhh22882282hhhhhh111hhhhhhhhhhhhhhhh
1h11h11hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh111hhhhhh11h111h11shhhhhhhhh11h11hhhhhhhhhhhhhhhhhhhh2222222hhhhhhh111hhhhhhhhhhhhhhhh
1h11h11hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh11h111hhhhhhh11h11h11hhhhhhhhhh11h11hhhhhhhhhhhhhhhhhhhhh2222h22hhh11h111hhhhhhhhhhhhhhhh
h111h11hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh111h11hhhhhhh11h11h11hhhhhhhhhh11h11hhhhhhhhhhhhhhhhhhhhhh222hh2hhh111h11hhhhhhhhhhhhhhhh
h111h11hhhhhhhhhhhhhhhhhhhhhhh11hhhhhhh111h11hhhhhhh11h11h11h1hhhhhhhh11h11hhhhhhhhhhhhhhhhhhhhhh1212hhhhh111h11hhhhhhhhhhhhhhhh
h11h11hhhhhhhhhhhhhhhhhhhhhhhh111hhhhhh111h11hhhhhhh1111h11h11hhhhhhhhh11h11hhhhhhhhhhhhhhhhhh11h161hhhhhh611h11hh6hh6hhhhhhhhhh
h11h11hhhhhhhhhhhhhhhhhhhhhhhh111hhhhhhh11h11hhhhhh11h11h11h11hhhhhhhhh11h11hhhhhhhhhhhhhhhhhh111h11hhhh6hh61h66hhhh6hhh6h66hhhh
111h11hhhhhhhhhhhhhhhhhhhhh11h111hhhhhhh11h11hhhhhh11h11h11h11hhhhhhhhh11h11hhhhhhhhhhhhhhhhhh111h11hhhhhhh11h11hhhhhhhhhhhhh6hh
111h11hhhhhhhhhhhhhhhhhhhhh111h11hhhhhhh11h11hhhhhh11h11h11h1hhhhhhhhhh11h11hhhhhhhhhhhhhhhhhh111h1166h6hhh16h11h6hhhhhhhhhhhh6h
1h11h11hhhhhhhhhhhhhhhhhhhh111h11hhhhhhh11h11hhhhhh11h111h11hhhhhhhhhh11h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhhh11h11hhhhhhh6hhhhhhhh
1h11h11hhhhhhhhhhhhhhhhhhhh111h11hhhhhhh11h11hhhhhhh11h11h11hhhhhhhhhh11h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhhh11h11hhhhhhhhhhhhhhhh
h111h11hhhhhhhhhhhhhhhhhhhhh11h11hhhhhh11h11hhhhhhhh11h11h11hhhhhhhhhh11h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhh11h11hhhhhhhhhhhhhhhhh
h111h11hhhhhhhhhhhhhhhhhhhhh11h11hhhhhh11h11hhhhhhhh11h11h11h1hhhhhhhh11h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhh11h11hhhhhhhhhhhhhhhhh
h11h11hhhhhhhhhhhhhhhhhhhhhh11h11hhhhhh11h11hhhhhhhh1111h11h11hhhhhhhhh11h11hhhhhhhhhhhhhhhhhhh11h11hhhhhh11h11hhhhhhhhhhhhhhhhh
h11h11hhhhhhhhhhhhhhhhhhhhhhs1h11hhhhhh11h18888888821h11h11h11hhhhhhhhh11h11hhhhhhhhhhhhhhhhhh11h11hhhhhhh11h11hhhhh82hhhhhhhhhh
111h11hhhhhhhhhhhhhhhhhhhhhh11h11hhhhhhh11h8822222221h11h11h11hhhhhhhhh11h11hhhhhhhhhhhhhhhhhh11h11hhhhhhhh11h11hhh822hhhhhhhhhh
111h11hhhhhhhhhhhhhhhhhhhhh11h11hhhhhhhh11h8222hhh221h11h11h1hhhhhhhhhh11h11hhhhhhhhhhhhhhhhhh11h11hhhhhhhh11h11hhh822hhhhhhhhhh
1h11h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhhhh11h8222hhh221h111h11hhhhhhhhhh11h11hhhhhhhhhhhhhhhhhhh11h11hhhhhhhh11h11hh8222hhhhhhhhhh
1h11h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhhhh11h8222hhh2211h11h11hhhhhhhhhh11h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhhh11h11hh8222hhhhhhhhhh
h111h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhhh11h18222hhh2211h11h11hhhhhhhhhh11h11hhhhhhhhhhhhhhhhhshh11h18888888888888888822h8hhhhhhhh
h111h11hhhhhhhhhhhhhhhhhhhhh11h11hhhhhh11h18222hhh2211h11h11h1hhhhhhhh11h11hhhhhhhhhhhhhhhhhhhh1188288288e8e8e8e8e888828hhhhhhhh
h11h11hhhhhhhhhhhhhhhhhhhhhh11h11hhhhhh11h188822hh221111h11h11hhhhhhhhh11h11hhhhhhhhhhhhhhhhhhh1822222282222222222222288hhhhhhhh
h11h11hhhhhhhhhhhhhhhhhhhhhh11h11hhhhhh11h118222hhh21h11h11h11hhhhhhhhh11h11hhhhhhhhhhhhhhhhhh11h22222288222222222228828hhhhhhhh
111h11hhhhhhhhhhhhhhhhhhhhhh11h11hhhhhhh11h18222hhh21h11h11h11hhhhhhhhh11h11hhhhhhhhhhhhhhhhhh11h11hhhh888888888888822h8hhhhhhhh
111h11hhhhhhhhhhhhhhhhhhhhh11h11hhhhhhhh11h18222hhh21h11h11h1hhhhhhhhhh11h11hhhhhhhhhhhhhhhhhh11h11hhhh888h11h11hh8222hhhhhhhhhh
1h11h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhhhh11h18222hhh21h111h11hhhhhhhhhh11h11hhhhhhhhhhhhhhhhhhh11h11hhhhh88811h11hh8222hhhhhhhhhh
1h11h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhhhh11h18222hhh2hh111h11hhhhhhhhhh11h11hhhhhhhhhhhhhhhhhhhh11h11hhhhh8881h11hhh822hhhhhhhhhh
h111h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhhh11h118222hhh21hh11h11hhhhhhhhhh11h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhh11h11hhhh822hhhhhhhhhh
h111h11hhhhhhhhhhhhhhhhhhhhh11h11hhhhhh11h118222hhh2hh111h11h1hhhhhhhh11h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhh11h11hhhhh82hhhhhhhhhh
h11h11hhhhhhhhhhhhhhhhhhhhhh11h11hhhhhh11h118222hhh21h11h11h11hhhhhhhh1hh1hhhhhhhhhhhhhhhhhhhhh11h11hhhhhh11h11hhhhhhhhhhhhhhhhh
h11h11hhhhhhhhhhhhhhhhhhhhhh11h11hhhhhh11h188822hhh2hh11h11h11hhhhhhhhh1hh1hhhshhhhhhhhhhhhhhh11h11hhhhhhh11h11hhhhhhhhhhhhhhhhh
h11h11hhhhhhhhhhhhhhhhhhhhhh11h11hhhhhhh11h8222222h2hh11h11h11hhhhhhhh1hh1hhhhhhhhhhhhhhshhhhh11h11hhhhhhhh11h11hhhhhhhhhhhhhhhh
h11h11hhhhhhhhhhhhhhhhhhhhh11h11hhhhhhhh11h8222222h21h11h11h1hhhhhhhhhh1hh1hhhhhhhhhhhhhhhhhhh11h11hhhhhhhh11h11hhhhhhhhhhhhhhhh
h111h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhhhh11h8222222h222221h1shhhhhhhhhh1hh1hhhhhhhhhhhhhhhhhhhh11h11hhhhhhhh11h11hhhhhhhhhhhhhhhh
hh11h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhhhh11h8222222hhhh221h11hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1hh1hhhhhhhhh11h11hhhhhhhhhhhhhhhh
h111h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhhh11h18222222hhhh221h11hhhhhhhhhhh1hh1hhhhhhhhhhhhhhhhhhhh1hh1hhhhhhh11h11hhhhhhhhhhhhhhhhh
hh11h11hhhhhhhhhhhhhhhhhhhhh11h11hhhhhh11h18222222hhhh221h11hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1hh1hhhhhhhh11h11hhhhhhhhhhhhhhhhh
h11h11hhhhhhhhhhhhhhhhhhhhhh11h11hhhhhh11h18888222hhhh22h11h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1hh18h88hhh11h11hhhhhhhhhhhhhhhhh
h11h11hhhhhhhhhhhhhhhhhhhhhh11h11hhhhhh11h118222hhhhhh22h11hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1hh88888hhhh11h11hhhhhhhhhhhhhhhhh
h11h11hhhhhhhhhhhhhhhhhhhhhh11h11hhhhhh1hh1h8222hhhhhh22h11h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh22228h8hhh11h11hhhhhhhhhhhhhhhh
h11h11hhhhhhhhhhhhhhhhhhhhh11h11hhhhhhhh1hh18222hhhhhh22h11hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh122882282hhh11h11hhhhhhhhhhhhhhhh
hh11h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhhh1hh1h8222hhhhhh22222hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh2222222hhhh11h11hhhhhhhhhhhhhhhh
hh11h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhhhh1hh18222hhhhhhhhh22h1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh2222h22hhh11h11hhhhhhhhhhhhhhhh
hh11h11hhhhhhhhhhhhhhhhhhhh11h11hhhhhhh1hh1h8222hhhhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh222hh2hh11h11hhhhhhhhhhhhhhhhh
hh11h11hhhhhhhhhhhhhhhhhhhh1hh1hhhhhhhhhhhhh8222hhhhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh2h2hhhh11h11hhhhhhhhhhhshhhhh
h11h11hhhhhhhhhhhhhhhhhhhhhh1hh1hhhhhhhh1hh18222hhhhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhshhhhhhhhhhhhhhhhhhhhhh11h11hhhhhhhhhhhhhhhhh
h11h11hhhhhhhhhhhhhhhhhhhhh1hh1hhhhhhhhhhhhh8222hhhhhhhhhhh2hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh11h11hhhhhhhhhhhhhhhhh
h11h11hhhhhhhhhhhhhhhhhhhhhh1hh1hhhhhhhhhhh88822hhhhhhhhhhh2hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1hh1hhhhhhhhhhhhhhhhhh
h11h11hhhhhhhhhhhhhhhhhhhhh1hh1hhhhhhhhhhhh822222hhhhhhhhhh2hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1hh1hhhhhhhhhhhhhhhhh
h1hh1hhhhhhhhhhhshhhhhhhhhhhhhhhhhhhhhhhhhh822222hhhhhhhhhh22222hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1hh1hhhhhhhhhhhhhhhhhh
hh1hh1hhhhhhhhhhhhhhhhhhhhhh1hh1hhhhhhhhhhh822222hhhhhhhhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhshhh1hh1hhhhhhhhhhhhhhhhh
h1hh1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhshhhhhhhh888222hhhhhhhhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1hh1hhhhhhhhhhhhhhhhhh
hh1hh1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8222hhhhhhhhhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
h1hh1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8222hhhhhhhhhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh1hh1hhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh88822hhhhhhhhhhh2hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hh1hh1hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8222222hhhhhhhhh2hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8222222hhhhhhhhh2hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8222222hhhhhhhhh22222hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8222222hhhhhhhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8222222hhhhhhhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8222222hhhhhhhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8888222hhhhhhhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8222hhh2222hhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8222hhh2222hh22hhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8222hhh2222hh22hhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8222hhh2222hhhhhhh22222hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8222hhhhhhhhhhhhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8222hhhhhhhhhhhhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8222hhhhhh22hhhhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8222hhhhhh22hhhhhhhhh22hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh

__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
5253000000000053000000645300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6263640053000063520052726300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7272726463646372626462727264520000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00004a4900004800000000000000000000484900000048490000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
48004a4b49005a494700000000000000004a4b0000004a594900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5a495a595b007b696a00000048490000005a59494a4958694b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7b5b6a794b486a7a6b000000584b4900486a725958595a796900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
78797b7a6b687872795900475a5b6b0068727969686b6a726b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7272787272787a72726b00787a72720078727a6b787a787a7200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4d4c004d4c004d4c005500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5d4c005d4c005d6e006555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d6e007d4c006d7e006565550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5d7e006d6e007d7e006565655500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d726e5d7e005d7c4c6565656500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d726e7d726e6d6c6e6565656500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5d6c7e5d6c7e5d727e6565656500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
67727c675f7c675f7c7575757500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6772726772726772720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6772726772726772720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
675f72676c776772720000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5d72775d725e5d6c770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d6c7f7d727f6d727f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7d77005d77005d77000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5d5e006d5c007d5e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6d5c007d7f006d5e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5d7f005d00005d7f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4f00004f00004f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00010000271502615025150251502415023150201501f1501c15018150131500f1500705005050000500600005000030000100000000000000d000010000f000180001a0001c0001e000220001c0000100000050
000100001d0501f0502105022050270000e0000b00009000070000400003000020000200001000000000000002000010000000000000000000000000000000000000000000000000000000000000000000000000
000200001f0301b03015030100300b030080200605005050040500305002050000500005005000040000200002000010000000000000000000000000000000000000000000000000000000000000000000000000
0005000021950110000b0000100002000010000000023000260000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00020000216501d6501e65015150151501515015150151501515015150141501315011150101500d1500a15007140041400114000140021400114000130001200200001000010000060000600006000060000600
000100001e0501e0501e0501f1501f1501f1501b05016050120500e0400a0400700004000020000200001000100000e0000d0000c0000b0000800006000030000100000000000000000000000000000000000000
000600000605408051090510a0510c0510d0510f0511005112051140511505117051170550e0040d6040d6020d6020d6020b6020a6020a6020a60205005020010000100001000010000100001000010000100001
000100002c0502e050300502d0502305019000140000c000060000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001800002122021220092002122021220000002122021220000002122021220000002122021220000002120021200000000000000000000000000000000000000000000000000000000000000000000000000000
0003000024a501d6101a61017610156101361012610106100f6100e6100b6100a6100761004610016100060000000000000000000000000000000000000000000000000000000000000000000000000000000000
0001000023130241302513027130291302c1002e1002e1002e1002e1002c03028030260302303021030200301e0301d0301c0301c0301c0301c0301c030230002300023000230002300023000230000000023000
000100002213023130251200c300130000f30022020280201f0201d020230201a0201f02019020180201a0201802014000120000e00008000030000200003300033002e0002d0002c0002b000280002700025000
00070000290030200018073140731d0502b073240501d073210501b05123051120511b05112050066300563005620046100461004610046100900008000000000000000000000000000000000000000000000000
000100001d0301d030210302103000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010f00200c0432d200211002d2001c625130000c0002d2000c0431b0002d200160001c6250c000130002d2000c0432d2000c0000c0431c6252d2000c000160000c0432d200130000c0001c6250c0432d2002d200
010f000002012020400e13102152020400e132021510204202111021520e041021320e15102032021500213202010020420e13002152020420e131021520204002112021520e041021320e1500e0310215202132
050f0020020750e0750e0050e00511075140050207514005170050e07517005170050e07517005020750e0050e0750e0050e0050e07514005170050e0750e005020750b0050b00502075080050e0050e07502005
500f00201a1101d1101f011221201a1201d0201f131221301a0301d1411f140220301a1301d1201f021221201a1101d0101f111221201a0201d1201f130220301a1301d1401f040221301a1301d0201f12022120
010f00002f611256111c61117611116110f6110c611096110761106611066110561103611036110261102611026150e6000b6010a601040010300103001030010100101001010010100101001020010200102001
010f00201a0501a0000e0050e0051d052140050e15014005170051a05217005170051a050170050e1500e0051a0520e0050e0051a05014005170051a0520e0050e1500b0050e15011100080050e0050e15002005
000c00000c0630000000000000000c0630000000000000000c0630c00000000000000c0630000000000000000c0630000000000000000c0630000000000000000c0630000000000000000c063000000c00000000
010c00000206002055021550214002060020520215002140020400205002152021400204002035021300214202040020500215202142020400205502155021400204002052021500204202040020520215202020
010f00201a0501a0000e0050e0051d052140050e15014005170051a05217005170051a050170050e1500e0051a0001a0520e0051a0001a052170051a0000c1550e1500b0050e1000e1500e1000e0050e15002005
010f00201d0521a0000e0051d05013000140051d05214005170051a05217005170051a050170051a0500e0051a0500e1000e0050e0051d052140050e150140050e1500e0050e1500e0050e1500e0050e1500e005
__music__
03 20212563
01 24622363
01 60622363
03 60222363
00 41424344
03 26274844
01 20212563
00 20212863
02 20212963

