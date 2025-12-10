

function _init()
    poke(0x5f5c, 0xff) --no button repeat--
    poke(0x5f5d, 0xff) --no button repeat--
    pal(4, 129, 1) -- add blues to pallette
    pal(5, 140, 1)

    environment = {
        drag = 0.95,
    }

    player = player_create()
    playing = false


    level_height = 112
    level_speed = 2/3
    dead_ctr = 2137
    score = 0
    
    background_x = rnd(128)
    background_range_x = rnd(13)
    background_len = 3 + rnd(3)

    press_x_text = {target_y = 92}
    add_tf(press_x_text, 33, 132)

    back_particles = {}
    for i=1,20 do
        back_particles[i] = {rnd(127), rnd(127)}
    end
end

function init_gameplay()
    dead_ctr = 0
    score = 0
    playing = true
    beat_counter = 0
    beat_time = 6
    in_beat_ctr = 0
    pillars = {}
    player_bullets = {}
    enemy_bullets = {}
    enemies = {}
    foam_particles = {}
    explosion_particles = {}
    player = player_create()
    pillar_spawn(31+rnd(30), 24)
    press_x_text.target_y = 132
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
        if beat_counter % 23 == 0 then -- every 2.3 seconds
            -- pillar_spawn(32 + rnd(80), 24 + rnd(16))
            pillar_spawn(32+rnd(64), 24)
        elseif beat_counter % 35 == 0 then
            bubblefish_spawn(16+rnd(88))
        elseif beat_counter % 200 == 0 then
            bubblefish_spawn(46+rnd(8))
            bubblefish_spawn(76+rnd(8))
        end
    end

    for i, enemy in ipairs(enemies) do
        enemy.update_func(enemy)
        if enemy.dead then
            deli(enemies, i)
        end
    end

    enemy_bullets_update()

    pillars_update()

    else -- end of main game loop, menu code below
    dead_ctr += 1
    if btnp(4) or btnp(5) then -- pressed play
        if (dead_ctr > 50) then
            init_gameplay()
            sfx(1)
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
    particles_update() -- do in any mode
    tf_spring_to(press_x_text, nil, press_x_text.target_y, 0.003)
    tf_update(press_x_text)
    background_x -= level_speed / 10
    if background_x < -48 then
        background_x = 128
        background_range_x = rnd(11)
        background_len = min(3 + rnd(3), 13-background_range_x)
    end
end

function _draw()
    cls(4)
    rectfill(0, 0, 127, 16, 1)
    for i=0,127,8 do
        spr(80, i, 16, 1, 3)
    end

    --draw background--
    map(background_range_x, 0, background_x, 16, background_len, 3)


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

    spr(1, flr(player.x-12), flr(player.y-7), 3, 2)
    particles_draw()
    local sine_prop = 2*sin(time())
    line(player.x-13, flr(player.y+1-sine_prop), player.x-13, flr(player.y+2+sine_prop), 6)  --propeller
    for bullet in all(player_bullets) do
        -- circfill(bullet.x-10, bullet.y, bullet.dx, 6)
        spr(4, bullet.x-8, bullet.y-4, 2, 1)
    end
    for bullet in all(enemy_bullets) do
        spr(23, bullet.x-4, bullet.y-4)
    end

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

    -- print("particles "..#foam_particles, 63, level_height+3)
    else -- draw main menu
        if game_over then
            press_x_text.target_y = 92
            print("game over", 47, 31, 2)
            print("game over", 46, 30, 7)
            print("SCORE", 53, 61, 7)
            score_str_length = print("\^w\^t"..score,0,-100)
            print("\^w\^t"..score, 64-0.5*score_str_length, 50)
            pset(63,63)
        else
            --print game title
        end
    end
    print("press ❎", 48, press_x_text.y+sine_y+1, 1)
    print("press ❎", 47, press_x_text.y+sine_y, 7)

    -- print("plr:"..#pillars.." enm:"..#enemies.." pb:"..#player_bullets.." eb:"..#enemy_bullets, 38, level_height + 3)

    --debug--
    -- pset(player.x, player.y, 11)
    -- rect(player.x-player.x_half_size, player.y-player.y_half_size, player.x+player.x_half_size, player.y + player.y_half_size, 11)

end
